package com.fonality.service;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      OrderService.java
 //* Revision:      1.0
 //* Author:        Satya Boddu
 //* Created On:    Nov 27, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   Service class to encapsulate business operations on Order data
 /********************************************************************************/

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.EntityAddress;
import com.fonality.bu.entity.EntityCreditCard;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.OrderTransaction;
import com.fonality.bu.entity.Orders;
import com.fonality.bu.entity.PaymentMethod;
import com.fonality.bu.entity.json.Address;
import com.fonality.bu.entity.json.CreditCard;
import com.fonality.bu.entity.json.Input;
import com.fonality.dao.AddressDAO;
import com.fonality.dao.BillingScheduleDAO;
import com.fonality.dao.BundleDAO;
import com.fonality.dao.EntityCreditCardDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.OrderTransactionDAO;
import com.fonality.dao.OrderTransactionItemDAO;
import com.fonality.dao.PaymentMethodDAO;
import com.fonality.util.BillingProperties;
import com.fonality.util.DateUtils;
import com.fonality.util.FSPConstants;
import com.fonality.util.ObjectUtils;
import com.fonality.ws.NetSuiteWS;
import com.netsuite.webservices.lists.relationships_2012_2.Customer;
import com.netsuite.webservices.lists.relationships_2012_2.CustomerCreditCards;
import com.netsuite.webservices.lists.relationships_2012_2.CustomerCreditCardsList;
import com.netsuite.webservices.platform.core_2012_2.Record;
import com.netsuite.webservices.platform.core_2012_2.RecordRef;
import com.netsuite.webservices.platform.core_2012_2.types.RecordType;

@Service
@Transactional
public class OrderService {

	@Autowired
	public OrderTransactionDAO orderTransactionDAO;

	@Autowired
	public OrderTransactionItemDAO orderTransactionItemDAO;

	@Autowired
	public OrderGroupDAO orderGroupDAO;

	@Autowired
	public OrderDAO orderDAO;

	@Autowired
	public BundleDAO bundleDAO;

	@Autowired
	public PaymentMethodDAO paymentMethodDAO;

	@Autowired
	public EntityCreditCardDAO entityCreditCardDAO;

	@Autowired
	public AddressDAO addressDAO;

	@Autowired
	public BillingScheduleDAO billingScheduleDAO;

	@Autowired
	public InvoiceService invoiceService;

	@Autowired
	public OrderTransactionLineItemService transactionItemService;

	@Autowired
	public NetSuiteWS netSuiteWS;

	private static final Logger LOGGER = Logger.getLogger(OrderService.class.getName());

	// 1) Checks if netsuite credit card id is associated with order record 
	// 2) If not, gets the customer record from netsuite 
	// 3) Gets the existing credit card list from customer record 
	// 4) Checks if the credit card number exists, if yes, updates the credit card details like expire date, name, type,etc.. 
	// 5) If credit card does not exists, create new credit card and attach to the customer
	// 6) Update customer record in netsuite 
	// 7) Update order record with the generated netsuite credit card id 
	// 8) Check if billing address exists in entity_address table, if not, create new address record. 
	// 9) Create new record in entity_credit_card table with the generated netsuite credit card id, address id and other credit card details.

