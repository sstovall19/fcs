package com.fonality.service;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Collection;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.logging.ConsoleHandler;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.ws.soap.SOAPFaultException;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionException;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.billsoft.eztaxasp.ArrayOfTaxData;
import com.billsoft.eztaxasp.TaxData;
import com.fonality.billing.DTO.BillableCdrDTO;
import com.fonality.billing.util.BillingFailureHandler;
import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.Bundle;
import com.fonality.bu.entity.BundlePriceModel;
import com.fonality.bu.entity.EntityAddress;
import com.fonality.bu.entity.OrderBundle;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.OrderTransaction;
import com.fonality.bu.entity.OrderTransactionItem;
import com.fonality.bu.entity.Orders;
import com.fonality.bu.entity.TaxMapping;
import com.fonality.bu.entity.TaxTuple;
import com.fonality.dao.BundleDAO;
import com.fonality.dao.BundlePriceModelDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.OrderTransactionDAO;
import com.fonality.dao.OrderTransactionItemDAO;
import com.fonality.util.BillingException;
import com.fonality.util.FSPConstants;
import com.fonality.util.ObjectUtils;

@Service
@Transactional(propagation = Propagation.REQUIRED, rollbackFor = TransactionException.class)
/**
 * Responsible for calculation of taxes and generation of line items for invoices
 * 
 * @author Fonality
 *
 */
public class OrderTransactionLineItemServiceImpl implements OrderTransactionLineItemService {

	private static final int MAX_BS_THREADS = 50; // Maximum number of threads to send to BillSoft at once

	@Autowired
	public OrderGroupDAO orderGroupDAO;

	@Autowired
	public OrderTransactionDAO orderTransactionDAO;

	@Autowired
	public OrderTransactionItemDAO orderTransactionItemDAO;

	@Autowired
	public BundleDAO bundleDAO;

	@Autowired
	private BundlePriceModelDAO bundlePriceModelDAO;

	@Autowired
	public BillingFailureHandler failureHandler;

	private BillSoftService bsService;

	private static final Logger logger = Logger.getLogger(OrderTransactionLineItemServiceImpl.class
			.getName());

	private BigDecimal runningTotal;

	private BillingSchedule schedule = null;

	private Bundle discountLineBundle = null;
	
	@Override
	public boolean calculateTransactionTotal(int orderTransactionId, OrderGroup orderGroup, List<BillableCdrDTO> unboundCdrFiltered, 
			String transactionType) throws InterruptedException, IOException {
		boolean returnVal = false;
		try {
			returnVal = calculateTransactionTotal(orderTransactionId, orderGroup,
					unboundCdrFiltered, transactionType, true); // Switch to false for production
		} catch (BillingException be) {
			failureHandler.notifyBillingFailure(be.getBillingSchedule(), be.getTransactionId(),
					be.getErrorCode(), be.getMessage());
		}
		return returnVal;
	}

	@Override
	public boolean generateTransactionLineItemsForFirstCashSale(int orderTransactionId, OrderGroup orderGroup) throws InterruptedException, IOException {
		return generateTransactionLineItemsForOrder(orderTransactionId, orderGroup, null, FSPConstants.BILLING_PROCESS_ONE_TIME, true);
	}

	@Override
	public boolean calculateTransactionTotal(int orderTransactionId, OrderGroup orderGroup, List<BillableCdrDTO> unboundCdrFiltered, 
			String transactionType, boolean isTestMode) throws InterruptedException, IOException {
		return generateTransactionLineItemsForOrder(orderTransactionId, orderGroup, unboundCdrFiltered, transactionType, isTestMode);
	}

