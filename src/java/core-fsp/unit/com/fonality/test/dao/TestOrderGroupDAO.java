package com.fonality.test.dao;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.Orders;
import com.fonality.dao.AddressDAO;
import com.fonality.dao.ContactDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.ProductDAO;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestOrderGroupDAO extends AbstractTransactionalJUnit4SpringContextTests {

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

	// @Rollback(false)
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
		// orderGroup1.setNetSuiteId(BigInteger.valueOf(1119580));
		orderGroup1.setEntityAddressByShippingAddressId(addressDAO.loadAddress(20000));

		orderGroupDAO.saveOrderGroup(orderGroup1);
		assertNotNull(orderGroup1);

		OrderGroup orderGroup2 = new OrderGroup();
		orderGroup2.setOrders(order);
		orderGroup2.setServerId(1);
		orderGroup2.setEntityAddressByBillingAddressId(addressDAO.loadAddress(20001));
		orderGroup2.setProduct(productDAO.loadProduct(8));
		orderGroup2.setOneTimeTotal(new BigDecimal(468.00));
		orderGroup2.setOneTimeTaxTotal(new BigDecimal(0));
		//orderGroup2.setDiscountAmount(new BigDecimal(0.00));
		orderGroup2.setMrcTaxTotal(new BigDecimal(0.00));
		orderGroup2.setMrcTotal(new BigDecimal(468.00));
		// orderGroup2.setNetSuiteId(BigInteger.valueOf(1119580));
		orderGroup2.setEntityAddressByShippingAddressId(addressDAO.loadAddress(20000));

		orderGroupDAO.saveOrderGroup(orderGroup2);
		assertNotNull(orderGroup2);

		List<OrderGroup> orderGroupList = orderGroupDAO.getOrderGroupListByOrderId(order
				.getOrderId());

		assertTrue(orderGroupList.size() == 2);

		orderGroupDAO.deleteOrderGroup(orderGroup2);
		orderGroupDAO.deleteOrderGroup(orderGroup1);
		orderDAO.deleteOrder(order);

	}
}
