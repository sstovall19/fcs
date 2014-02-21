package com.fonality.test.dao;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.bu.entity.OrderBundle;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.Orders;
import com.fonality.dao.AddressDAO;
import com.fonality.dao.BundleDAO;
import com.fonality.dao.ContactDAO;
import com.fonality.dao.OrderBundleDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.ProductDAO;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestOrderBundleDAO extends AbstractTransactionalJUnit4SpringContextTests {

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
	public BundleDAO bundleDAO;

	@Autowired
	public OrderBundleDAO orderBundleDAO;

	// @Rollback(false)
	@Test
	public void testOrder() {

		Orders newOrder = new Orders();
		newOrder.setCreated(new Timestamp(System.currentTimeMillis()));
		newOrder.setOneTimeTotal(new BigDecimal(368.00));
		newOrder.setOrderType("NEW");
		newOrder.setRecordType("ORDER");
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
		orderGroup1.setEntityAddressByShippingAddressId(addressDAO.loadAddress(20000));

		OrderGroup newGroup = orderGroupDAO.saveOrderGroup(orderGroup1);
		assertNotNull(newGroup);

		OrderBundle orderBundle = new OrderBundle();
		orderBundle.setBundle(bundleDAO.loadBundle(1));
		orderBundle.setDiscountedPrice(new BigDecimal(100.00));
		orderBundle.setIsRented(false);
		orderBundle.setListPrice(new BigDecimal(100.00));
		orderBundle.setMrcTotal(BigDecimal.ZERO);
		orderBundle.setOneTimeTotal(new BigDecimal(100.00));
		orderBundle.setOrderGroup(newGroup);
		orderBundle.setProvisionedOn(new Date());
		orderBundle.setQuantity(1);
		//orderBundle.setUnitPrice(new BigDecimal(100.00));

		OrderBundle bundle = orderBundleDAO.saveOrderBundle(orderBundle);
		assertNotNull(bundle);
		assertTrue(orderBundleDAO.getOrderBundleListByBundleId(1).size() > 0);
		assertTrue(orderBundleDAO.getOrderBundleListByOrderGroupId(newGroup.getOrderGroupId())
				.size() > 0);
		assertNotNull(orderBundleDAO.loadOrderBundle(bundle.getOrderBundleId()));
		orderBundleDAO.deleteOrderBundle(bundle);
		assertNull(orderBundleDAO.loadOrderBundle(bundle.getOrderBundleId()));

	}
}