	public boolean generateTransactionLineItemsForOrder(int orderTransactionId, OrderGroup orderGroup, List<BillableCdrDTO> unboundCdrFiltered, 
			String transactionType, boolean isTestMode) throws InterruptedException, IOException {
		boolean status = true;
		boolean processOneTimeCosts = transactionType.equals(FSPConstants.BILLING_PROCESS_ONE_TIME);
		boolean processUsage = transactionType.equals(FSPConstants.BILLING_SCHEDULE_TYPE_SERVICE) || transactionType.equals(FSPConstants.BILLING_SCHEDULE_TYPE_ALL);
		boolean processBundles = transactionType.equals(FSPConstants.BILLING_SCHEDULE_TYPE_SYSTEM) || transactionType.equals(FSPConstants.BILLING_SCHEDULE_TYPE_ALL)
				|| processOneTimeCosts;

		OrderTransaction orderTransaction = orderTransactionDAO.loadOrderTransaction(orderTransactionId);
		if (!ObjectUtils.isValid(orderTransaction)) {
			logger.error("No orderTransaction record found for id " + orderTransactionId);
			throw new BillingException("No orderTransaction record found for id " + orderTransactionId, FSPConstants.DATA_ERROR, null);
		}

		//Pull existing running total, in case this is not the first order group being processed for this order
		runningTotal = orderTransaction.getAmount();
		if (!ObjectUtils.isValid(runningTotal)) {
			runningTotal = new BigDecimal(0.00);
		}
		
		schedule = orderTransaction.getBillingSchedule();

		try {
			suppressSoapWarnings();
			bsService = new BillSoftService(isTestMode);
		} catch (SOAPFaultException | IllegalStateException sfe) {
			logger.error("Unable to initialize BillSoft services.", sfe);
			throw new BillingException("Unable to initialize BillSoft services.", FSPConstants.BILLSOFT_ERROR, schedule);
		}

		Orders originalOrder = orderGroup.getOrders();
		if (!ObjectUtils.isValid(originalOrder)) {
			logger.error("No orders record found for transaction " + orderTransactionId);
			throw new BillingException("No orders record found for transaction " + orderTransactionId, FSPConstants.DATA_ERROR, schedule);
		}

		int interval;
		//If this is a first cash sale, we ignore the interval and charge for one month
		if (processOneTimeCosts)
			interval = 1;
		else
			interval = originalOrder.getBillingIntervalInMonths();
		if (interval < 1) {
			logger.error("Improper interval");
			throw new BillingException("Improper interval: " + interval, FSPConstants.DATA_ERROR, schedule);
		}

		Bundle taxBundle = bundleDAO.getBundleByName(FSPConstants.BUNDLE_NAME_TAX);
		if (!ObjectUtils.isValid(taxBundle)) {
			logger.error("No bundle found with name " + FSPConstants.BUNDLE_NAME_TAX);
			throw new BillingException("No bundle found with name " + FSPConstants.BUNDLE_NAME_TAX, FSPConstants.DATA_ERROR, schedule);
		}

		discountLineBundle = bundleDAO.getBundleByName(FSPConstants.BUNDLE_NAME_LINE_DISCOUNT);

		BigDecimal bigInterval = new BigDecimal(interval); // Convert interval to BigDecimal for ease of calculations

		BSUncaughtExceptionHandler bsHandler = new BSUncaughtExceptionHandler();
		EntityAddress shipAddress = orderGroup.getEntityAddressByShippingAddressId();
		if (!ObjectUtils.isValid(shipAddress)) {
			logger.error("No shipping address found for order group " + orderGroup.getOrderGroupId());
			throw new BillingException("No shipping address found for order group " + orderGroup.getOrderGroupId(), FSPConstants.DATA_ERROR, schedule);
		}
		//Determine whether customer is domestic or international
		String countryISO = shipAddress.getCountry();
		double vat = 0.00;
		boolean isDomestic = false;
		// Domestic (USA) orders will go through BillSoft
		if (FSPConstants.USA_ISO3_CODE.equals(countryISO) || FSPConstants.USA_ISO2_CODE.equals(countryISO)) {
			isDomestic = true;
			// Set jurisdiction for all upcoming BS requests
			bsService.generatePCode(shipAddress);
		}
		
		HashMap<String, TaxTuple> taxMap = new HashMap<String, TaxTuple>();

		// Instantiate structures used by both usage and MRC calculations
		HashMap<Integer, OrderTransactionItem> bsTaxTypeMap = new HashMap<Integer, OrderTransactionItem>();

		if (processUsage) {
			Bundle faxBundle = bundleDAO.getBundleByName(FSPConstants.BUNDLE_NAME_FAX);
			if (!ObjectUtils.isValid(faxBundle)) {
				logger.error("No bundle found with name " + FSPConstants.BUNDLE_NAME_FAX);
				throw new BillingException("No bundle found with name " + FSPConstants.BUNDLE_NAME_FAX, FSPConstants.DATA_ERROR, schedule);
			}
			// Find all usage bundles - Amounts are already set
			Set<OrderTransactionItem> lineItems = orderTransaction.getOrderTransactionItems();
			for (OrderTransactionItem usageItem : lineItems) {

				BigDecimal usageFee = usageItem.getAmount();
				runningTotal = runningTotal.add(usageFee);
				// Calculate taxes on Fax usage only, other usage will be taxed by call below
				if (isDomestic) {
					if (usageItem.getBundle().getBundleId().equals(faxBundle.getBundleId())) {
						Set<BundlePriceModel> priceModelSet = faxBundle.getBundlePriceModels();
						// Should be guaranteed to have exactly one price model associated with a usage bundle
						TaxMapping taxMapData = priceModelSet.iterator().next().getTaxMapping();
						Integer transId = taxMapData.getBsTransType();
						Integer serviceId = taxMapData.getBsServiceType();
						TaxTuple curBundleTuple = new TaxTuple(transId.shortValue(), serviceId.shortValue(), usageFee);
						try {
							bsService.queryTaxData(curBundleTuple);
						} catch (DatatypeConfigurationException | IOException bse) {
							logger.error("Tax calculation failure for fax usage", bse);
							throw new BillingException("Tax calculation failure for fax usage", FSPConstants.BILLSOFT_ERROR, schedule);
						}
						if (!updateTaxItemMap(bsTaxTypeMap, curBundleTuple, taxBundle, orderTransaction, orderGroup)) {
							return false;
						}
					}
				}
			}

			// Calculate taxes on usage
			if (isDomestic) {
				HashMap<String, TaxMapping> taxTypeMap = new HashMap<String, TaxMapping>(10, 1);
				// Loop through entity list(s), creating usage tuples by call
				List<TaxTuple> usageList = new ArrayList<TaxTuple>();
				for (BillableCdrDTO call : unboundCdrFiltered) {
	
					// Determine tax category of call
					String callType = call.getCallType();
					char internationalFlag = call.getInternational() ? '1' : '0';
					String taxTypeKey = new StringBuilder(13).append(callType).append('_').append(internationalFlag).toString();
					// At this point we assume all standard and mobile call are international. This algorithm will need to 
					// change when we start charging for domestic calls
					TaxMapping thisBundleMap = taxTypeMap.get(callType);
					if (thisBundleMap == null) {
						String bundleName = null;
						switch (callType) {
						case FSPConstants.UNBOUND_CDR_CALL_TYPE_TOLLFREE:
							bundleName = FSPConstants.BUNDLE_TOLLFREE_USAGE;
							break;
						case FSPConstants.UNBOUND_CDR_CALL_TYPE_STANDARD:
							bundleName = FSPConstants.BUNDLE_INTERNATIONAL_STD_USAGE;
							break;
						case FSPConstants.UNBOUND_CDR_CALL_TYPE_MOBILE:
							bundleName = FSPConstants.BUNDLE_INTERNATIONAL_MOBILE_USAGE;
							break;
						case FSPConstants.UNBOUND_CDR_CALL_TYPE_EMERGENCY:
							bundleName = FSPConstants.BUNDLE_EMERGENCY_USAGE;
							break;
						case FSPConstants.UNBOUND_CDR_CALL_TYPE_PREMIUM:
							bundleName = FSPConstants.BUNDLE_PREMIUM_USAGE;
							break;
						default:
							bundleName = FSPConstants.BUNDLE_INTERNATIONAL_STD_USAGE; // We should never hit this case
							logger.warn("Invalid or null call type found for transaction " + orderTransactionId + ". Defaulting to International Usage.");
						}
						Bundle usageBundle = bundleDAO.getBundleByName(bundleName);
						if (!ObjectUtils.isValid(usageBundle)) {
							logger.error("Data error - No bundle found with name '" + bundleName + "'");
							throw new BillingException("No bundle found with name '" + bundleName + "'", FSPConstants.DATA_ERROR, schedule);
						}
						Set<BundlePriceModel> priceModels = usageBundle.getBundlePriceModels();
						if (!ObjectUtils.isValid(priceModels)) {
							logger.error("Data error - No price model(s) found for bundle '" + bundleName + "'");
							throw new BillingException("No price model(s) found for bundle '"
									+ bundleName + "'", FSPConstants.DATA_ERROR, schedule);
						}
						thisBundleMap = priceModels.iterator().next().getTaxMapping();
						taxTypeMap.put(callType, thisBundleMap);
					}
					Integer transId = thisBundleMap.getBsTransType();
					Integer serviceId = thisBundleMap.getBsServiceType();
					TaxTuple curCallTuple = new TaxTuple(transId.shortValue(), serviceId.shortValue(),
							new BigDecimal(call.getCustomerBilledAmount()));
					GregorianCalendar callDate = new GregorianCalendar();
					callDate.setTime(call.getCalldate());
					curCallTuple.setDate(callDate);
					usageList.add(curCallTuple);
	
				}
//				long startTime = System.currentTimeMillis();
				// Make calls to BS by tuple - Divide usage records into batches for multithreading
				int lastIndex = usageList.size() - 1;
				int batchCount = usageList.size() / MAX_BS_THREADS + (usageList.size() % MAX_BS_THREADS == 0 ? 0 : 1);
				for (int i = 0; i < batchCount; i++) {
					int startIndex = i * MAX_BS_THREADS;
					int endIndex = ((i + 1) * MAX_BS_THREADS) - 1;
					if (endIndex > lastIndex)
						endIndex = lastIndex;
					int batchSize = endIndex - startIndex + 1;
					Thread[] curBatchThreads = new Thread[batchSize];
					for (int k = 0; k < batchSize; k++) {
						TaxTuple callToTax = usageList.get(startIndex + k);
						curBatchThreads[k] = bsService.new UsageTaxThread(callToTax);
						curBatchThreads[k].setUncaughtExceptionHandler(bsHandler);
						curBatchThreads[k].start();
					}
					for (int k = 0; k < curBatchThreads.length; k++) {
						curBatchThreads[k].join();
					}
				}
				long stopTime = System.currentTimeMillis();
//				System.out.println("Usage taxation calculation took " + (stopTime - startTime) + " millis");
				if (!updateTaxItemMap(bsTaxTypeMap, usageList, taxBundle, orderTransaction, orderGroup))
					return false; // We do not want to update the DB if we had a failure here
//				System.out.println("Taxation aggregation took took " + (System.currentTimeMillis() - stopTime) + " millis");
			} //End isDomestic block
		}
		
		if (processBundles) {
			// Create line items for monthly (and possibly one-time) charges and calculate taxes for same
			boolean isMRC;
			boolean isNoPriceModel;
			Set<OrderBundle> orderBundleSet = orderGroup.getOrderBundles();
			for (OrderBundle orderBundle : orderBundleSet) {
				isNoPriceModel = false;
				TaxMapping taxMapData;
				Bundle bundle = orderBundle.getBundle();
				Set<BundlePriceModel> bundlePriceModels = bundle.getBundlePriceModels();
				BundlePriceModel thisBundleModel = null;
				if (!ObjectUtils.isValid(bundlePriceModels)) {
					throw new BillingException("No bundle price model found for bundle: " + bundle.getName(), FSPConstants.DATA_ERROR, schedule);
				}
				if (bundlePriceModels.size() > 1) {
					//Verify that multiple price models must be Rent and Buy
					for (Iterator<BundlePriceModel> ite = bundlePriceModels.iterator(); ite.hasNext();) {
						BundlePriceModel bpm = ite.next();
						int priceModelId = bpm.getPriceModel().getPriceModelId();
						if (priceModelId != FSPConstants.PRICE_MODEL_BUY && priceModelId != FSPConstants.PRICE_MODEL_RENT) {
							throw new BillingException("Data integrity error. Too many bundle price models for bundle: "
									+ bundle.getName(), FSPConstants.DATA_ERROR, schedule);						
						}
					}
					if (orderBundle.isIsRented()) {
						isMRC = true;
						taxMapData = bundlePriceModelDAO.getTaxMappingByPriceModelId(bundle.getBundleId(), FSPConstants.PRICE_MODEL_RENT);
					} else {
						isMRC = false;
						taxMapData = bundlePriceModelDAO.getTaxMappingByPriceModelId(bundle.getBundleId(), FSPConstants.PRICE_MODEL_BUY);
					}
				} else {
					// Assume a single price model, containing the correct tax mapping code
					thisBundleModel = bundlePriceModels.iterator().next();
					switch (thisBundleModel.getPriceModel().getPriceModelId()) {
					case (FSPConstants.PRICE_MODEL_NONE):
						isMRC = false;
						isNoPriceModel = true;
						break;
					case (FSPConstants.PRICE_MODEL_MONTHLY):
						isMRC = true;
						break;
					case (FSPConstants.PRICE_MODEL_ANNUALLY):
					case (FSPConstants.PRICE_MODEL_ONE_TIME):
					default:
						isMRC = false;
						throw new BillingException("Data integrity error. Improper bundle price model associated with bundle: "
								+ bundle.getName(), FSPConstants.DATA_ERROR, schedule);
					}
					taxMapData = thisBundleModel.getTaxMapping();
				}
				if ((isMRC || processOneTimeCosts) && !isNoPriceModel) {
					if (!ObjectUtils.isValid(taxMapData)) {
						logger.error("Data error - No tax mapping found for order bundle " + orderBundle.getOrderBundleId());
						throw new BillingException("No tax mapping found for order bundle " + orderBundle.getOrderBundleId(), 
								FSPConstants.DATA_ERROR, schedule);
					}
					
					BigDecimal bundleCost;
					if (isMRC) {
						bundleCost = orderBundle.getMrcTotal();
					} else {
						bundleCost = orderBundle.getOneTimeTotal();
					}
					BigDecimal intervalCharge = bundleCost.multiply(bigInterval);
					runningTotal = runningTotal.add(intervalCharge);
					// Create line item
					OrderTransactionItem billingItem = new OrderTransactionItem();
					billingItem.setAmount(intervalCharge);
					billingItem.setBundle(bundle);
					billingItem.setDescription(bundle.getDescription());
					billingItem.setOrderTransaction(orderTransaction);
					billingItem.setMonthlyUsage(0);
					billingItem.setOrderGroup(orderGroup);
					Long netsuiteId;
					if (isMRC) {
						netsuiteId = bundle.getNetsuiteMrcId();
						if (!ObjectUtils.isValid(netsuiteId)) {
							logger.error("Data error - No NetSuite MRC Id for bundle " + bundle.getBundleId());
							throw new BillingException("No NetSuite MRC Id for bundle " + bundle.getBundleId(),  FSPConstants.DATA_ERROR, schedule);
						}
					} else {
						netsuiteId = bundle.getNetsuiteOneTimeId();
						if (!ObjectUtils.isValid(netsuiteId)) {
							logger.error("Data error - No NetSuite one-time Id for bundle " + bundle.getBundleId());
							throw new BillingException("No NetSuite Id for bundle " + bundle.getBundleId(),  FSPConstants.DATA_ERROR, schedule);
						}
					}
					billingItem.setNetsuiteItemId(netsuiteId);
					billingItem.setQuantity(orderBundle.getQuantity());
					billingItem.setListPrice(orderBundle.getListPrice());
					orderTransactionItemDAO.saveOrderTransactionItem(billingItem);

					// Create tax tuple
					if (isDomestic) {
						if (intervalCharge.compareTo(BigDecimal.ZERO) > 0) {
							Integer transId = taxMapData.getBsTransType();
							Integer serviceId = taxMapData.getBsServiceType();
							String taxKey = new StringBuilder(5).append(transId).append('_').append(serviceId).toString();
							TaxTuple curBundleTuple;
							// If we have already mapped this key, add to the total. Otherwise create the new key
							if ((curBundleTuple = taxMap.get(taxKey)) != null) {
								curBundleTuple.setTotalPrice(curBundleTuple.getTotalPrice().add(intervalCharge));
							} else {
								curBundleTuple = new TaxTuple(transId.shortValue(), serviceId.shortValue(), intervalCharge);
								taxMap.put(taxKey, curBundleTuple);
							}
						}
					}
					//Add a discount line item if applicable
					OrderTransactionItem discountItem = generateDiscountLineItemForBundle(orderBundle, orderTransaction, 
							billingItem, orderGroup);
					if (netsuiteId != 0 && ObjectUtils.isValid(discountItem)) { //Change me!
						orderTransactionItemDAO.saveOrderTransactionItem(discountItem);
						runningTotal = runningTotal.add(discountItem.getAmount());
					}
				}
			}

			// Create line items for taxation
			if (isDomestic) {
				// Make BillSoft calls in multithreaded fashion.
				// Spawn a new thread for each entry in the map to make a separate BillSoft request
				Thread[] allThreads = new Thread[taxMap.keySet().size()];
				int i = 0;
				for (TaxTuple groupedTax : taxMap.values()) {
					allThreads[i] = bsService.new EZTaxThread(groupedTax);
					allThreads[i].setUncaughtExceptionHandler(bsHandler);
					allThreads[i].start();
					i++;
				}
				for (i = 0; i < allThreads.length; i++) {
					allThreads[i].join();
				}
				if (!updateTaxItemMap(bsTaxTypeMap, taxMap.values(), taxBundle, orderTransaction, orderGroup))
					return false; // We do not want to update the DB if we had a failure here
			}
			
		} // End processMRC block

		if (isDomestic) {
			// Loop through each of these new line items, adding them to the DB
			for (OrderTransactionItem taxItem : bsTaxTypeMap.values()) {
				orderTransactionItemDAO.saveOrderTransactionItem(taxItem);
			}
		}
		logger.debug("Processed " + bsTaxTypeMap.size() + " tax categories.");

		if (runningTotal.compareTo(BigDecimal.ZERO) < 0) {
			logger.error("Illegal invoice value " + runningTotal.toString() + ". Invoice total cannot be less than 0.00");
			failureHandler.notifyBillingFailure(schedule, null, FSPConstants.DATA_ERROR, "Illegal invoice value " 
											+ runningTotal.toString() + ". Invoice total cannot be less than 0.00");
			return false;
		}
		orderTransaction.setAmount(runningTotal);
		orderTransactionDAO.saveOrderTransaction(orderTransaction);
		return status;
	}

