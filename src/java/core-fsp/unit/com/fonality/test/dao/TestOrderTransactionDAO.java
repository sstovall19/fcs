package com.fonality.test.dao;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.OrderTransaction;
import com.fonality.bu.entity.OrderTransactionItem;
import com.fonality.bu.entity.Orders;
import com.fonality.dao.AddressDAO;
import com.fonality.dao.BundleDAO;
import com.fonality.dao.ContactDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.OrderTransactionDAO;
import com.fonality.dao.OrderTransactionItemDAO;
import com.fonality.dao.PaymentMethodDAO;
import com.fonality.dao.ProductDAO;
import com.fonality.util.FSPConstants;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestOrderTransactionDAO extends AbstractTransactionalJUnit4SpringContextTests {

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

	/**
	 * 
	 */
	/**
	 * 
	 */
	@Rollback(true)
	@Test
	public void testOrderTransaction() {
		Orders newOrder = new Orders();
		newOrder.setCreated(new Timestamp(System.currentTimeMillis()));
		newOrder.setOneTimeTotal(new BigDecimal(368.00));
		// newOrder.setStatus("pending_fulfillment");
		newOrder.setOrderType("NEW");
		newOrder.setRecordType("ORDER");
		// newOrder.setNetsuiteLeadId(1119583);
		newOrder.setPrepayAmount(BigDecimal.ZERO);
		newOrder.setMrcTotal(new BigDecimal(398.00));
		newOrder.setPrepayAmount(new BigDecimal(0.00));
		newOrder.setApprovalComment("Test Approval Comment");
		newOrder.setContractBalance(new BigDecimal(398.00));
		newOrder.setContractTotal(new BigDecimal(398.00));
		newOrder.setCompanyName("Test Company");
		newOrder.setEntityContact(contactDAO.loadContact(1));
		newOrder.setIndustry("Test");
		newOrder.setNote("Test order created from JUnit");
		newOrder.setWebsite("Test Wbesite");
		newOrder.setAvgCostPerUser("0.00");
		newOrder.setCostAddUser("Test");

		Orders order = orderDAO.saveOrder(newOrder);
		assertNotNull(order);

		OrderGroup orderGroup1 = new OrderGroup();
		orderGroup1.setOrders(order);
		orderGroup1.setServerId(0);
		orderGroup1.setEntityAddressByBillingAddressId(addressDAO.loadAddress(20000));
		orderGroup1.setProduct(productDAO.loadProduct(7));
		orderGroup1.setOneTimeTotal(new BigDecimal(368.00));
		orderGroup1.setOneTimeTaxTotal(new BigDecimal(0));
		//orderGroup1.setDiscountAmount(new BigDecimal(0.00));
		orderGroup1.setMrcTaxTotal(new BigDecimal(0.00));
		orderGroup1.setMrcTotal(new BigDecimal(368.00));
		orderGroup1.setNetsuiteSalesOrderId(Long.valueOf(1119580));
		orderGroup1.setEntityAddressByShippingAddressId(addressDAO.loadAddress(20000));

		orderGroupDAO.saveOrderGroup(orderGroup1);
		assertNotNull(orderGroup1);

		OrderTransaction orderTransaction = new OrderTransaction();
		orderTransaction.setOrderGroup(orderGroup1);
		orderTransaction.setCustomerId(1);
		orderTransaction.setType(FSPConstants.INVOICE_TRANSACTION_TYPE);
		orderTransaction.setAmount(new BigDecimal(1111.00));
		orderTransaction.setCreated(new Timestamp(System.currentTimeMillis()));
		orderTransaction.setServerId(1);
		orderTransaction.setPaymentMethod(paymentMethodDAO.loadPaymentMethod(1));
		orderTransaction.setStatus(FSPConstants.ORDER_TRANSACTION_STATUS_NOT_PROCESSED);
		orderTransaction = orderTransactionDAO.saveOrderTransaction(orderTransaction);
		assertNotNull(orderTransactionDAO.loadOrderTransaction(orderTransaction
				.getOrderTransactionId()));

		OrderTransactionItem orderTransactionItem = new OrderTransactionItem();
		orderTransactionItem.setOrderTransaction(orderTransaction);
		orderTransactionItem.setBundle(this.bundleDAO.loadBundle(31));
		orderTransactionItem.setDescription("Test Order Transaction Item2");
		orderTransactionItem.setAmount(new BigDecimal(200.0));
		orderTransactionItem.setMonthlyUsage(223);
		orderTransactionItem.setListPrice(BigDecimal.ZERO);
		orderTransactionItem.setOrderGroup(orderGroup1);
		orderTransactionItem.setNetsuiteItemId(this.bundleDAO.loadBundle(31).getNetsuiteOrderId());

		orderTransactionItemDAO.saveOrderTransactionItem(orderTransactionItem);
		assertNotNull(orderTransactionItem);

		List<OrderTransactionItem> items = orderTransactionItemDAO
				.getItemListByTrasanctionId(orderTransaction.getOrderTransactionId());

		assertNotNull(items);

		orderTransactionItemDAO.deleteOrderTransactionItem(orderTransactionItem);
		assertNull(orderTransactionItemDAO.loadOrderTransactionItem(orderTransactionItem
				.getOrderTransactionItemId()));

		orderTransactionItemDAO.deleteOrderTransactionItem(orderTransactionItem);

		orderTransactionDAO.deleteOrderTransaction(orderTransaction);
		assertNull(orderTransactionDAO.loadOrderTransaction(orderTransaction
				.getOrderTransactionId()));

	}
}
