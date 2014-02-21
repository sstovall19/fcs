package com.fonality.test.service;

import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.billing.DTO.BillableCdrDTO;
import com.fonality.bu.entity.OrderBundle;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.OrderTransaction;
import com.fonality.bu.entity.PaymentMethod;
import com.fonality.dao.AddressDAO;
import com.fonality.dao.BundleDAO;
import com.fonality.dao.OrderBundleDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.OrderTransactionDAO;
import com.fonality.dao.PaymentMethodDAO;
import com.fonality.dao.ProductDAO;
import com.fonality.dao.TaxMappingDAO;
import com.fonality.service.OrderTransactionLineItemService;
import com.fonality.util.FSPConstants;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestTaxCalculationService extends AbstractTransactionalJUnit4SpringContextTests {

	@Autowired
	public OrderTransactionLineItemService taxCalcService;

	@Autowired
	public OrderTransactionDAO orderTransactionDAO;

	@Autowired
	public PaymentMethodDAO paymentMethodDAO;

	@Autowired
	public OrderGroupDAO orderGroupDAO;

	@Autowired
	public BundleDAO bundleDAO;

	@Autowired
	public OrderDAO orderDAO;

	@Autowired
	public AddressDAO addressDAO;

	@Autowired
	public ProductDAO productDAO;

	@Autowired
	public OrderBundleDAO orderBundleDAO;

	@Autowired
	public TaxMappingDAO taxMappingDAO;

	@Autowired
	public OrderTransactionLineItemService taxCalculatorService;

	@Test
	public void testTaxCalculation() throws InterruptedException, IOException {

		// Create test order group and associated bundles
		OrderGroup orderGroup1 = new OrderGroup();
		orderGroup1.setOrders(orderDAO.loadOrder(1));
		orderGroup1.setServerId(0);
		orderGroup1.setEntityAddressByBillingAddressId(addressDAO.loadAddress(20000));
		orderGroup1.setProduct(productDAO.loadProduct(7));
		orderGroup1.setOneTimeTotal(new BigDecimal(368.00));
		orderGroup1.setOneTimeTaxTotal(new BigDecimal(0));
		//orderGroup1.setDiscountAmount(new BigDecimal(0.00));
		orderGroup1.setMrcTaxTotal(new BigDecimal(0.00));
		orderGroup1.setMrcTotal(new BigDecimal(368.00));
		orderGroup1.setEntityAddressByShippingAddressId(addressDAO.loadAddress(1));

		orderGroupDAO.saveOrderGroup(orderGroup1);

		OrderBundle orderBundle1 = new OrderBundle();
		orderBundle1.setBundle(bundleDAO.loadBundle(1));
		orderBundle1.setIsRented(true);
		orderBundle1.setListPrice(new BigDecimal(100.00));
		orderBundle1.setMrcTotal(new BigDecimal(100.00));
		orderBundle1.setOneTimeTotal(new BigDecimal(0.00));
		orderBundle1.setOrderGroup(orderGroup1);
		orderBundle1.setQuantity(1);
		//orderBundle1.setUnitPrice(new BigDecimal(100.00));
		orderBundle1.setDiscountedPrice(BigDecimal.ZERO);
		orderBundleDAO.saveOrderBundle(orderBundle1);

		OrderBundle orderBundle2 = new OrderBundle();
		orderBundle2.setBundle(bundleDAO.loadBundle(54));
		orderBundle2.setIsRented(true);
		orderBundle2.setListPrice(new BigDecimal(100.00));
		orderBundle2.setMrcTotal(new BigDecimal(100.00));
		orderBundle2.setOneTimeTotal(new BigDecimal(0.00));
		orderBundle2.setOrderGroup(orderGroup1);
		orderBundle2.setQuantity(1);
		//orderBundle2.setUnitPrice(new BigDecimal(100.00));
		orderBundle2.setDiscountedPrice(BigDecimal.ZERO);
		orderBundleDAO.saveOrderBundle(orderBundle2);

		Set<OrderBundle> orderBundleSet = new HashSet<OrderBundle>();
		orderBundleSet.add(orderBundle1);
		orderBundleSet.add(orderBundle2);
		orderGroup1.setOrderBundles(orderBundleSet);
		orderGroupDAO.saveOrderGroup(orderGroup1);

		// Generate initial OrderTransaction
		OrderTransaction testTrans = new OrderTransaction();
		testTrans.setCustomerId(1);
		testTrans.setOrderGroup(orderGroup1);
		testTrans.setServerId(1);
		testTrans.setType(FSPConstants.CASHSALE_TRANSACTION_TYPE);
		testTrans.setAmount(new BigDecimal(0.00));
		testTrans.setStatus(FSPConstants.ORDER_TRANSACTION_STATUS_NOT_PROCESSED);
		// Payment method is required
		PaymentMethod paymentMethod = paymentMethodDAO.loadPaymentMethod(1);
		testTrans.setPaymentMethod(paymentMethod);

		orderTransactionDAO.saveOrderTransaction(testTrans);

		// Generate initial UnboundCDRTest list
		List<BillableCdrDTO> cdrList = new ArrayList<BillableCdrDTO>();
		BillableCdrDTO call1 = new BillableCdrDTO();
		call1.setAni("81370443712");
		// call1.setAni("7039883511");
		call1.setBillableDuration(100);
		call1.setCalldate(new Date());
		call1.setCallType("tollfree");
		call1.setCustomerBilledAmount(5.00f);
		call1.setDialedNumber("17036361920");
		call1.setDid("8887199914");
		// call1.setDid("12022447525");
		call1.setDirection("inbound");
		call1.setServerId(0);
		call1.setInternational(false);
		cdrList.add(call1);

		BillableCdrDTO call2 = new BillableCdrDTO();
		call2.setAni("2025692814");
		call2.setBillableDuration(100);
		call2.setCalldate(new Date());
		call2.setCallType("standard");
		call2.setCustomerBilledAmount(5.00f);
		call2.setDialedNumber("17036361920");
		call2.setDid("7036596165");
		call2.setDirection("outbound");
		call2.setServerId(0);
		call2.setInternational(false);
		cdrList.add(call2);

		long startTime = System.currentTimeMillis();
		// Call calculateTransactionTotal, forcing it into test mode
		boolean status = taxCalculatorService.calculateTransactionTotal(
				testTrans.getOrderTransactionId(), orderGroup1, cdrList, FSPConstants.BILLING_SCHEDULE_TYPE_ALL,
				true);
		long totalTime = System.currentTimeMillis() - startTime;
		//System.out.println("Total time was " + totalTime + " milliseconds");
		// Assert return code is true
		assertTrue(status);

		OrderTransaction resultTrans = orderTransactionDAO.loadOrderTransaction(testTrans
				.getOrderTransactionId());
		//System.out.println("Amount = " + resultTrans.getAmount().doubleValue());
		// System.out.println("Id is " + testTrans.getOrderTransactionId());
		orderTransactionDAO.deleteOrderTransaction(testTrans);
		orderBundleDAO.deleteOrderBundle(orderBundle1);
		orderBundleDAO.deleteOrderBundle(orderBundle2);
		orderGroupDAO.deleteOrderGroup(orderGroup1);
	}
}