	/**
	 * Method to process order invoice. If payment method is credit card,
	 * 
	 * @param inputObj
	 * @return return value, null if success, exception, if error occurs
	 */
	public String processOrderInvoice(Input inputObj) throws Exception {
		String retVal = null;

		if (!ObjectUtils.isValid(inputObj)) {
			retVal = FSPConstants.INPUT_EMPTY;
		} else if (!ObjectUtils.isValid(inputObj.getOrderId())
				|| !StringUtils.isNumeric(inputObj.getOrderId())) {
			retVal = FSPConstants.INVALID_ORDER;
		} else {
			try {
				//orderTaxationService.calculateAndInsertTaxRates(Integer.parseInt(inputObj
				//	.getOrderId()));
			} catch (Exception exc) {
				LOGGER.error("Error occurred in calculating one time tax", exc);
				retVal = ("Error occurred in calculating one time tax \n " + exc
						.getLocalizedMessage());
			}

			if (retVal == null) {
				// Load order object with the order Id
				Orders order = this.orderDAO.loadOrder(Integer.parseInt(inputObj.getOrderId()));

				if (order == null) {
					// If order is null, set the error message
					retVal = FSPConstants.INVALID_ORDER;
				} else {
					if (order.getPaymentMethod() == null) {
						/*
						 * If payment method id is null in order object, set the error message
						 */
						retVal = FSPConstants.INVALID_PAYMENT_METHOD;
					} else {

						// If payment method is credit card
						if (this.isCreditCard(order.getPaymentMethod())) {
							CreditCard creditCard = inputObj.getCreditCard();

							LOGGER.info("Payment method is credit card");
							// Check if netsuite credit card id exists in order record
							if (!ObjectUtils.isValid(order.getEntityCreditCard())) {
								try {

									// Set customer id and netsuite lead id (customer internal id)
									creditCard.setCustomerNetSuiteId(order.getNetsuiteEntityId());
									creditCard.setCustomerId(order.getCustomerId());

									// Validate credit card data and create, if needed
									retVal = this.validateAndCreateCreditCard(inputObj, order);

								} catch (Exception exc) {
									LOGGER.error(
											"Error occurred on creating new credit card record in NetSuite",
											exc);
									retVal = "Error occurred on creating new credit card record in NetSuite\n "
											+ exc.getLocalizedMessage();
								}

								if (StringUtils.isBlank(retVal)) {
									try {
										/*
										 * If credit card id is created successfully in netsuite,
										 * update fcs data
										 */
										if (creditCard.getCreditCardId() != null) {

											List<EntityCreditCard> creditCardList = this.entityCreditCardDAO
													.getCreditCardByNSIdAndCustomer(
															creditCard.getCreditCardId(),
															creditCard.getCustomerId());
											EntityCreditCard entityCreditCard = null;

											if (!ObjectUtils.isValid(creditCardList)) {
												Integer addressId = getBillingAddressId(
														inputObj.getBillingAddress(),
														creditCard.getCustomerId());
												if (addressId == null) {
													LOGGER.error("Error occurred on retrieving / creating new entity address");
													retVal = "Error occurred on retrieving / creating new entity address";
												} else {

													// Create new entity credit card
													// object
													entityCreditCard = this
															.createEntityCreditCard(creditCard);

													entityCreditCard.setEntityAddress(addressDAO
															.loadAddress(addressId));

													LOGGER.info("Creating new entity credit card record");
													entityCreditCard = this.entityCreditCardDAO
															.saveEntityCreditCard(entityCreditCard);
												}
											} else {
												entityCreditCard = creditCardList.get(0);
												LOGGER.info("Entity credit card record exists with netsuite credit card id: "
														+ entityCreditCard.getNetsuiteCardId()
														+ ", customer id: "
														+ creditCard.getCustomerId());

											}

											if (entityCreditCard != null) {
												LOGGER.info("Updating order record with credit card id: "
														+ inputObj.getCreditCard()
																.getCreditCardId());
												order.setEntityCreditCard(entityCreditCard);
												// Update order record with credit card
												// id
												this.orderDAO.saveOrder(order);
											}
										}
									} catch (Exception exc) {
										LOGGER.error(
												"Error occurred on saving new credit card id in order:"
														+ order.getOrderId(), exc);
										retVal = "Error occurred on saving new credit card id in order\n "
												+ exc.getLocalizedMessage();
									}
								}
							}

						} else {
							LOGGER.info("Payment method is not credit card");
						}

						// Iterate through each order group, if success
						if (StringUtils.isBlank(retVal)) {
							for (OrderGroup orderGroup : order.getOrderGroups()) {
								try {
									// Create new invoice/cash sale
									this.createNewOrderInvoice(orderGroup);
								} catch (Exception exc) {
									LOGGER.error(
											"Error occurred in creating cash sale / invoice transaction for orderGroup:"
													+ orderGroup.getOrderGroupId(), exc);
									retVal = exc.getLocalizedMessage();
								}
							}

						}
					}
				}
			}
		}

		return retVal;
	}

