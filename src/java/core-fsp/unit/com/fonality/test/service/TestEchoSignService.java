package com.fonality.test.service;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.HashSet;
import java.util.Set;

import org.json.JSONObject;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.bu.entity.EntityContact;
import com.fonality.bu.entity.OrderBundle;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.OrderShipping;
import com.fonality.bu.entity.Orders;
import com.fonality.dao.AddressDAO;
import com.fonality.dao.BundleDAO;
import com.fonality.dao.ContactDAO;
import com.fonality.dao.OrderBundleDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.ProductDAO;
import com.fonality.dao.TaxMappingDAO;
import com.fonality.service.EchoSignService;
import com.fonality.util.FSPConstants;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestEchoSignService extends AbstractTransactionalJUnit4SpringContextTests {

	@Autowired
	public EchoSignService echoSignService;

	@Autowired
	public OrderDAO orderDAO;

	@Autowired
	public ProductDAO productDAO;

	@Autowired
	public ContactDAO contactDAO;

	@Autowired
	public AddressDAO addressDAO;

	@Autowired
	public OrderGroupDAO orderGroupDAO;

	@Autowired
	public BundleDAO bundleDAO;

	@Autowired
	public OrderBundleDAO orderBundleDAO;

	@Autowired
	public TaxMappingDAO taxMappingDAO;

	@Rollback(true)
	@Test
	public void testEchoSignAgreement() {
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
		newOrder.setContractTotal(new BigDecimal(398.00));
		newOrder.setCompanyName("Test Company");

		EntityContact contact = contactDAO.getContactByEmail("sboddu@fonality.com");

		if (contact == null) {
			contact = new EntityContact();
			contact.setEmail("sboddu@fonality.com");
			contact.setFirstName("Satya");
			contact.setLastName("Boddu");
			contact.setRole("admin");
			contact.setPhone("3104388931");
			contact = contactDAO.saveContact(contact);
		}

		newOrder.setEntityContact(contact);
		newOrder.setIndustry("Test");
		newOrder.setNote("Test order created from echo sign JUnit");
		newOrder.setWebsite("Test Wbesite");
		newOrder.setCustomerId(1);
		newOrder.setNetsuiteSalespersonId(24549); // Danny's account
		newOrder.setAvgCostPerUser("0.00");
		newOrder.setCostAddUser("Test");

		Orders order = orderDAO.saveOrder(newOrder);
		assertNotNull(order);

		OrderGroup orderGroup = new OrderGroup();
		orderGroup.setOrders(order);
		orderGroup.setServerId(0);
		orderGroup.setEntityAddressByBillingAddressId(addressDAO.loadAddress(20000));
		orderGroup.setProduct(productDAO.loadProduct(7));
		orderGroup.setOneTimeTotal(new BigDecimal(368.00));
		orderGroup.setOneTimeTaxTotal(new BigDecimal(0));
		//orderGroup.setDiscountAmount(new BigDecimal(0.00));
		orderGroup.setMrcTaxTotal(new BigDecimal(0.00));
		orderGroup.setMrcTotal(new BigDecimal(368.00));

		OrderShipping orderShipping = new OrderShipping();
		orderShipping.setOrderShippingId(155);
		orderShipping.setShippingText("UPS Ground");
		orderGroup.setOrderShipping(orderShipping);
		orderGroup.setNetsuiteSalesOrderId(Long.valueOf(1164602));
		orderGroup.setEntityAddressByShippingAddressId(addressDAO.loadAddress(20000));

		orderGroupDAO.saveOrderGroup(orderGroup);
		assertNotNull(orderGroup);

		Set<OrderGroup> orderGroupSet = new HashSet<OrderGroup>();
		orderGroupSet.add(orderGroup);
		newOrder.setOrderGroups(orderGroupSet);
		orderDAO.saveOrder(newOrder);

		OrderBundle orderBundle1 = new OrderBundle();
		orderBundle1.setBundle(bundleDAO.loadBundle(81));
		orderBundle1.setIsRented(false);
		orderBundle1.setListPrice(new BigDecimal(1005.00));
		orderBundle1.setMrcTotal(new BigDecimal(169.00));
		orderBundle1.setOneTimeTotal(new BigDecimal(1005.00));
		orderBundle1.setOrderGroup(orderGroup);
		orderBundle1.setQuantity(10);
		//orderBundle1.setUnitPrice(new BigDecimal(100.50));
		orderBundle1.setDiscountedPrice(BigDecimal.ZERO);
		orderBundleDAO.saveOrderBundle(orderBundle1);

		Set<OrderBundle> orderBundleSet = new HashSet<OrderBundle>();
		orderBundleSet.add(orderBundle1);
		orderGroup.setOrderBundles(orderBundleSet);
		orderGroupDAO.saveOrderGroup(orderGroup);

		JSONObject retVal = null;
		int sendStatus = 0;

		try {
			retVal = echoSignService.emailEchoSignAgreement(orderGroup.getOrderGroupId());
			sendStatus = retVal.getInt(FSPConstants.STATUS);
			assertTrue(sendStatus == 1);

			retVal = echoSignService.getSignedEchoSignDocument(orderGroup.getOrderGroupId());
			assertEquals(retVal.getString(FSPConstants.MESSAGE),
					"EchoSign Agreement is not signed, the current status is Out For Signature");
			assertEquals(retVal.getString(FSPConstants.SIGNED_STATUS),
					FSPConstants.NETSUITE_OUT_FOR_SIGNATURE_STATUS);
		} catch (Exception exc) {
			exc.printStackTrace();
		}

	}
}
