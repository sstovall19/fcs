package com.fonality.service;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.Set;
import java.util.logging.ConsoleHandler;
import java.util.logging.Logger;

import javax.xml.datatype.DatatypeConfigurationException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.bu.entity.Bundle;
import com.fonality.bu.entity.BundlePriceModel;
import com.fonality.bu.entity.EntityAddress;
import com.fonality.bu.entity.OrderBundle;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.TaxMapping;
import com.fonality.bu.entity.TaxTuple;
import com.fonality.bu.entity.json.Input;
import com.fonality.bu.quote.TaxCalculator;
import com.fonality.dao.BundlePriceModelDAO;
import com.fonality.dao.OrderBundleDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.service.BillSoftService.EZTaxThread;
import com.fonality.util.BillSoftProperties;
import com.fonality.util.BillingException;
import com.fonality.util.FSPConstants;
import com.fonality.util.ObjectUtils;

@Transactional
public class QuoteTaxationService {

	@Autowired
	private OrderBundleDAO orderBundleDAO;
	@Autowired
	private BundlePriceModelDAO bundlePriceModelDAO;
	@Autowired
	private OrderGroupDAO orderGroupDAO;

	private BillSoftService bsService;
	
	private org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(QuoteTaxationService.class.getName());

	private Properties bsProps = null;

