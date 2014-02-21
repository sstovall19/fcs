package com.fonality.test.service;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.HashSet;
import java.util.Set;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.OrderTransaction;
import com.fonality.bu.entity.OrderTransactionItem;
import com.fonality.bu.entity.Orders;
import com.fonality.dao.AddressDAO;
import com.fonality.dao.BillingScheduleDAO;
import com.fonality.dao.BundleDAO;
import com.fonality.dao.ContactDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.OrderTransactionDAO;
import com.fonality.dao.OrderTransactionItemDAO;
import com.fonality.dao.PaymentMethodDAO;
import com.fonality.dao.ProductDAO;
import com.fonality.service.InvoiceService;
import com.fonality.util.DateUtils;
import com.fonality.util.FSPConstants;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestInvoiceService extends AbstractTransactionalJUnit4SpringContextTests {

	@Autowired
	public InvoiceService invoiceService;

	@Autowired
	public OrderTransactionDAO orderTransactionDAO;

	@Autowired
	public OrderTransactionItemDAO orderTransactionItemDAO;

	@Autowired
	public OrderDAO orderDAO;

	@Autowired
	public BundleDAO bundleDAO;

	@Autowired
	public ProductDAO productDAO;

	@Autowired
	public ContactDAO contactDAO;

	@Autowired
	public AddressDAO addressDAO;

	@Autowired
	public OrderGroupDAO orderGroupDAO;

	@Autowired
	public PaymentMethodDAO paymentMethodDAO;

	@Autowired
	public BillingScheduleDAO billingScheduleDAO;

	@Rollback(true)
	@Test
	public void testCreateInvoiceSingle() {

		Orders newOrder = new Orders();
		newOrder.setCreated(new Timestamp(System.currentTimeMillis()));
		newOrder.setOneTimeTotal(new BigDecimal(368.00));
		newOrder.setOrderType("NEW");
		newOrder.setRecordType("ORDER");
		//newOrder.setDiscountAmount(new BigDecimal(0.00));
		//newOrder.setDiscountPercent(new BigDecimal(0.00));
		newOrder.setPrepayAmount(BigDecimal.ZERO);
		newOrder.setMrcTotal(new BigDecimal(398.00));
		newOrder.setPrepayAmount(new BigDecimal(0.00));
		newOrder.setApprovalComment("Test Approval Comment");
		newOrder.setContractBalance(new BigDecimal(398.00));
		newOrder.setCompanyName("Test Company");
		newOrder.setEntityContact(contactDAO.loadContact(1));
		newOrder.setIndustry("Test");
		newOrder.setNote("Test order created from JUnit");
		newOrder.setWebsite("Test Wbesite");
		newOrder.setCustomerId(29179);
		newOrder.setContractStartDate(DateUtils.formatDate("12/02/2012", DateUtils.USA_DATETIME));
		newOrder.setTermInMonths(12);

		Orders order = orderDAO.saveOrder(newOrder);
		assertNotNull(order);

		OrderGroup orderGroup = new OrderGroup();
		orderGroup.setOrders(order);
		orderGroup.setServerId(19075);
		orderGroup.setEntityAddressByBillingAddressId(addressDAO.loadAddress(20000));
		orderGroup.setProduct(productDAO.loadProduct(7));
		orderGroup.setOneTimeTotal(new BigDecimal(368.00));
		orderGroup.setOneTimeTaxTotal(new BigDecimal(0));
		//orderGroup.setDiscountAmount(new BigDecimal(0.00));
		orderGroup.setMrcTaxTotal(new BigDecimal(0.00));
		orderGroup.setMrcTotal(new BigDecimal(368.00));
		orderGroup.setNetsuiteSalesOrderId(Long.valueOf(1152798));

		orderGroup.setEntityAddressByShippingAddressId(addressDAO.loadAddress(20000));

		orderGroupDAO.saveOrderGroup(orderGroup);
		assertNotNull(orderGroup);

		//BillingSchedule billingSchedule = billingScheduleDAO.loadBuillingSchedule(7);

		BillingSchedule newSched = new BillingSchedule();
		newSched.setCustomerId(order.getCustomerId());
		newSched.setStartDate(DateUtils.formatDate("09/01/2012", DateUtils.USA_DATETIME));
		newSched.setOrders(order);
		newSched.setPaymentMethod(paymentMethodDAO.loadPaymentMethod(4));
		newSched.setEndDate(DateUtils.formatDate("10/31/2012", DateUtils.USA_DATETIME));
		newSched.setStatus(FSPConstants.BILLING_SCHEDULE_STATUS_NOT_PROCESSED);
		newSched.setType(FSPConstants.BILLING_SCHEDULE_TYPE_ALL);
		BillingSchedule schedule = billingScheduleDAO.saveBillingSchedule(newSched);

		OrderTransaction orderTransaction = new OrderTransaction();
		orderTransaction.setOrderGroup(orderGroup);
		orderTransaction.setCustomerId(schedule.getCustomerId());
		orderTransaction.setType(FSPConstants.CASHSALE_TRANSACTION_TYPE);
		orderTransaction.setAmount(new BigDecimal(1111.00));
		orderTransaction.setCreated(new Timestamp(System.currentTimeMillis()));
		orderTransaction.setBillingSchedule(schedule);
		orderTransaction.setPaymentMethod(paymentMethodDAO.loadPaymentMethod(4));
		orderTransaction.setStatus(FSPConstants.ORDER_TRANSACTION_STATUS_NOT_PROCESSED);
		orderTransaction = orderTransactionDAO.saveOrderTransaction(orderTransaction);
		assertNotNull(orderTransactionDAO.loadOrderTransaction(orderTransaction
				.getOrderTransactionId()));

		OrderTransactionItem orderTransactionItem1 = new OrderTransactionItem();
		orderTransactionItem1.setOrderTransaction(orderTransaction);
		orderTransactionItem1.setOrderGroup(orderGroup);
		orderTransactionItem1.setBundle(this.bundleDAO.loadBundle(42));
		orderTransactionItem1.setDescription("Polycom SoundPoint IP 331 phone");
		orderTransactionItem1.setAmount(new BigDecimal(200.0));
		orderTransactionItem1.setMonthlyUsage(223);
		orderTransactionItem1.setNetsuiteItemId(2610);
		orderTransactionItem1.setListPrice(BigDecimal.ZERO);

		OrderTransactionItem orderTransactionItem2 = new OrderTransactionItem();
		orderTransactionItem2.setOrderTransaction(orderTransaction);
		orderTransactionItem2.setOrderGroup(orderGroup);
		orderTransactionItem2.setBundle(this.bundleDAO.loadBundle(100));
		orderTransactionItem2.setDescription("International Minutes Usage");
		orderTransactionItem2.setAmount(new BigDecimal(23.0));
		orderTransactionItem2.setMonthlyUsage(11);
		orderTransactionItem2.setNetsuiteItemId(3240);
		orderTransactionItem2.setListPrice(BigDecimal.ZERO);

		OrderTransactionItem orderTransactionItem3 = new OrderTransactionItem();
		orderTransactionItem3.setOrderTransaction(orderTransaction);
		orderTransactionItem3.setOrderGroup(orderGroup);
		orderTransactionItem3.setBundle(this.bundleDAO.loadBundle(102));
		orderTransactionItem3.setDescription("Fax Pages Usage");
		orderTransactionItem3.setAmount(new BigDecimal(20.0));
		orderTransactionItem3.setMonthlyUsage(0);
		orderTransactionItem3.setNetsuiteItemId(3240);
		orderTransactionItem3.setListPrice(BigDecimal.ZERO);

		OrderTransactionItem orderTransactionItem4 = new OrderTransactionItem();
		orderTransactionItem4.setOrderTransaction(orderTransaction);
		orderTransactionItem4.setOrderGroup(orderGroup);
		orderTransactionItem4.setBundle(this.bundleDAO.loadBundle(190));
		orderTransactionItem4.setDescription("Downpayment from Pre-Pay (first month only)");
		orderTransactionItem4.setAmount(new BigDecimal(50.0));
		orderTransactionItem4.setMonthlyUsage(0);
		orderTransactionItem4.setNetsuiteItemId(4314);
		orderTransactionItem4.setListPrice(BigDecimal.ZERO);

		orderTransactionItemDAO.saveOrderTransactionItem(orderTransactionItem1);
		assertNotNull(orderTransactionItem1);

		orderTransactionItemDAO.saveOrderTransactionItem(orderTransactionItem2);
		assertNotNull(orderTransactionItem2);

		orderTransactionItemDAO.saveOrderTransactionItem(orderTransactionItem3);
		assertNotNull(orderTransactionItem3);

		orderTransactionItemDAO.saveOrderTransactionItem(orderTransactionItem4);
		assertNotNull(orderTransactionItem4);

		Set<OrderTransactionItem> itemList = new HashSet<OrderTransactionItem>();
		itemList.add(orderTransactionItem1);
		itemList.add(orderTransactionItem2);
		itemList.add(orderTransactionItem3);
		itemList.add(orderTransactionItem4);
		orderTransaction.setOrderTransactionItems(itemList);
		orderTransactionDAO.saveOrderTransaction(orderTransaction);

		boolean retVal = invoiceService.createInvoice(orderTransaction.getOrderTransactionId());

		// long retVal = invoiceService.createInvoice(37);
		assertTrue(retVal);

	}

	@Rollback(true)
	@Test
	public void testCreateInvoiceMultiple() {

		Orders newOrder = new Orders();
		newOrder.setCreated(new Timestamp(System.currentTimeMillis()));
		newOrder.setOneTimeTotal(new BigDecimal(368.00));
		newOrder.setOrderType("NEW");
		newOrder.setRecordType("ORDER");
		newOrder.setCustomerId(29179);
		//newOrder.setDiscountAmount(new BigDecimal(0.00));
		//newOrder.setDiscountPercent(new BigDecimal(0.00));
		newOrder.setPrepayAmount(BigDecimal.ZERO);
		newOrder.setMrcTotal(new BigDecimal(398.00));
		newOrder.setPrepayAmount(new BigDecimal(0.00));
		newOrder.setApprovalComment("Test Approval Comment");
		newOrder.setContractBalance(new BigDecimal(398.00));
		newOrder.setCompanyName("Test Company");
		newOrder.setEntityContact(contactDAO.loadContact(1));
		newOrder.setIndustry("Test");
		newOrder.setNote("Test order created from JUnit");
		newOrder.setWebsite("Test Wbesite");

		Orders order = orderDAO.saveOrder(newOrder);
		assertNotNull(order);

		OrderGroup orderGroup = new OrderGroup();
		orderGroup.setOrders(order);
		orderGroup.setServerId(19075);
		orderGroup.setEntityAddressByBillingAddressId(addressDAO.loadAddress(20000));
		orderGroup.setProduct(productDAO.loadProduct(7));
		orderGroup.setOneTimeTotal(new BigDecimal(168.00));
		orderGroup.setOneTimeTaxTotal(new BigDecimal(0));
		//orderGroup.setDiscountAmount(new BigDecimal(0.00));
		orderGroup.setMrcTaxTotal(new BigDecimal(0.00));
		orderGroup.setMrcTotal(new BigDecimal(168.00));
		orderGroup.setNetsuiteSalesOrderId(Long.valueOf(1119580));
		orderGroup.setEntityAddressByShippingAddressId(addressDAO.loadAddress(20000));

		orderGroupDAO.saveOrderGroup(orderGroup);
		assertNotNull(orderGroup);

		OrderGroup orderGroup1 = new OrderGroup();
		orderGroup1.setOrders(order);
		orderGroup1.setServerId(18836);
		orderGroup1.setEntityAddressByBillingAddressId(addressDAO.loadAddress(10000));
		orderGroup1.setProduct(productDAO.loadProduct(7));
		orderGroup1.setOneTimeTotal(new BigDecimal(368.00));
		orderGroup1.setOneTimeTaxTotal(new BigDecimal(0));
		//orderGroup1.setDiscountAmount(new BigDecimal(0.00));
		orderGroup1.setMrcTaxTotal(new BigDecimal(0.00));
		orderGroup1.setMrcTotal(new BigDecimal(368.00));
		//orderGroup1.setNetsuiteSalesOrderId(Long.valueOf(1119580));
		orderGroup1.setEntityAddressByShippingAddressId(addressDAO.loadAddress(10000));

		orderGroupDAO.saveOrderGroup(orderGroup1);
		assertNotNull(orderGroup1);

		Set<OrderGroup> orderGroupSet = new HashSet<OrderGroup>();
		orderGroupSet.add(orderGroup);
		orderGroupSet.add(orderGroup1);
		order.setOrderGroups(orderGroupSet);
		orderDAO.saveOrder(order);

		BillingSchedule newSched = new BillingSchedule();
		newSched.setCustomerId(order.getCustomerId());
		newSched.setStartDate(DateUtils.formatDate("09/01/2012", DateUtils.USA_DATETIME));
		newSched.setOrders(order);
		newSched.setPaymentMethod(paymentMethodDAO.loadPaymentMethod(1));
		newSched.setEndDate(DateUtils.formatDate("10/31/2012", DateUtils.USA_DATETIME));
		newSched.setStatus(FSPConstants.BILLING_SCHEDULE_STATUS_NOT_PROCESSED);
		newSched.setType(FSPConstants.BILLING_SCHEDULE_TYPE_ALL);
		BillingSchedule schedule = billingScheduleDAO.saveBillingSchedule(newSched);

		OrderTransaction orderTransaction = new OrderTransaction();
		orderTransaction.setOrderGroup(orderGroup);
		orderTransaction.setCustomerId(schedule.getCustomerId());
		orderTransaction.setType(FSPConstants.INVOICE_TRANSACTION_TYPE);
		orderTransaction.setAmount(new BigDecimal(1111.00));
		orderTransaction.setCreated(new Timestamp(System.currentTimeMillis()));
		orderTransaction.setBillingSchedule(schedule);
		orderTransaction.setPaymentMethod(paymentMethodDAO.loadPaymentMethod(1));
		orderTransaction.setStatus(FSPConstants.ORDER_TRANSACTION_STATUS_NOT_PROCESSED);
		orderTransaction = orderTransactionDAO.saveOrderTransaction(orderTransaction);
		assertNotNull(orderTransactionDAO.loadOrderTransaction(orderTransaction
				.getOrderTransactionId()));

		OrderTransactionItem orderTransactionItem1 = new OrderTransactionItem();
		orderTransactionItem1.setOrderTransaction(orderTransaction);
		orderTransactionItem1.setOrderGroup(orderGroup);
		orderTransactionItem1.setBundle(this.bundleDAO.loadBundle(42));
		orderTransactionItem1.setDescription("Polycom SoundPoint IP 331 phone");
		orderTransactionItem1.setAmount(new BigDecimal(200.0));
		orderTransactionItem1.setMonthlyUsage(223);
		orderTransactionItem1.setListPrice(BigDecimal.ZERO);
		orderTransactionItem1.setNetsuiteItemId(2610);

		OrderTransactionItem orderTransactionItem2 = new OrderTransactionItem();
		orderTransactionItem2.setOrderTransaction(orderTransaction);
		orderTransactionItem2.setOrderGroup(orderGroup);
		orderTransactionItem2.setBundle(this.bundleDAO.loadBundle(100));
		orderTransactionItem2.setDescription("International Minutes Usage");
		orderTransactionItem2.setAmount(new BigDecimal(23.0));
		orderTransactionItem2.setMonthlyUsage(11);
		orderTransactionItem2.setListPrice(BigDecimal.ZERO);
		orderTransactionItem2.setNetsuiteItemId(3240);

		OrderTransactionItem orderTransactionItem3 = new OrderTransactionItem();
		orderTransactionItem3.setOrderTransaction(orderTransaction);
		orderTransactionItem3.setOrderGroup(orderGroup);
		orderTransactionItem3.setBundle(this.bundleDAO.loadBundle(102));
		orderTransactionItem3.setDescription("Fax Pages Usage");
		orderTransactionItem3.setAmount(new BigDecimal(20.0));
		orderTransactionItem3.setMonthlyUsage(0);
		orderTransactionItem3.setListPrice(BigDecimal.ZERO);
		orderTransactionItem3.setNetsuiteItemId(3240);

		OrderTransactionItem orderTransactionItem4 = new OrderTransactionItem();
		orderTransactionItem4.setOrderTransaction(orderTransaction);
		orderTransactionItem4.setOrderGroup(orderGroup1);
		orderTransactionItem4.setBundle(this.bundleDAO.loadBundle(42));
		orderTransactionItem4.setDescription("Polycom SoundPoint IP 331 phone");
		orderTransactionItem4.setAmount(new BigDecimal(100.0));
		orderTransactionItem4.setMonthlyUsage(223);
		orderTransactionItem4.setListPrice(BigDecimal.ZERO);
		orderTransactionItem4.setNetsuiteItemId(2610);

		OrderTransactionItem orderTransactionItem5 = new OrderTransactionItem();
		orderTransactionItem5.setOrderTransaction(orderTransaction);
		orderTransactionItem5.setOrderGroup(orderGroup1);
		orderTransactionItem5.setBundle(this.bundleDAO.loadBundle(100));
		orderTransactionItem5.setDescription("International Minutes Usage");
		orderTransactionItem5.setAmount(new BigDecimal(13.0));
		orderTransactionItem5.setMonthlyUsage(11);
		orderTransactionItem5.setListPrice(BigDecimal.ZERO);
		orderTransactionItem5.setNetsuiteItemId(3240);

		OrderTransactionItem orderTransactionItem6 = new OrderTransactionItem();
		orderTransactionItem6.setOrderTransaction(orderTransaction);
		orderTransactionItem6.setOrderGroup(orderGroup1);
		orderTransactionItem6.setBundle(this.bundleDAO.loadBundle(102));
		orderTransactionItem6.setDescription("Fax Pages Usage");
		orderTransactionItem6.setAmount(new BigDecimal(10.0));
		orderTransactionItem6.setMonthlyUsage(0);
		orderTransactionItem6.setListPrice(BigDecimal.ZERO);
		orderTransactionItem6.setNetsuiteItemId(3240);

		orderTransactionItemDAO.saveOrderTransactionItem(orderTransactionItem1);
		assertNotNull(orderTransactionItem1);

		orderTransactionItemDAO.saveOrderTransactionItem(orderTransactionItem2);
		assertNotNull(orderTransactionItem2);

		orderTransactionItemDAO.saveOrderTransactionItem(orderTransactionItem3);
		assertNotNull(orderTransactionItem3);

		orderTransactionItemDAO.saveOrderTransactionItem(orderTransactionItem4);
		assertNotNull(orderTransactionItem4);

		orderTransactionItemDAO.saveOrderTransactionItem(orderTransactionItem5);
		assertNotNull(orderTransactionItem5);

		orderTransactionItemDAO.saveOrderTransactionItem(orderTransactionItem6);
		assertNotNull(orderTransactionItem6);

		Set<OrderTransactionItem> itemList = new HashSet<OrderTransactionItem>();
		itemList.add(orderTransactionItem1);
		itemList.add(orderTransactionItem2);
		itemList.add(orderTransactionItem3);
		itemList.add(orderTransactionItem4);
		itemList.add(orderTransactionItem5);
		itemList.add(orderTransactionItem6);
		orderTransaction.setOrderTransactionItems(itemList);
		orderTransactionDAO.saveOrderTransaction(orderTransaction);

		boolean retVal = invoiceService.createInvoice(orderTransaction.getOrderTransactionId());

		// long retVal = invoiceService.createInvoice(37);
		assertTrue(retVal);

	}
}