	private class BSUncaughtExceptionHandler implements Thread.UncaughtExceptionHandler {

		@Override
		public void uncaughtException(Thread t, Throwable e) {
			logger.error("Tax calculation thread failure", e);
			throw new BillingException("Tax calculation thread failure", FSPConstants.BILLSOFT_ERROR, schedule);
		}
	}

	/**
	 * Adds taxation data to a single repository of tax data, grouped by type, that can later be
	 * used to generate line items. We also update the running total here for the sake of
	 * convenience.
	 * 
	 * @param taxLineItemMap
	 *            The repository of taxation line items
	 * @param groupedTaxes
	 *            A collection of TaxTuples that contain BillSoft taxation data
	 * @param taxBundle
	 *            The sales_tax_and_regulatory_fees bundle record
	 * @param allParent
	 *            The parent OrderTransaction of all line items being created
	 * @return True if all tax arrays are valid, false otherwise
	 */
	private boolean updateTaxItemMap(HashMap<Integer, OrderTransactionItem> taxLineItemMap,
			Collection<TaxTuple> groupedTaxes, Bundle taxBundle, OrderTransaction allParent, OrderGroup orderGroup) {
		int i = 0;
		for (TaxTuple groupedTax : groupedTaxes) {
			if (!updateTaxItemMap(taxLineItemMap, groupedTax, taxBundle, allParent, orderGroup)) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Adds taxation data to a single repository of tax data, grouped by type, that can later be
	 * used to generate line items. We also update the running total here for the sake of
	 * convenience.
	 * 
	 * @param taxLineItemMap
	 *            The repository of taxation line items
	 * @param groupedTax
	 *            A TaxTuple record containing BillSoft taxation data
	 * @param taxBundle
	 *            The sales_tax_and_regulatory_fees bundle record
	 * @param allParent
	 *            The parent OrderTransaction of all line items being created
	 * @return True if the tax array is valid, false otherwise
	 */
	private boolean updateTaxItemMap(HashMap<Integer, OrderTransactionItem> taxLineItemMap,
			TaxTuple groupedTax, Bundle taxBundle, OrderTransaction allParent, OrderGroup orderGroup) {
		// Create line item for each unique tax type
		ArrayOfTaxData taxArray = groupedTax.getTaxArray();
		// TaxArray will be null if the BillSoft call failed. We need to handle that here.
		if (ObjectUtils.isValid(taxArray)) {
			for (TaxData oneTaxElement : taxArray.getTaxData()) {
				int taxCode = oneTaxElement.getTaxType();
				runningTotal = runningTotal.add(new BigDecimal(oneTaxElement.getTaxAmount()));
				OrderTransactionItem taxLineItem;
				// Based on tax code, update existing line item or create new
				if ((taxLineItem = taxLineItemMap.get(taxCode)) != null) {
					taxLineItem.setAmount(taxLineItem.getAmount().add(new BigDecimal(oneTaxElement.getTaxAmount())));
				} else {
					taxLineItem = new OrderTransactionItem();
					taxLineItem.setAmount(new BigDecimal(oneTaxElement.getTaxAmount()));
					taxLineItem.setBundle(taxBundle);
					taxLineItem.setDescription(oneTaxElement.getDescription().getValue());
					taxLineItem.setOrderTransaction(allParent);
					taxLineItem.setMonthlyUsage(0);
					if (taxBundle.getNetsuiteOneTimeId() == null)
						logger.error("Data error - No NetSuite one-time Id for bundle " + taxBundle.getBundleId());
					else
						taxLineItem.setNetsuiteItemId(taxBundle.getNetsuiteOneTimeId());
					taxLineItem.setOrderGroup(orderGroup);
					taxLineItem.setListPrice(BigDecimal.ZERO);
					taxLineItem.setQuantity(1);
					taxLineItemMap.put(taxCode, taxLineItem);
				}
			}
		} else {
			logger.error("Null tax array found, indicating BillSoft communication failure");
			throw new BillingException("Null tax array found, indicating BillSoft communication failure", FSPConstants.BILLSOFT_ERROR, schedule);
		}
		return true;

	}

	/**
	 * Suppresses SOAP warnings on console
	 */
	private void suppressSoapWarnings() {
		java.util.logging.Logger rootLogger = java.util.logging.Logger.getLogger("");
		java.util.logging.Handler[] handlers = rootLogger.getHandlers();
		if (handlers.length > 0 && handlers[0] instanceof ConsoleHandler) {
			rootLogger.removeHandler(handlers[0]);
		}

	}

	/**
	 * Locates the tax mapping record for a given order bundle based on the associated bundle record
	 * 
	 * @param orderBundle
	 *            The order bundle record for which to find the tax mapping
	 * @return The TaxMapping record, or null if none are found
	 */
	private TaxMapping getTaxMappingFromBundle(OrderBundle orderBundle) {
		TaxMapping taxMapData;
		Bundle bundle = orderBundle.getBundle();
		Set<BundlePriceModel> bundlePriceModels = bundle.getBundlePriceModels();
		BundlePriceModel thisBundleModel = null;
		if (!ObjectUtils.isValid(bundlePriceModels)) {
			return null;
		}
		if (bundlePriceModels.size() > 1) {
			// Assume for now that multiple price models must be Rent and Buy
			if (orderBundle.isIsRented()) {
				taxMapData = bundlePriceModelDAO.getTaxMappingByPriceModelId(bundle.getBundleId(), FSPConstants.PRICE_MODEL_RENT);
			} else {
				taxMapData = bundlePriceModelDAO.getTaxMappingByPriceModelId(bundle.getBundleId(), FSPConstants.PRICE_MODEL_BUY);
			}
		} else {
			// Assume a single price model, containing the correct tax mapping code
			thisBundleModel = bundlePriceModels.iterator().next();
			taxMapData = thisBundleModel.getTaxMapping();
		}

		return taxMapData;
	}

	/**
	 * Creates a new discount line item for an upcoming invoice, using the pricing data stored in an
	 * order bundle
	 * 
	 * @param orderBundle
	 *            The order bundle for which a discount was applied
	 * @param orderTransaction
	 *            The order transaction to which the discount line item will be added
	 * @return The discount line item, or null if no discount applies
	 */
	public OrderTransactionItem generateDiscountLineItemForBundle(OrderBundle orderBundle,
			OrderTransaction orderTransaction, OrderTransactionItem parentItem, OrderGroup orderGroup) {
		OrderTransactionItem discountLine;
		//Check whether a discount applies
		BigDecimal discountedPrice = orderBundle.getDiscountedPrice();
		BigDecimal listPrice = orderBundle.getListPrice();
		if (listPrice.compareTo(discountedPrice) > 0) {
			discountLine = new OrderTransactionItem();
			BigDecimal discountAmount = discountedPrice.add(listPrice.negate());
			BigDecimal totalDiscount = discountAmount.multiply(new BigDecimal(orderBundle.getQuantity()));
			discountLine.setListPrice(totalDiscount);
			discountLine.setAmount(totalDiscount);
			discountLine.setOrderTransaction(orderTransaction);
			discountLine.setOrderTransactionItem(parentItem);
			discountLine.setOrderGroup(orderGroup);
			discountLine.setBundle(discountLineBundle);
			discountLine.setNetsuiteItemId(discountLineBundle.getNetsuiteMrcId());
			discountLine.setDescription(orderBundle.getBundle().getDisplayName() + " : Line Discount");
			discountLine.setQuantity(1);
		} else {
			discountLine = null;
		}

		return discountLine;
	}

}
