package com.fonality.test.dao;

import static org.junit.Assert.assertNotNull;

import java.math.BigDecimal;
import java.util.Date;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.Orders;
import com.fonality.dao.AddressDAO;
import com.fonality.dao.BillingScheduleDAO;
import com.fonality.dao.ContactDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.PaymentMethodDAO;
import com.fonality.dao.ProductDAO;
import com.fonality.util.FSPConstants;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestBillingScheduleDAO extends AbstractTransactionalJUnit4SpringContextTests {

	@Autowired
	public BillingScheduleDAO billingScheduleDAO;

	@Autowired
	public OrderDAO orderDAO;

	@Autowired
	public OrderGroupDAO orderGroupDAO;

	@Autowired
	public ProductDAO productDAO;

	@Autowired
	public AddressDAO addressDAO;

	@Autowired
	public ContactDAO contactDAO;
	
	@Autowired
	public PaymentMethodDAO paymentMethodDAO;

	@Test
	public void testBillingSchedule() {

		// Set up fake order to be referenced by schedule
		Orders newOrder = new Orders();
		newOrder.setOneTimeTotal(new BigDecimal(368.00));
		newOrder.setOrderType(FSPConstants.ORDERS_ORDER_TYPE_NEW);
		newOrder.setRecordType(FSPConstants.ORDERS_RECORD_TYPE_ORDER);
		//newOrder.setFirstPayment(new BigDecimal(398.00));
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
		newOrder.setPrepayAmount(BigDecimal.ZERO);
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
		orderGroup1.setEntityAddressByShippingAddressId(addressDAO.loadAddress(20000));

		orderGroupDAO.saveOrderGroup(orderGroup1);
		assertNotNull(orderGroup1);

		BillingSchedule newSched = new BillingSchedule();
		newSched.setCustomerId(1);
		newSched.setEndDate(new Date());
		newSched.setOrders(order);
		newSched.setPaymentMethod(paymentMethodDAO.loadPaymentMethod(1));
		newSched.setStartDate(new Date());
		newSched.setStatus(FSPConstants.BILLING_SCHEDULE_STATUS_NOT_PROCESSED);
		newSched.setType(FSPConstants.BILLING_SCHEDULE_TYPE_ALL);

		BillingSchedule schedule = billingScheduleDAO.saveBillingSchedule(newSched);
		assertNotNull(schedule);
		// assertNotNull(schedule.getCreated());

		int scheduleId = schedule.getBillingScheduleId();
		assertNotNull(billingScheduleDAO.loadBuillingSchedule(scheduleId));

		//assertTrue(billingScheduleDAO.getCustomerListId().size() > 0);
	}

}