	/**
	 * Method to create MRC Billing schedule for order
	 * 
	 * @param inputObj
	 * @return return value, null if success, exception, if error occurs
	 */
	public String createMRCBillingSchedule(Input inputObj) throws Exception {
		String retVal = null;
		Orders order = this.orderDAO.loadOrder(Integer.parseInt(inputObj.getOrderId()));
		if (order == null) {
			// If order is null, set the error message
			retVal = FSPConstants.INVALID_ORDER;
		} else if (!ObjectUtils.isValid(order.getOrderGroups())) {
			// If order group list is null/blank, set the error message
			retVal = FSPConstants.ORDER_GROUP_EMPTY;
		} else {
			if (order.getPaymentMethod() == null) {
				/*
				 * If payment method id is null in order object, set the error message
				 */
				retVal = FSPConstants.INVALID_PAYMENT_METHOD;
			} else {
				List<BillingSchedule> billingScheduleList = new ArrayList<BillingSchedule>();

				/*
				 * Contract start date needs to be retrieved from the DB, added temp code
				 */
				Calendar startDate = Calendar.getInstance();
				startDate.set(2013, 4, 10);

				Calendar endDate = Calendar.getInstance();
				endDate.setTime(startDate.getTime());
				endDate.add(Calendar.MONTH, 1);

				for (int i = 0; i < order.getTermInMonths(); i++) {

					BillingSchedule billingSchedule = new BillingSchedule();
					billingSchedule.setCustomerId(order.getCustomerId());

					billingSchedule.setEntityCreditCard(order.getEntityCreditCard());
					billingSchedule.setPaymentMethod(order.getPaymentMethod());
					billingSchedule.setOrders(order);
					billingSchedule.setStatus(FSPConstants.BILLING_SCHEDULE_STATUS_NOT_PROCESSED);
					billingSchedule.setType(getBillingScheduleType((i + 1),
							order.getBillingIntervalInMonths()));
					billingSchedule.setStartDate(startDate.getTime());
					billingSchedule.setEndDate(endDate.getTime());
					billingScheduleList.add(billingSchedule);

					startDate.add(Calendar.MONTH, 1);
					endDate.add(Calendar.MONTH, 1);
				}

				if (ObjectUtils.isValid(billingScheduleList)) {
					for (BillingSchedule billingSchedule : billingScheduleList) {
						billingScheduleDAO.saveBillingSchedule(billingSchedule);
					}
				}
			}
		}

		return retVal;

	}

	/**
	 * Method to get billing schedule type based on billing interval and row count.
	 * 
	 * @param rowCnt
	 * @param billingInterval
	 * @return billingSchedule type
	 */
	private String getBillingScheduleType(int rowCnt, int billingInterval) {
		String retVal = null;
		if (rowCnt == 1)
			retVal = FSPConstants.BILLING_SCHEDULE_TYPE_SERVICE;
		else {
			if (billingInterval == 1)
				retVal = FSPConstants.BILLING_SCHEDULE_TYPE_ALL;
			else {
				if ((rowCnt % billingInterval) == 0)
					retVal = FSPConstants.BILLING_SCHEDULE_TYPE_ALL;
				else
					retVal = FSPConstants.BILLING_SCHEDULE_TYPE_SERVICE;
			}
		}

		return retVal;
	}