	/**
	 * The workhorse method. Pulls order data from the DB, makes calls to
	 * calculate taxes on the order and inserts the final tax numbers back into
	 * the DB
	 * 
	 * @param inputObj Deserialized JSON containing the order ID
	 * @throws DatatypeConfigurationException
	 * @throws IOException
	 * @throws InterruptedException
	 */
	public void calculateAndInsertTaxRates(Input inputObj) throws DatatypeConfigurationException, IOException, InterruptedException {
		double otTaxTotal = 0.00;
		double mrcTaxTotal = 0.00;
		// long startTime = System.currentTimeMillis();
		String orderId = inputObj.getOrderId();
		if (!ObjectUtils.isValid(orderId)) {
			throw new NumberFormatException("Null or empty value for order_id");
		}
		// Find each order group in the order. Each may ship to a different address, and therefore have different tax rates
		List<OrderGroup> orderGroupList = orderGroupDAO.getOrderGroupListByOrderId(Integer.parseInt(orderId));
		if (ObjectUtils.isValid(orderGroupList)) {
			// Get BillSoft properties, passing "true" because we are in test mode
			bsProps = BillSoftProperties.getProperties(true);
			suppressSoapWarnings();
			bsService = new BillSoftService(true);
		}
		//orderGroupList may be empty, but will not be null, so this loop will simply be skipped if data is missing
		for (OrderGroup orderGroup : orderGroupList) {
			// The max number of codes is 19, so the default size of 16 is actually pretty good
			HashMap<String, TaxTuple> taxMap = new HashMap<String, TaxTuple>();
			EntityAddress shipAddress = orderGroup .getEntityAddressByShippingAddressId();
			String countryISO = shipAddress.getCountry();
			double vat = 0.00;
			boolean isDomestic = false;
			// Domestic (USA) orders will go through BillSoft
			if (FSPConstants.USA_ISO3_CODE.equals(countryISO) || FSPConstants.USA_ISO2_CODE.equals(countryISO)) {
				// Generate a BillSoft "PCode" for tax jurisdiction
				bsService.generatePCode(shipAddress);
				isDomestic = true;
				// System.out.println("Domestic");
			} else {
				// Non-US orders may have VAT applied if we support it for that country
				String vatStr = bsProps.getProperty(countryISO);
				if (vatStr != null) {
					vat = Double.parseDouble(vatStr);
				}
				// System.out.println("International");
			}
			// Loop over all order bundles to generate a list of unique transaction codes and quantities for each
			Set<OrderBundle> orderBundleSet = orderGroup.getOrderBundles();
			for (OrderBundle orderBundle : orderBundleSet) {
				BigDecimal totalPrice = null;
				Bundle bundle = orderBundle.getBundle();
				if (ObjectUtils.isValid(bundle)) {

					TaxMapping taxMapData;
					boolean isMonthly = false;
					Set<BundlePriceModel> bundlePriceModels = bundle.getBundlePriceModels();
					BundlePriceModel thisBundleModel = null;
					if (!ObjectUtils.isValid(bundlePriceModels)) {
						throw new RuntimeException("No bundle_price_model found for bundle with ID: "+ bundle.getBundleId());
					}
					if (bundlePriceModels.size() > 1) {
						//Verify that multiple price models must be Rent and Buy
						for (Iterator<BundlePriceModel> ite = bundlePriceModels.iterator(); ite.hasNext();) {
							BundlePriceModel bpm = ite.next();
							int priceModelId = bpm.getPriceModel().getPriceModelId();
							if (priceModelId != FSPConstants.PRICE_MODEL_BUY && priceModelId != FSPConstants.PRICE_MODEL_RENT) {
								throw new RuntimeException("Data integrity error. Too many bundle price models for bundle: " + bundle.getName());
							}
						}
						if (orderBundle.isIsRented()) {
							isMonthly = true;
							taxMapData = bundlePriceModelDAO.getTaxMappingByPriceModelId(bundle.getBundleId(), FSPConstants.PRICE_MODEL_RENT);
						} else {
							isMonthly = false;
							taxMapData = bundlePriceModelDAO.getTaxMappingByPriceModelId(bundle.getBundleId(), FSPConstants.PRICE_MODEL_BUY);
						}
					} else {
						// Assume a single price model, containing the correct tax mapping code
						thisBundleModel = bundlePriceModels.iterator().next();
						switch (thisBundleModel.getPriceModel().getPriceModelId()) {
						case (FSPConstants.PRICE_MODEL_NONE):
							 //Skip the rest of this loop iteration, nothing to tax
							continue;
						case (FSPConstants.PRICE_MODEL_MONTHLY):
							isMonthly = true;
							break;
						case (FSPConstants.PRICE_MODEL_ANNUALLY):
						case (FSPConstants.PRICE_MODEL_ONE_TIME):
						default:
							isMonthly = false;
							break;
						}
						taxMapData = thisBundleModel.getTaxMapping();
					}
					if (isDomestic) {
						if (isMonthly) {
							totalPrice = orderBundle.getMrcTotal();
						} else {
							totalPrice = orderBundle.getOneTimeTotal();
						}
						Integer transId = taxMapData.getBsTransType();
						Integer serviceId = taxMapData.getBsServiceType();
						// Integer transId = 10;
						// Integer serviceId = 15;
						if (transId != null && serviceId != null) {
							// Each unique combination of BillSoft transaction and service codes gets a key
							StringBuilder taxKeyBuilder = new StringBuilder(7).append(transId).append('_').append(serviceId);
							if (isMonthly) {
								taxKeyBuilder.append("_1");
							} else {
								taxKeyBuilder.append("_0");
							}
							String taxKey = taxKeyBuilder.toString();
							TaxTuple curBundleTuple;
							// If we have already mapped this key, add to the total. Otherwise create the new key
							if ((curBundleTuple = taxMap.get(taxKey)) != null) {
								curBundleTuple.setTotalPrice(curBundleTuple.getTotalPrice().add(totalPrice));
							} else {
								curBundleTuple = new TaxTuple(transId.shortValue(), serviceId.shortValue(), totalPrice, isMonthly);
								taxMap.put(taxKey, curBundleTuple);
							}
						}
					} else {
						// International order
						if (isMonthly) {
							mrcTaxTotal += orderBundle.getMrcTotal().doubleValue() * vat;
						} else {
							otTaxTotal += orderBundle.getOneTimeTotal().doubleValue() * vat;
						}
					}
				}
			}
			if (isDomestic) {
				// Spawn a new thread for each entry in the map to make a separate BillSoft request
				Thread[] allThreads = new Thread[taxMap.keySet().size()];
				int i = 0;
				for (TaxTuple groupedTax : taxMap.values()) {
					allThreads[i] = bsService.new EZTaxThread(groupedTax);
					allThreads[i].start();
					i++;
				}
				for (i = 0; i < allThreads.length; i++) {
					allThreads[i].join();
				}
				for (TaxTuple groupedTax : taxMap.values()) {
					if (groupedTax.isMonthly()) {
						mrcTaxTotal += bsService.calcTaxes(groupedTax.getTaxArray());
					} else {
						otTaxTotal += bsService.calcTaxes(groupedTax.getTaxArray());
					}
				}
			}

			// Round the total off to 2 decimal places using BigDecimal
			BigDecimal doublePrecisionMRCTaxTotal = new BigDecimal(mrcTaxTotal);
			doublePrecisionMRCTaxTotal = doublePrecisionMRCTaxTotal.setScale(2, RoundingMode.HALF_EVEN);
			BigDecimal doublePrecisionOTTaxTotal = new BigDecimal(otTaxTotal);
			doublePrecisionOTTaxTotal = doublePrecisionOTTaxTotal.setScale(2, RoundingMode.HALF_EVEN);
			// Write to DB
			orderGroup.setMrcTaxTotal(doublePrecisionMRCTaxTotal);
			orderGroup.setOneTimeTaxTotal(doublePrecisionOTTaxTotal);
			orderGroupDAO.saveOrderGroup(orderGroup);
			// System.err.println("Tax total was " + taxTotal);
			// Reset tax total for next order group
			mrcTaxTotal = 0.00;
			otTaxTotal = 0.00;
		}
	}

	/**
	 * Method to suppress SOAP warnings on console
	 * 
	 */
	private void suppressSoapWarnings() {
		Logger rootLogger = Logger.getLogger("");
		java.util.logging.Handler[] handlers = rootLogger.getHandlers();
		if (handlers.length > 0 && handlers[0] instanceof ConsoleHandler) {
			rootLogger.removeHandler(handlers[0]);
		}

	}

}
