package com.fonality.test.dao;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import java.math.BigDecimal;
import java.sql.Timestamp;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.bu.entity.Orders;
import com.fonality.dao.ContactDAO;
import com.fonality.dao.OrderDAO;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestOrderDAO extends AbstractTransactionalJUnit4SpringContextTests {

	@Autowired
	public ContactDAO contactDAO;

	@Autowired
	public OrderDAO orderDAO;

	@Test
	public void testOrder() {
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

		int orderId = order.getOrderId();
		assertNotNull(orderDAO.loadOrder(orderId));

		BigDecimal updateTotalPrice = new BigDecimal(11111);
		order.setOneTimeTotal(updateTotalPrice);
		orderDAO.saveOrder(order);

		Orders updatedOrder = orderDAO.loadOrder(orderId);
		assertEquals(updatedOrder.getOneTimeTotal(), updateTotalPrice);

		orderDAO.deleteOrder(order);
		assertNull(orderDAO.loadOrder(orderId));
	}

}