	/**
	 * Method to create new credit card record in Netsuite
	 * 
	 * @param creditCard
	 * @return creditCard internal Id
	 */
	private Integer createNewCreditCard(CreditCard creditCard) throws Exception {
		Integer retVal = null;
		// Create customer netsuite record
		Customer customer = new Customer();
		customer.setInternalId(creditCard.getCustomerNetSuiteId().toString());
		CustomerCreditCards[] creditCardList = new CustomerCreditCards[1];

		CustomerCreditCards customerCreditCard = new CustomerCreditCards();

		Calendar expireCal = Calendar.getInstance();
		Date expireDate = DateUtils
				.formatDate(creditCard.getCcExpireDate(), DateUtils.USA_DATETIME);
		expireCal.setTime(expireDate);

		customerCreditCard.setCcExpireDate(expireCal);
		customerCreditCard.setCcName(creditCard.getCcName());
		customerCreditCard.setCcNumber(creditCard.getCcNumber());
		customerCreditCard.setPaymentMethod(this.netSuiteWS.initRecordRef(creditCard
				.getPaymentMethodId()));

		creditCardList[0] = customerCreditCard;

		/*
		 * Create credit card list with the new credit card data, set replace all to false
		 */
		CustomerCreditCardsList customerCreditCardList = new CustomerCreditCardsList();
		customerCreditCardList.setReplaceAll(false);
		customerCreditCardList.setCreditCards(creditCardList);

		customer.setCreditCardsList(customerCreditCardList);
		Long customerId = this.netSuiteWS.updateRecord(customer);

		if (customerId != null) {
			retVal = getCreditCardId(creditCard);
		}

		return retVal;
	}

	/**
	 * Method to create new invoice/ cash sale transaction in Netsuite
	 * 
	 * @param orderGroup
	 * @throws Exception
	 *             , if error occurred during the process of creating invoice
	 */
	private void createNewOrderInvoice(OrderGroup orderGroup) throws Exception {
		boolean retVal = false;
		// Validate order group data
		this.validateOrder(orderGroup);
		LOGGER.info("Creating order transaction and items for orderGroup:"
				+ orderGroup.getOrderGroupId());
		// Create order transaction record
		OrderTransaction orderTransaction = this.createOrderTransaction(orderGroup);

		if (!ObjectUtils.isValid(orderTransaction)) {
			throw new Exception("Error occurred in creating order transaction for orderGroup:"
					+ orderGroup.getOrderGroupId());
		}

		// Create order transaction items
		retVal = transactionItemService.generateTransactionLineItemsForFirstCashSale(
				orderTransaction.getOrderTransactionId(), orderGroup);

		if (!retVal) {
			throw new Exception(
					"Error occurred in creating order transaction items for orderGroup:"
							+ orderGroup.getOrderGroupId() + ", orderTrsanctionId: "
							+ orderTransaction.getOrderTransactionId());
		}

		LOGGER.info("Creating new cash sale/ invoice in Netsuite for orderGroup:"
				+ orderGroup.getOrderGroupId());
		// Create cash sale/invoice transaction
		retVal = invoiceService.createInvoice(orderTransaction.getOrderTransactionId());

		// Throw exception, on failure
		if (!retVal) {
			throw new Exception(invoiceService.geFailureMessage());
		}
	}

