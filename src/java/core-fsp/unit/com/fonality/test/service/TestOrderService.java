package com.fonality.test.service;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

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

import com.fonality.bu.entity.OrderBundle;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.Orders;
import com.fonality.bu.entity.json.Address;
import com.fonality.bu.entity.json.CreditCard;
import com.fonality.bu.entity.json.Input;
import com.fonality.dao.AddressDAO;
import com.fonality.dao.BillingScheduleDAO;
import com.fonality.dao.BundleDAO;
import com.fonality.dao.ContactDAO;
import com.fonality.dao.EntityCreditCardDAO;
import com.fonality.dao.OrderBundleDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.PaymentMethodDAO;
import com.fonality.dao.ProductDAO;
import com.fonality.dao.TaxMappingDAO;
import com.fonality.service.InvoiceService;
import com.fonality.service.OrderService;
import com.fonality.util.BillingProperties;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestOrderService extends AbstractTransactionalJUnit4SpringContextTests {

	@Autowired
	public InvoiceService invoiceService;

	@Autowired
	public OrderService orderService;

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
	public PaymentMethodDAO paymentMethodDAO;

	@Autowired
	public EntityCreditCardDAO entityCreditCardDAO;

	@Autowired
	public BillingScheduleDAO billingScheduleDAO;

	@Autowired
	public BundleDAO bundleDAO;

	@Autowired
	public OrderBundleDAO orderBundleDAO;

	@Autowired
	public TaxMappingDAO taxMappingDAO;

	@Rollback(true)
	@Test
	public void testCreateCashsale() {

		String retVal = null;
		// orderService.createNewOrderInvoice(30050);
		Orders newOrder = new Orders();
		newOrder.setCreated(new Timestamp(System.currentTimeMillis()));
		newOrder.setOneTimeTotal(new BigDecimal(368.00));
		newOrder.setOrderType("NEW");
		newOrder.setRecordType("ORDER");
		newOrder.setPrepayAmount(BigDecimal.ZERO);
		newOrder.setOneTimeTotal(new BigDecimal(188.00));
		newOrder.setMrcTotal(new BigDecimal(398.00));
		newOrder.setPrepayAmount(new BigDecimal(0.00));
		newOrder.setApprovalComment("Test Approval Comment");
		newOrder.setContractBalance(new BigDecimal(398.00));
		newOrder.setContractTotal(new BigDecimal(398.00));
		newOrder.setCompanyName("Test Company");
		newOrder.setEntityContact(contactDAO.loadContact(1));
		newOrder.setIndustry("Test");
		newOrder.setNote("Test cash sale order created from JUnit");
		newOrder.setWebsite("www.fonality.com");
		// newOrder.setEntityCreditCard(entityCreditCardDAO
		// .loadEntityCreditCard(2));
		newOrder.setPaymentMethod(paymentMethodDAO.loadPaymentMethod(1));
		newOrder.setCustomerId(29179);
		newOrder.setNetsuiteEntityId(26110l);
		newOrder.setAvgCostPerUser("0.00");
		newOrder.setCostAddUser("Test");

		newOrder = orderDAO.saveOrder(newOrder);
		assertNotNull(newOrder);

		OrderGroup orderGroup = new OrderGroup();
		orderGroup.setOrders(newOrder);
		orderGroup.setEntityAddressByBillingAddressId(addressDAO.loadAddress(20000));
		orderGroup.setProduct(productDAO.loadProduct(7));
		orderGroup.setOneTimeTotal(new BigDecimal(3708.00));
		orderGroup.setOneTimeTaxTotal(new BigDecimal(333.72));
		orderGroup.setMrcTaxTotal(new BigDecimal(165.76));
		orderGroup.setMrcTotal(new BigDecimal(984.00));
		orderGroup.setNetsuiteSalesOrderId(Long.valueOf(1119583));
		orderGroup.setServerId(15305);
		orderGroup.setEntityAddressByShippingAddressId(addressDAO.loadAddress(1));

		orderGroupDAO.saveOrderGroup(orderGroup);
		assertNotNull(orderGroup);

		Set<OrderGroup> orderGroupSet = new HashSet<OrderGroup>();
		orderGroupSet.add(orderGroup);
		newOrder.setOrderGroups(orderGroupSet);
		orderDAO.saveOrder(newOrder);

		OrderBundle orderBundle1 = new OrderBundle();
		orderBundle1.setBundle(bundleDAO.loadBundle(69));
		orderBundle1.setIsRented(false);
		orderBundle1.setListPrice(new BigDecimal(1005.00));
		orderBundle1.setMrcTotal(new BigDecimal(169.00));
		orderBundle1.setOneTimeTotal(new BigDecimal(1005.00));
		orderBundle1.setOrderGroup(orderGroup);
		orderBundle1.setQuantity(10);
		//orderBundle1.setUnitPrice(new BigDecimal(100.50));
		orderBundle1.setDiscountedPrice(BigDecimal.ZERO);
		orderBundleDAO.saveOrderBundle(orderBundle1);

		OrderBundle orderBundle2 = new OrderBundle();
		orderBundle2.setBundle(bundleDAO.loadBundle(81));
		orderBundle2.setIsRented(false);
		orderBundle2.setListPrice(new BigDecimal(0.00));
		orderBundle2.setMrcTotal(new BigDecimal(9.00));
		orderBundle2.setOneTimeTotal(new BigDecimal(0.00));
		orderBundle2.setOrderGroup(orderGroup);
		orderBundle2.setQuantity(10);
		//orderBundle2.setUnitPrice(new BigDecimal(0.90));
		orderBundle2.setDiscountedPrice(BigDecimal.ZERO);
		//orderBundleDAO.saveOrderBundle(orderBundle2);

		OrderBundle orderBundle3 = new OrderBundle();
		orderBundle3.setBundle(bundleDAO.loadBundle(63));
		orderBundle3.setIsRented(false);
		orderBundle3.setListPrice(new BigDecimal(2253.00));
		orderBundle3.setMrcTotal(new BigDecimal(0.00));
		orderBundle3.setOneTimeTotal(new BigDecimal(2253.00));
		orderBundle3.setOrderGroup(orderGroup);
		orderBundle3.setQuantity(1);
		//orderBundle3.setUnitPrice(new BigDecimal(2253.00));
		orderBundle3.setDiscountedPrice(BigDecimal.ZERO);
		//orderBundleDAO.saveOrderBundle(orderBundle3);

		OrderBundle orderBundle4 = new OrderBundle();
		orderBundle4.setBundle(bundleDAO.loadBundle(43));
		orderBundle4.setIsRented(false);
		orderBundle4.setListPrice(new BigDecimal(450.00));
		orderBundle4.setMrcTotal(new BigDecimal(9.00));
		orderBundle4.setOneTimeTotal(new BigDecimal(450.00));
		orderBundle4.setOrderGroup(orderGroup);
		orderBundle4.setQuantity(4);
		//orderBundle4.setUnitPrice(new BigDecimal(112.50));
		orderBundle4.setDiscountedPrice(BigDecimal.ZERO);
		//orderBundleDAO.saveOrderBundle(orderBundle4);

		OrderBundle orderBundle5 = new OrderBundle();
		orderBundle5.setBundle(bundleDAO.loadBundle(55));
		orderBundle5.setIsRented(false);
		orderBundle5.setListPrice(new BigDecimal(0.00));
		orderBundle5.setMrcTotal(new BigDecimal(975.00));
		orderBundle5.setOneTimeTotal(new BigDecimal(0.00));
		orderBundle5.setOrderGroup(orderGroup);
		orderBundle5.setQuantity(65);
		//orderBundle5.setUnitPrice(new BigDecimal(15.00));
		orderBundle5.setDiscountedPrice(BigDecimal.ZERO);
		//orderBundleDAO.saveOrderBundle(orderBundle5);

		Set<OrderBundle> orderBundleSet = new HashSet<OrderBundle>();
		orderBundleSet.add(orderBundle1);
		//orderBundleSet.add(orderBundle2);
		//orderBundleSet.add(orderBundle3);
		//orderBundleSet.add(orderBundle4);
		//orderBundleSet.add(orderBundle5);
		orderGroup.setOrderBundles(orderBundleSet);
		orderGroupDAO.saveOrderGroup(orderGroup);

		try {
			Input inputObj = new Input(new JSONObject());
			inputObj.setOrderId(newOrder.getOrderId().toString());

			CreditCard creditCard = new CreditCard(new JSONObject());
			creditCard.setCcName("Test Name");
			creditCard.setCcNumber("6011371009074492");
			creditCard.setCcExpireDate("10/01/2015");
			creditCard.setCcType("discover");
			creditCard.setPaymentMethodId((String) BillingProperties.getProperties()
					.get("discover"));
			inputObj.setCreditCard(creditCard);

			Address billingAddress = new Address(new JSONObject());
			billingAddress.setAddress1(newOrder.getOrderId() + " Stillwood Drive ");
			billingAddress.setAddress2(null);
			billingAddress.setCity("Wake Forest");
			billingAddress.setZipCode("27587");
			billingAddress.setState("NC");
			billingAddress.setCountry("USA");
			inputObj.setBillingAddress(billingAddress);

			retVal = orderService.processOrderInvoice(inputObj);
		} catch (Exception exc) {
			exc.printStackTrace();
		}

		assertNull(retVal);

	}

	@Rollback(true)
	@Test
	public void testCreateInvoice() {
		String retVal = null;
		Orders newOrder1 = new Orders();
		newOrder1.setCreated(new Timestamp(System.currentTimeMillis()));
		newOrder1.setOneTimeTotal(new BigDecimal(368.00));
		newOrder1.setOrderType("NEW");
		newOrder1.setRecordType("ORDER");
		//newOrder1.setDiscountAmount(new BigDecimal(0.00));
		//newOrder1.setDiscountPercent(new BigDecimal(0.00));
		newOrder1.setPrepayAmount(BigDecimal.ZERO);
		newOrder1.setOneTimeTotal(new BigDecimal(177.00));
		newOrder1.setMrcTotal(new BigDecimal(398.00));
		newOrder1.setPrepayAmount(new BigDecimal(0.00));
		newOrder1.setApprovalComment("Test Approval Comment");
		newOrder1.setContractBalance(new BigDecimal(398.00));
		newOrder1.setContractTotal(new BigDecimal(398.00));
		newOrder1.setCompanyName("Test Company");
		newOrder1.setEntityContact(contactDAO.loadContact(1));
		newOrder1.setIndustry("Test");
		newOrder1.setNote("Test invoice order created from JUnit");
		newOrder1.setWebsite("www.fonality.com");
		// newOrder1.setNetsuiteCreditCardId(75328L);
		newOrder1.setEntityCreditCard(entityCreditCardDAO.loadEntityCreditCard(2));
		newOrder1.setPaymentMethod(paymentMethodDAO.loadPaymentMethod(2));
		newOrder1.setCustomerId(29179);
		newOrder1.setNetsuiteEntityId(26110l);
		newOrder1.setAvgCostPerUser("0.00");
		newOrder1.setCostAddUser("Test");

		newOrder1 = orderDAO.saveOrder(newOrder1);
		assertNotNull(newOrder1);

		OrderGroup orderGroup1 = new OrderGroup();
		orderGroup1.setOrders(newOrder1);
		orderGroup1.setEntityAddressByBillingAddressId(addressDAO.loadAddress(20000));
		orderGroup1.setProduct(productDAO.loadProduct(7));
		orderGroup1.setOneTimeTotal(new BigDecimal(126.00));
		orderGroup1.setOneTimeTaxTotal(new BigDecimal(42.0));
		//orderGroup1.setDiscountAmount(new BigDecimal(0.00));
		orderGroup1.setMrcTaxTotal(new BigDecimal(0.00));
		orderGroup1.setMrcTotal(new BigDecimal(368.00));
		orderGroup1.setNetsuiteSalesOrderId(Long.valueOf(1119580));
		orderGroup1.setServerId(16294);
		orderGroup1.setEntityAddressByShippingAddressId(addressDAO.loadAddress(20000));

		orderGroupDAO.saveOrderGroup(orderGroup1);
		assertNotNull(orderGroup1);

		Set<OrderGroup> orderGroupSet = new HashSet<OrderGroup>();
		orderGroupSet.add(orderGroup1);
		newOrder1.setOrderGroups(orderGroupSet);
		orderDAO.saveOrder(newOrder1);

		OrderBundle orderBundle6 = new OrderBundle();
		orderBundle6.setBundle(bundleDAO.loadBundle(42));
		orderBundle6.setIsRented(true);
		orderBundle6.setListPrice(new BigDecimal(159.00));
		orderBundle6.setMrcTotal(new BigDecimal(159.00));
		orderBundle6.setOneTimeTotal(new BigDecimal(159.00));
		orderBundle6.setOrderGroup(orderGroup1);
		orderBundle6.setQuantity(1);
		//orderBundle6.setUnitPrice(new BigDecimal(159.00));
		orderBundle6.setDiscountedPrice(BigDecimal.ZERO);
		//orderBundleDAO.saveOrderBundle(orderBundle6);

		OrderBundle orderBundle7 = new OrderBundle();
		orderBundle7.setBundle(bundleDAO.loadBundle(43));
		orderBundle7.setIsRented(false);
		orderBundle7.setListPrice(new BigDecimal(149.00));
		orderBundle7.setMrcTotal(new BigDecimal(149.00));
		orderBundle7.setOneTimeTotal(new BigDecimal(149.00));
		orderBundle7.setOrderGroup(orderGroup1);
		orderBundle7.setQuantity(1);
		//orderBundle7.setUnitPrice(new BigDecimal(149.00));
		orderBundle7.setDiscountedPrice(BigDecimal.ZERO);
		//orderBundleDAO.saveOrderBundle(orderBundle7);

		OrderBundle orderBundle8 = new OrderBundle();
		orderBundle8.setBundle(bundleDAO.loadBundle(69));
		orderBundle8.setIsRented(true);
		orderBundle8.setListPrice(new BigDecimal(59.00));
		orderBundle8.setMrcTotal(new BigDecimal(59.00));
		orderBundle8.setOneTimeTotal(new BigDecimal(59.00));
		orderBundle8.setOrderGroup(orderGroup1);
		orderBundle8.setQuantity(1);
		//orderBundle6.setUnitPrice(new BigDecimal(159.00));
		orderBundle8.setDiscountedPrice(BigDecimal.ZERO);
		orderBundleDAO.saveOrderBundle(orderBundle8);

		Set<OrderBundle> orderBundleSet = new HashSet<OrderBundle>();
		//orderBundleSet.add(orderBundle6);
		//orderBundleSet.add(orderBundle7);
		orderBundleSet.add(orderBundle8);
		orderGroup1.setOrderBundles(orderBundleSet);
		orderGroupDAO.saveOrderGroup(orderGroup1);

		try {
			Input inputObj = new Input(new JSONObject());
			inputObj.setOrderId(newOrder1.getOrderId().toString());
			retVal = orderService.processOrderInvoice(inputObj);
		} catch (Exception exc) {
			exc.printStackTrace();
		}

		assertNull(retVal);

	}

	/* This test method is used to create MRC schedule with monthly billing interval */
	@Rollback(true)
	@Test
	public void testCreateMRCScheduleMonthly() {
		String retVal = null;
		Orders newOrder1 = new Orders();
		newOrder1.setCreated(new Timestamp(System.currentTimeMillis()));
		newOrder1.setOneTimeTotal(new BigDecimal(368.00));
		newOrder1.setOrderType("NEW");
		newOrder1.setRecordType("ORDER");
		//newOrder1.setDiscountAmount(new BigDecimal(0.00));
		//newOrder1.setDiscountPercent(new BigDecimal(0.00));
		newOrder1.setPrepayAmount(BigDecimal.ZERO);
		newOrder1.setOneTimeTotal(new BigDecimal(177.00));
		newOrder1.setMrcTotal(new BigDecimal(398.00));
		newOrder1.setPrepayAmount(new BigDecimal(0.00));
		newOrder1.setApprovalComment("Test Approval Comment");
		newOrder1.setContractBalance(new BigDecimal(398.00));
		newOrder1.setContractTotal(new BigDecimal(398.00));
		newOrder1.setCompanyName("Test Company");
		newOrder1.setEntityContact(contactDAO.loadContact(1));
		newOrder1.setIndustry("Test");
		newOrder1.setTermInMonths(12);
		newOrder1.setBillingIntervalInMonths(1);
		newOrder1.setNote("Test invoice order created for MRC Schedule from JUnit");
		newOrder1.setWebsite("www.fonality.com");
		// newOrder1.setNetsuiteCreditCardId(75328L);
		newOrder1.setEntityCreditCard(entityCreditCardDAO.loadEntityCreditCard(2));
		newOrder1.setPaymentMethod(paymentMethodDAO.loadPaymentMethod(2));
		newOrder1.setCustomerId(29179);
		newOrder1.setAvgCostPerUser("0.00");
		newOrder1.setCostAddUser("Test");

		newOrder1 = orderDAO.saveOrder(newOrder1);
		assertNotNull(newOrder1);

		OrderGroup orderGroup1 = new OrderGroup();
		orderGroup1.setOrders(newOrder1);
		orderGroup1.setEntityAddressByBillingAddressId(addressDAO.loadAddress(20000));
		orderGroup1.setProduct(productDAO.loadProduct(7));
		orderGroup1.setOneTimeTotal(new BigDecimal(126.00));
		orderGroup1.setOneTimeTaxTotal(new BigDecimal(42.0));
		//orderGroup1.setDiscountAmount(new BigDecimal(0.00));
		orderGroup1.setMrcTaxTotal(new BigDecimal(0.00));
		orderGroup1.setMrcTotal(new BigDecimal(368.00));
		orderGroup1.setNetsuiteSalesOrderId(Long.valueOf(1119580));
		orderGroup1.setServerId(16294);
		orderGroup1.setEntityAddressByShippingAddressId(addressDAO.loadAddress(20000));

		orderGroupDAO.saveOrderGroup(orderGroup1);
		assertNotNull(orderGroup1);

		Set<OrderGroup> orderGroupSet = new HashSet<OrderGroup>();
		orderGroupSet.add(orderGroup1);
		newOrder1.setOrderGroups(orderGroupSet);
		orderDAO.saveOrder(newOrder1);

		try {
			Input inputObj = new Input(new JSONObject());
			inputObj.setOrderId(newOrder1.getOrderId().toString());

			retVal = orderService.createMRCBillingSchedule(inputObj);
		} catch (Exception exc) {
			exc.printStackTrace();
		}

		assertNull(retVal);
	}

	/* This test method is used to create MRC schedule with quarterly billing interval */
	@Rollback(true)
	@Test
	public void testCreateMRCScheduleQuarterly() {
		String retVal = null;
		Orders newOrder1 = new Orders();
		newOrder1.setCreated(new Timestamp(System.currentTimeMillis()));
		newOrder1.setOneTimeTotal(new BigDecimal(368.00));
		newOrder1.setOrderType("NEW");
		newOrder1.setRecordType("ORDER");
		//newOrder1.setDiscountAmount(new BigDecimal(0.00));
		//newOrder1.setDiscountPercent(new BigDecimal(0.00));
		newOrder1.setPrepayAmount(BigDecimal.ZERO);
		newOrder1.setOneTimeTotal(new BigDecimal(177.00));
		newOrder1.setMrcTotal(new BigDecimal(398.00));
		newOrder1.setPrepayAmount(new BigDecimal(0.00));
		newOrder1.setApprovalComment("Test Approval Comment");
		newOrder1.setContractBalance(new BigDecimal(398.00));
		newOrder1.setContractTotal(new BigDecimal(398.00));
		newOrder1.setCompanyName("Test Company");
		newOrder1.setEntityContact(contactDAO.loadContact(1));
		newOrder1.setIndustry("Test");
		newOrder1.setTermInMonths(12);
		newOrder1.setBillingIntervalInMonths(3);
		newOrder1.setNote("Test invoice order created for MRC Schedule from JUnit");
		newOrder1.setWebsite("www.fonality.com");
		// newOrder1.setNetsuiteCreditCardId(75328L);
		newOrder1.setEntityCreditCard(entityCreditCardDAO.loadEntityCreditCard(2));
		newOrder1.setPaymentMethod(paymentMethodDAO.loadPaymentMethod(2));
		newOrder1.setCustomerId(29179);
		newOrder1.setAvgCostPerUser("0.00");
		newOrder1.setCostAddUser("Test");

		newOrder1 = orderDAO.saveOrder(newOrder1);
		assertNotNull(newOrder1);

		OrderGroup orderGroup1 = new OrderGroup();
		orderGroup1.setOrders(newOrder1);
		orderGroup1.setEntityAddressByBillingAddressId(addressDAO.loadAddress(20000));
		orderGroup1.setProduct(productDAO.loadProduct(7));
		orderGroup1.setOneTimeTotal(new BigDecimal(126.00));
		orderGroup1.setOneTimeTaxTotal(new BigDecimal(42.0));
		//orderGroup1.setDiscountAmount(new BigDecimal(0.00));
		orderGroup1.setMrcTaxTotal(new BigDecimal(0.00));
		orderGroup1.setMrcTotal(new BigDecimal(368.00));
		orderGroup1.setNetsuiteSalesOrderId(Long.valueOf(1119580));
		orderGroup1.setServerId(16294);
		orderGroup1.setEntityAddressByShippingAddressId(addressDAO.loadAddress(20000));

		orderGroupDAO.saveOrderGroup(orderGroup1);
		assertNotNull(orderGroup1);

		Set<OrderGroup> orderGroupSet = new HashSet<OrderGroup>();
		orderGroupSet.add(orderGroup1);
		newOrder1.setOrderGroups(orderGroupSet);
		orderDAO.saveOrder(newOrder1);

		try {
			Input inputObj = new Input(new JSONObject());
			inputObj.setOrderId(newOrder1.getOrderId().toString());

			retVal = orderService.createMRCBillingSchedule(inputObj);
		} catch (Exception exc) {
			exc.printStackTrace();
		}

		assertNull(retVal);
	}
}