	/**
	 * Method to validate the data
	 * 
	 * @param orderGroup
	 * @param orderGroupId
	 * @return boolean
	 */
	private void validateOrder(OrderGroup orderGroup) throws Exception {
		String errorMsg = null;
		long orderGroupId = orderGroup.getOrderGroupId();
		// orderGroup.getOrders().setCustomerId(29179);
		// orderGroup.getOrders().setPaymentMethodId(1);

		if (orderGroup == null) {
			errorMsg = "Invalid Data: Unable to find orderGroup for orderGroup Id: " + orderGroupId;
		} else if (!ObjectUtils.isValid(orderGroup.getNetsuiteSalesOrderId())) {
			errorMsg = "Invalid Data: NetSuite Id is blank/null for orderGroup Id: " + orderGroupId;
		} else if (!ObjectUtils.isValid(orderGroup.getServerId())) {
			errorMsg = "Invalid Data: Server Id is blank/null for orderGroup Id: " + orderGroupId;
		} else if (!ObjectUtils.isValid(orderGroup.getOrderBundles())) {
			errorMsg = "Invalid Data: Order Bundles missing for orderGroup Id: " + orderGroupId;
		} else if (!ObjectUtils.isValid(orderGroup.getOrders().getCustomerId())) {
			errorMsg = "Invalid Data: Customer Id missing for orderGroup Id: " + orderGroupId;
		} else if (!ObjectUtils.isValid(orderGroup.getOrders().getPaymentMethod())) {
			errorMsg = "Invalid Data: Payment Method missing for orderGroup Id: " + orderGroupId;
		}

		if (StringUtils.isNotEmpty(errorMsg))
			throw new Exception(errorMsg);

	}

	/**
	 * Method to create order transaction record
	 * 
	 * @param orderGroup
	 * @return orderTransaction
	 */
	private OrderTransaction createOrderTransaction(OrderGroup orderGroup) throws Exception {
		OrderTransaction orderTransaction = new OrderTransaction();

		orderTransaction.setPaymentMethod(orderGroup.getOrders().getPaymentMethod());

		orderTransaction.setServerId(orderGroup.getServerId());
		orderTransaction.setCustomerId(orderGroup.getOrders().getCustomerId());
		orderTransaction.setOrderGroup(orderGroup);
		orderTransaction.setStatus(FSPConstants.ORDER_TRANSACTION_STATUS_READY);
		orderTransaction.setAmount(orderGroup.getOneTimeTotal()
				.add(orderGroup.getOneTimeTaxTotal()));
		if (orderGroup.getOrders().getPaymentMethod().getName()
				.equals(FSPConstants.PAYMENT_METHOD_CREDIT_CARD)) {
			orderTransaction.setType(FSPConstants.CASHSALE_TRANSACTION_TYPE);
		} else {
			orderTransaction.setType(FSPConstants.INVOICE_TRANSACTION_TYPE);
		}

		orderTransaction = orderTransactionDAO.saveOrderTransaction(orderTransaction);

		if (orderTransaction == null) {
			throw new Exception(
					"Error occurred on creating order transaction record, orderGroupId: "
							+ orderGroup.getOrderGroupId());
		}

		return orderTransaction;
	}

	/**
	 * Method to create order transaction items based on orderBundles list
	 * 
	 * @param orderGroup
	 * @param orderTransaction
	 */
	private void createOrderTransactionItems(OrderTransaction orderTransaction,
			OrderGroup orderGroup) throws Exception {

	}

	/**
	 * Method to get customer record from Netsuite by netsuite customerId
	 * 
	 * @param customerId
	 * @return record
	 * @throws Exception
	 */
	private Record getCustomer(Long customerId) throws Exception {
		RecordRef recordRef = new RecordRef();
		recordRef.setInternalId(customerId.toString());
		recordRef.setType(RecordType.customer);
		return this.netSuiteWS.getRecord(recordRef);
	}

	/**
	 * Method to get customer by customerId
	 * 
	 * @param customerId
	 * @return record
	 * @throws Exception
	 */
	private Integer getCreditCardId(CreditCard creditCard) throws Exception {
		Integer creditCardId = null;
		boolean creditCardExists = false;
		// Get customer record from netsuite
		Customer customer = (Customer) this.getCustomer(Long.valueOf(creditCard
				.getCustomerNetSuiteId()));

		// Get existing credit card list for the customer
		CustomerCreditCards[] creditCards = customer.getCreditCardsList().getCreditCards();

		/*
		 * Loop through each credit card and check if credit card with the same number exists
		 */
		for (int i = 0; i < creditCards.length; i++) {
			CreditCard customerCreditCard = new CreditCard(creditCards[i]);

			if (customerCreditCard.equals(creditCard)) {
				creditCardExists = true;
				LOGGER.info("Credit card exists with the same number ");
				creditCardId = Integer.parseInt(creditCards[i].getInternalId());

				Calendar expireDate = Calendar.getInstance();
				expireDate.setTime(DateUtils.formatDate(creditCard.getCcExpireDate(),
						DateUtils.USA_DATETIME_YYYY));

				creditCards[i].setCcExpireDate(expireDate);
				creditCards[i].setCcName(creditCard.getCcName());
				creditCards[i].setPaymentMethod(this.netSuiteWS.initRecordRef(creditCard
						.getPaymentMethodId()));
				break;
			}
		}

		/*
		 * If credit card exists in netsuite with same number, update the record with the data
		 * provided
		 */
		if (creditCardExists) {
			Customer updateCustomer = new Customer();
			updateCustomer.setInternalId(customer.getInternalId());

			CustomerCreditCardsList creditCardsList = new CustomerCreditCardsList();
			creditCardsList.setReplaceAll(true);
			creditCardsList.setCreditCards(creditCards);

			updateCustomer.setCreditCardsList(creditCardsList);
			LOGGER.info("Updating credit card record with the input data(expire date, name, payment method) ");
			this.netSuiteWS.updateRecord(updateCustomer);
		}

		return creditCardId;

	}

	/**
	 * Method to validate the JSON data
	 * 
	 * @param creditCard
	 * @return boolean
	 */
	private String validateAndCreateCreditCard(Input inputObj, Orders order) throws Exception {

		CreditCard creditCard = inputObj.getCreditCard();

		String retVal = null;
		if (creditCard == null) {
			retVal = "Invalid Data: Unable to find creditCard data";
		} else if (!ObjectUtils.isValid(order.getCustomerId())) {
			retVal = "Invalid Data: Customer id Null/Blank";
		} else if (!ObjectUtils.isValid(order.getNetsuiteEntityId())) {
			retVal = "Invalid Data: Order Netsuite Lead id Null/Blank";
		} else if (!ObjectUtils.isValid(creditCard.getCcName())) {
			retVal = "Invalid Data: Credit card name is missing";
		} else if (!ObjectUtils.isValid(creditCard.getCcType())) {
			retVal = "Invalid Data: Credit card type is missing";
		} else if (!ObjectUtils.isValid(creditCard.getCcExpireDate())) {
			retVal = "Invalid Data: Credit card expire date is missing";
		} else if (DateUtils.formatDate(creditCard.getCcExpireDate(), DateUtils.USA_DATETIME_YYYY) == null) {
			retVal = "Invalid Data: Credit card expire date value/format is invalid. Must provide date in MM/dd/yyyy format";
		} else if (!ObjectUtils.isValid(creditCard.getCcNumber())) {
			retVal = "Invalid Data: Credit card number is missing";
		} else if (BillingProperties.getProperties().get(creditCard.getCcType()) == null) {
			retVal = "Invalid Data: Credit card type is invalid, Valid types:(visa, mastercard, american_express, discover) ";
		} else if (inputObj.getBillingAddress() == null) {
			retVal = "Invalid Data: Billing Address is missing";
		} else if (!ObjectUtils.isValid(inputObj.getBillingAddress().getAddress1())) {
			retVal = "Invalid Data: Billing Address is missing";
		} else if (!ObjectUtils.isValid(inputObj.getBillingAddress().getCity())) {
			retVal = "Invalid Data: Billing City is missing";
		} else if (!ObjectUtils.isValid(inputObj.getBillingAddress().getState())) {
			retVal = "Invalid Data: Billing State is missing";
		} else if (!ObjectUtils.isValid(inputObj.getBillingAddress().getZipCode())) {
			retVal = "Invalid Data: Billing Postal is missing";
		} else if (!ObjectUtils.isValid(inputObj.getBillingAddress().getCountry())) {
			retVal = "Invalid Data: Billing Country is missing";
		}

		if (retVal == null) {
			Integer creditCardId = this.createCreditCard(creditCard);
			if (creditCardId == null) {
				retVal = "Unable to create credit card in NetSuite";
			} else {
				creditCard.setCreditCardId(creditCardId);
			}

		}
		return retVal;
	}

	/**
	 * Method to check if payment type is credit card
	 * 
	 * @param paymentMethod
	 * @return boolean
	 */
	private boolean isCreditCard(PaymentMethod paymentMethod) {
		return paymentMethod.getName().equals(FSPConstants.PAYMENT_METHOD_CREDIT_CARD);
	}

	/**
	 * Method to check if credit card exists, else create new credit card record in NS
	 * 
	 * @param creditCard
	 * @return creditCardId
	 */
	private Integer createCreditCard(CreditCard creditCard) throws Exception {
		// Check if credit card exists in netsuite with the same number
		Integer creditCardId = this.getCreditCardId(creditCard);

		// If it does not exists, create new credit card
		if (creditCardId == null) {
			LOGGER.info("Credit card does not exists, creating new credit card record in NetSuite");
			creditCardId = this.createNewCreditCard(creditCard);
		}

		return creditCardId;
	}

	/**
	 * Method to create EntityCreditCard object in NS
	 * 
	 * @param creditCard
	 * @return creditCardId
	 */
	private EntityCreditCard createEntityCreditCard(CreditCard creditCard) throws Exception {
		EntityCreditCard entityCreditCard = new EntityCreditCard();
		entityCreditCard.setCardholderName(creditCard.getCcName());
		entityCreditCard.setCustomerId(creditCard.getCustomerId());
		entityCreditCard.setNetsuiteCardId(creditCard.getCreditCardId());

		Calendar expireCal = Calendar.getInstance();
		expireCal.setTime(DateUtils.formatDate(creditCard.getCcExpireDate(),
				DateUtils.USA_DATETIME_YYYY));
		entityCreditCard.setExpirationMonth((byte) (expireCal.get(Calendar.MONTH) + 1));
		entityCreditCard.setExpirationYear((short) expireCal.get(Calendar.YEAR));
		entityCreditCard.setFirstFour(creditCard.getCcNumber().substring(0, 4));
		entityCreditCard.setLastFour(creditCard.getCcNumber().substring(
				(creditCard.getCcNumber().length() - 4), creditCard.getCcNumber().length()));
		return entityCreditCard;
	}

	/**
	 * Method to check if credit card exists, else create new credit card record in NS
	 * 
	 * @param creditCard
	 * @return creditCardId
	 */
	private Integer getBillingAddressId(Address address, int customerId) throws Exception {
		Integer entityAddressId = null;
		EntityAddress checkEntityAddress = new EntityAddress("Customer: " + customerId,
				FSPConstants.BILLING_ADDRESS_TYPE, address.getAddress1(),
				(address.getAddress2() == null) ? "" : address.getAddress2(), address.getCity(),
				address.getState(), address.getZipCode(), address.getCountry(), null, null);

		List<EntityAddress> addressList = addressDAO
				.getAddressList(FSPConstants.BILLING_ADDRESS_TYPE);
		if (ObjectUtils.isValid(addressList)) {
			for (EntityAddress entityAddress : addressList) {
				if (ObjectUtils.doesAddressMatch(entityAddress, checkEntityAddress)) {
					entityAddressId = entityAddress.getEntityAddressId();
					break;
				}
			}
		}

		if (entityAddressId == null) {
			LOGGER.info("Address does not exists, creating new address ");
			checkEntityAddress = this.addressDAO.saveEntityAddress(checkEntityAddress);
			entityAddressId = checkEntityAddress.getEntityAddressId();
		}

		return entityAddressId;
	}
}
