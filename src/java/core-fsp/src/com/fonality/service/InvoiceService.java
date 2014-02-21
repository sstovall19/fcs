package com.fonality.service;

/*********************************************************************************
 * Copyright (C) 2012 Fonality. All Rights Reserved.
 *
 * Filename:      InvoiceService.java
 * Revision:      1.0
 * Author:        Satya Boddu
 * Created On:    Jan 16, 2012
 * Modified by:   
 * Modified On:   
 *
 * Description:   Service class to encapsulate business operations to create 
 * 				    invoice/cash sale transactions in NetSuite based on order transaction data
 *
 ********************************************************************************/

import java.io.InputStreamReader;
import java.io.Reader;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Properties;
import java.util.Set;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionException;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.billing.DTO.ServerCdrUsageDTO;
import com.fonality.billing.service.CdrService;
import com.fonality.billing.util.BillingFailureHandler;
import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.OrderTransaction;
import com.fonality.bu.entity.OrderTransactionItem;
import com.fonality.bu.entity.Orders;
import com.fonality.dao.BundleDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.OrderTransactionDAO;
import com.fonality.util.FSPConstants;
import com.fonality.util.NetSuiteProperties;
import com.fonality.util.ObjectUtils;
import com.fonality.util.TransactionItemComparator;
import com.fonality.ws.NetSuiteWS;
import com.netsuite.webservices.documents.filecabinet_2012_2.File;
import com.netsuite.webservices.documents.filecabinet_2012_2.types.MediaType;
import com.netsuite.webservices.platform.core_2012_2.CustomFieldList;
import com.netsuite.webservices.platform.core_2012_2.CustomFieldRef;
import com.netsuite.webservices.platform.core_2012_2.Record;
import com.netsuite.webservices.platform.core_2012_2.RecordRef;
import com.netsuite.webservices.platform.core_2012_2.StringCustomFieldRef;
import com.netsuite.webservices.platform.core_2012_2.types.RecordType;
import com.netsuite.webservices.transactions.sales_2012_2.CashSale;
import com.netsuite.webservices.transactions.sales_2012_2.CashSaleItem;
import com.netsuite.webservices.transactions.sales_2012_2.CashSaleItemList;
import com.netsuite.webservices.transactions.sales_2012_2.Invoice;
import com.netsuite.webservices.transactions.sales_2012_2.InvoiceItem;
import com.netsuite.webservices.transactions.sales_2012_2.InvoiceItemList;
import com.netsuite.webservices.transactions.sales_2012_2.SalesOrder;

@Service
@Transactional(propagation = Propagation.REQUIRED, rollbackFor = TransactionException.class)
public class InvoiceService {

	@Autowired
	public OrderTransactionDAO orderTransactionDAO;

	@Autowired
	public BundleDAO bundleDAO;

	@Autowired
	public OrderGroupDAO orderGroupDAO;

	@Autowired
	public OrderDAO orderDAO;

	@Autowired
	public NetSuiteWS netSuiteWS;

	@Autowired
	public CdrUsageService cdrUsageService;

	@Autowired
	public CdrService cdrService;

	@Autowired
	public BillingFailureHandler failureHandler;

	private StringBuffer failureMessages;

	private String authHeader;

	private static final Logger LOGGER = Logger.getLogger(InvoiceService.class.getName());

	/**
	 * Method to create invoice/cash sale transaction in Netsuite
	 * 
	 * @param orderTransactionId
	 * @return success/fail code
	 */
	public boolean createInvoice(Integer orderTransactionId) {
		boolean invoiceSuccess = false;
		OrderTransaction orderTransaction = null;
		if (failureMessages == null)
			failureMessages = new StringBuffer();
		else
			failureMessages.setLength(0);
		LOGGER.info(" Loading order transaction object, orderTransactionId: " + orderTransactionId);
		// Load orderTransaction data object
		try {
			orderTransaction = this.orderTransactionDAO.loadOrderTransaction(orderTransactionId);
		} catch (Exception exc) {
			LOGGER.error("Error in loading orderTransaction record, id:" + orderTransactionId, exc);
			this.notifyFailure(orderTransaction, FSPConstants.DATA_ERROR,
					"Error in loading orderTransaction record: " + exc.getMessage());
		}
		if (orderTransaction == null) {
			LOGGER.error("Unable to find order transaction record, id:" + orderTransactionId);
			this.notifyFailure(orderTransaction, FSPConstants.DATA_ERROR,
					"Unable to find order transaction record");
		} else {
			/*
			 * Check for valid data and create NetSuite Record object based on the transaction type
			 */
			LOGGER.info("Validating order data, orderTransactionId: " + orderTransactionId);
			if (validateOrder(orderTransaction)) {
				Record record = null;
				try {
					LOGGER.info("Creating Netsuite transaction record object, orderTransactionId: "
							+ orderTransactionId);
					if (orderTransaction.getType().equals(FSPConstants.INVOICE_TRANSACTION_TYPE)) {
						record = createInvoiceRecord(orderTransaction);
					} else if (orderTransaction.getType().equals(
							FSPConstants.CASHSALE_TRANSACTION_TYPE)) {
						record = createCashSaleRecord(orderTransaction);
					} else {
						LOGGER.error("Inavlid order transaction type:" + orderTransaction.getType());
						this.notifyFailure(orderTransaction, FSPConstants.NETSUITE_ERROR,
								"Inavlid order transaction type:" + orderTransaction.getType());
					}

				} catch (Exception exc) {
					LOGGER.error(
							"Error occurred in creating cash sale/ invoice record from FCS, orderTransactionId: "
									+ orderTransaction.getOrderTransactionId(), exc);
					this.notifyFailure(
							orderTransaction,
							FSPConstants.NETSUITE_ERROR,
							"Error occurred in creating cash sale/ invoice record from FCS: "
									+ exc.getMessage());
				}

				if (record != null) {
					try {
						/*
						 * Invoke NetSuite web service to create transaction in NetSuite
						 */
						LOGGER.info("Invoke Netsuite Webservice Call to create transaction in Netsuite, orderTransactionId: "
								+ orderTransactionId);
						Long internalId = netSuiteWS.createRecord(record);
						if (internalId == null) {
							LOGGER.error("Error occurred in processing cash sale/ invoice transaction, orderTransactionId:"
									+ orderTransaction.getOrderTransactionId());
							this.notifyFailure(orderTransaction, FSPConstants.NETSUITE_ERROR,
									"Error occurred in creating cash sale/ invoice record from FCS");

						} else {

							LOGGER.info("Transaction created successfully with internal id "
									+ internalId);
							/*
							 * Update orderTransaction with netSuite transaction id and status as
							 * 'Success'
							 */
							orderTransaction.setNetsuiteTransId(internalId);
							orderTransaction
									.setStatus(FSPConstants.ORDER_TRANSACTION_STATUS_SUCCESS);
							this.orderTransactionDAO.saveOrderTransaction(orderTransaction);
							invoiceSuccess = true;

						}
					} catch (Exception exc) {
						LOGGER.error(
								"Error occurred in processing cash sale/ invoice transaction, orderTransactionId:"
										+ orderTransaction.getOrderTransactionId(), exc);
						this.notifyFailure(orderTransaction, FSPConstants.NETSUITE_ERROR,
								exc.getMessage());
					}
				}
			}

			LOGGER.info("Calling e-mail transacton service and update order balance, orderTransactionId: "
					+ orderTransactionId);
			// If invoice is generated successfully, call email service to generate usage report and email transaction
			if (invoiceSuccess) {
				this.emailTransactionAndUsage(orderTransaction);

				// Update order balance value
				this.updateOrderBalance(orderTransaction);
			}
		}

		return invoiceSuccess;
	}

	/**
	 * Method to create invoice record based on orderTransaction and items data
	 * 
	 * @param orderTransaction
	 * @return invoiceRecord
	 */
	private Record createInvoiceRecord(OrderTransaction orderTransaction) throws Exception {
		Invoice invoiceRecord = new Invoice();
		invoiceRecord.setCreatedFrom(this.netSuiteWS.initRecordRef(orderTransaction.getOrderGroup()
				.getNetsuiteSalesOrderId().intValue()));
		invoiceRecord
				.setCustomForm(this.netSuiteWS.initRecordRef(FSPConstants.INVOICE_CUSTOM_FORM));
		invoiceRecord.setToBeEmailed(false);
		invoiceRecord.setIsTaxable(false);
		Record salesOrder = this.netSuiteWS.getRecord(this.initSalesOrderRecordRef(orderTransaction
				.getOrderGroup().getNetsuiteSalesOrderId()));
		if (salesOrder != null)
			invoiceRecord.setMemo(((SalesOrder) salesOrder).getTranId());
		invoiceRecord.setCustomFieldList(getCustomFieldList(orderTransaction));
		List<InvoiceItem> itemList = populateInvoiceItems(orderTransaction);

		InvoiceItemList invoiceItemList = new InvoiceItemList();
		invoiceItemList.setReplaceAll(true);
		invoiceItemList.setItem(itemList.toArray(new InvoiceItem[itemList.size()]));
		invoiceRecord.setItemList(invoiceItemList);

		return invoiceRecord;
	}

	/**
	 * Method to create cash sale record based on orderTransaction and items data
	 * 
	 * @param orderTransaction
	 * @return cashSaleRecord
	 */
	private Record createCashSaleRecord(OrderTransaction orderTransaction) throws Exception {

		CashSale cashSaleRecord = null;
		Long creditCardId = null;

		/* Check if valid credit card id is associated with the transaction */
		if (orderTransaction.getPaymentMethod().getPaymentMethodId().equals(1)) {
			//.equals(FSPConstants.PAYMENT_METHOD_CREDIT_CARD)) {
			creditCardId = this.getNSCreditCardId(orderTransaction);
			if (creditCardId == null) {
				if (orderTransaction.getBillingSchedule() == null)
					throw new Exception("Netsuite credit card id is null/missing for orderId: "
							+ orderTransaction.getOrderGroup().getOrders().getOrderId());
				else
					throw new Exception(
							"Netsuite credit card id is null/missing for billingScheduleId: "
									+ orderTransaction.getBillingSchedule().getBillingScheduleId());
			}
		}

		cashSaleRecord = new CashSale();
		cashSaleRecord.setCreatedFrom(this.netSuiteWS.initRecordRef(orderTransaction
				.getOrderGroup().getNetsuiteSalesOrderId().intValue()));
		cashSaleRecord.setCustomForm(this.netSuiteWS
				.initRecordRef(FSPConstants.CASHSALE_CUSTOM_FORM));

		if (creditCardId != null)
			cashSaleRecord.setCreditCard(this.netSuiteWS.initRecordRef(creditCardId));
		Record salesOrder = this.netSuiteWS.getRecord(this.initSalesOrderRecordRef(orderTransaction
				.getOrderGroup().getNetsuiteSalesOrderId()));
		if (salesOrder != null)
			cashSaleRecord.setMemo(((SalesOrder) salesOrder).getTranId());
		cashSaleRecord.setIsTaxable(false);
		cashSaleRecord.setToBeEmailed(false);

		List<CashSaleItem> itemList = populateCashSaleItems(orderTransaction);
		CashSaleItemList cashSaleItemList = new CashSaleItemList();
		cashSaleItemList.setReplaceAll(true);
		cashSaleItemList.setItem(itemList.toArray(new CashSaleItem[itemList.size()]));

		cashSaleRecord.setItemList(cashSaleItemList);

		return cashSaleRecord;

	}

	/**
	 * Method to validate order transaction data
	 * 
	 * @param orderTransaction
	 * @return boolean
	 */
	private boolean validateOrder(OrderTransaction orderTransaction) {
		boolean retVal = false;

		List<OrderTransactionItem> itemList = this.orderTransactionDAO
				.getItemsByOrderTransactionId(orderTransaction.getOrderTransactionId());

		// Items are not being loaded, so invoking call to load associated
		// items. NEED TO FIX
		if (ObjectUtils.isValid(itemList)) {
			Set<OrderTransactionItem> itemSet = new HashSet<OrderTransactionItem>(itemList);
			orderTransaction.setOrderTransactionItems(itemSet);
			this.orderTransactionDAO.saveOrderTransaction(orderTransaction);
		}

		/* Check if valid netsuite id is associated with orderGroup */
		if (!ObjectUtils.isValid(orderTransaction.getOrderGroup().getNetsuiteSalesOrderId())) {
			LOGGER.error("Netsuite Id is null/blank on orderId: "
					+ orderTransaction.getOrderGroup().getOrders().getOrderId());
			this.notifyFailure(orderTransaction, FSPConstants.DATA_ERROR,
					"Netsuite Id is null/blank for orderId: "
							+ orderTransaction.getOrderGroup().getOrders().getOrderId());
		} /* Check if line items exist for orderTransaction */
		else if (!ObjectUtils.isValid(orderTransaction.getOrderTransactionItems())) {
			LOGGER.error("Line items missing for orderTransactionId: "
					+ orderTransaction.getOrderTransactionId());
			this.notifyFailure(orderTransaction, FSPConstants.DATA_ERROR,
					"Line items missing for orderTransaction");
		} else {
			boolean isValid = true;
			for (OrderTransactionItem item : orderTransaction.getOrderTransactionItems()) {
				if (!ObjectUtils.isValid(item.getNetsuiteItemId())) {
					LOGGER.error("Valid netsuite bundle does not exists with line item, orderTransactionId: "
							+ orderTransaction.getOrderTransactionId()
							+ ", orderTransactionItemId: " + item.getOrderTransactionItemId());
					this.notifyFailure(orderTransaction, FSPConstants.DATA_ERROR,
							"Valid netsuite bundle does not exists with orderTransactionItemId: "
									+ item.getOrderTransactionItemId());
					isValid = false;
					break;
				}
			}
			retVal = isValid;
		}
		return retVal;
	}

	/**
	 * Method to populate invoice items from transaction item list
	 * 
	 * @param orderTransaction
	 * @return invoiceItemList
	 */
	private List<InvoiceItem> populateInvoiceItems(OrderTransaction orderTransaction)
			throws Exception {
		List<InvoiceItem> invoiceItemList = new ArrayList<InvoiceItem>();
		List<OrderTransactionItem> transactionItems = new ArrayList<OrderTransactionItem>(
				orderTransaction.getOrderTransactionItems());
		Collections.sort(transactionItems, new TransactionItemComparator());
		/* Loop through orderTransaction items */
		for (OrderTransactionItem item : transactionItems) {
			InvoiceItem invoiceItem = new InvoiceItem();
			this.populateInvoiceData(item, invoiceItem);
			invoiceItemList.add(invoiceItem);
		}
		return invoiceItemList;
	}

	/**
	 * Method to populate cash sale items from transaction item list
	 * 
	 * @param orderTransaction
	 * @return cashSaleItemList
	 */
	private List<CashSaleItem> populateCashSaleItems(OrderTransaction orderTransaction)
			throws Exception {
		List<CashSaleItem> cashSaleItemList = new ArrayList<CashSaleItem>();
		List<OrderTransactionItem> transactionItems = new ArrayList<OrderTransactionItem>(
				orderTransaction.getOrderTransactionItems());
		Collections.sort(transactionItems, new TransactionItemComparator());
		/* Loop through orderTransaction items */
		for (OrderTransactionItem item : transactionItems) {
			CashSaleItem cashSaleItem = new CashSaleItem();
			this.populateInvoiceData(item, cashSaleItem);
			cashSaleItemList.add(cashSaleItem);
		}
		return cashSaleItemList;
	}

	/**
	 * Method to get custom fields list for setting custom fieldss on netsuite transaction
	 * 
	 * @param orderTransaction
	 * @return customeFieldList
	 */
	private CustomFieldList getCustomFieldList(OrderTransaction orderTransaction) {
		CustomFieldList customFieldList = new CustomFieldList();

		List<CustomFieldRef> customFieldRefList = new ArrayList<CustomFieldRef>();
		StringCustomFieldRef serverFieldRef = new StringCustomFieldRef();
		serverFieldRef.setInternalId(FSPConstants.CUSTOM_SERVER_ID);
		serverFieldRef.setValue(String.valueOf(orderTransaction.getServerId()));
		customFieldRefList.add(serverFieldRef);
		customFieldList.setCustomField(customFieldRefList
				.toArray(new CustomFieldRef[customFieldRefList.size()]));

		return customFieldList;
	}

	/**
	 * Method to create customer billing report pdf using jasper service
	 * 
	 * @param billingSchedule
	 * @param cashSaleId
	 * @return fileId
	 */
	public Long createCustomerBillingReport(OrderTransaction orderTransaction, byte[] fileContents)
			throws Exception {
		Long fileId = null;

		try {
			/* Create NetSuite file object */
			File file = new File();
			file.setContent(fileContents);
			file.setName(FSPConstants.NS_USAGE_REPORT_NAME + orderTransaction.getNetsuiteTransId()
					+ FSPConstants.PDF_EXT);
			file.setFileType(MediaType._PDF);
			file.setFolder(this.netSuiteWS.initRecordRef(-11));
			/* Upload file on netsuite file cabinet */
			fileId = this.netSuiteWS.createRecord(file);
			LOGGER.info("Document created successfully with internalId:" + fileId);
		} catch (Exception exc) {
			LOGGER.warn("Error occurred in uploading customer usage report for cash sale/ invoice id:"
					+ orderTransaction.getNetsuiteTransId()
					+ " , orderTransactionId:"
					+ orderTransaction.getOrderTransactionId());
			this.notifyFailure(orderTransaction, FSPConstants.REPORT_ERROR,
					"Error occurred in uploading customer usage report for cash sale/ invoice id:"
							+ orderTransaction.getNetsuiteTransId(),
					FSPConstants.BILLING_WARN_LEVEL);
		}

		return fileId;

	}

	/**
	 * Method to email CashSale/Invoice transaction with usage report
	 * 
	 * @param orderTransaction
	 * @param internalId
	 * @param fileId
	 * @param type
	 */
	private void emailTransaction(OrderTransaction orderTransaction, Long fileId, String type) {
		boolean sentStatus = false;
		GetMethod httpGet = null;
		try {
			Properties nsProps = NetSuiteProperties.getProperties();
			HttpClient client = new HttpClient();
			int statusCode = -1;
			StringBuffer getUrl = new StringBuffer(
					nsProps.getProperty(FSPConstants.NS_EMAIL_TRANSACTION_URL_PARAM))
					.append(FSPConstants.TRANSACTION_ID_PARAM).append("=")
					.append(orderTransaction.getNetsuiteTransId()).append("&")
					.append(FSPConstants.FILE_ID_PARAM).append("=")
					.append((fileId == null) ? "0" : fileId).append("&")
					.append(FSPConstants.TYPE_ID_PARAM).append("=").append(type);

			LOGGER.info("Email transaction URL " + getUrl.toString());
			httpGet = new GetMethod(getUrl.toString());
			httpGet.setRequestHeader(FSPConstants.AUTH_HEADER, this.getAuthHeader());
			/*
			 * Execute call to suite script to email transaction with usage report
			 */
			statusCode = client.executeMethod(httpGet);
			if (statusCode != -1) {
				Reader reader = null;
				try {
					reader = new InputStreamReader(httpGet.getResponseBodyAsStream(),
							httpGet.getResponseCharSet());
					String response = IOUtils.toString(reader);
					/* Validate the respone */
					if ((response != null) && response.trim().equals(FSPConstants.SUCCESS))
						sentStatus = true;

				} finally {
					if (reader != null)
						reader.close();
				}
			}

		} catch (Exception exc) {
			/*
			 * Suppress warnings, as notiyFailure would handle the error condition
			 */
		} finally {
			if (httpGet != null)
				httpGet.releaseConnection();

		}

		if (!sentStatus) {
			LOGGER.warn("Error occurred in sending email to the customer for cash sale/invoice: "
					+ orderTransaction.getNetsuiteTransId() + " , orderTransactionId:"
					+ orderTransaction.getOrderTransactionId());
			this.notifyFailure(orderTransaction, FSPConstants.NETSUITE_ERROR,
					"Error occurred in sending email to the customer for cash sale/invoice: "
							+ orderTransaction.getNetsuiteTransId(),
					FSPConstants.BILLING_WARN_LEVEL);
		}

	}

	/**
	 * Method to return authHeader
	 * 
	 * @return the authHeader
	 */
	public String getAuthHeader() {
		/* Create authHeader with account, user and password, if null */
		if (this.authHeader == null) {
			try {
				Properties nsProps = NetSuiteProperties.getProperties();
				StringBuilder auth = new StringBuilder("NLAuth nlauth_account=")
						.append(nsProps.getProperty(FSPConstants.NS_ACCOUNT))
						.append(", nlauth_email=" + nsProps.getProperty(FSPConstants.NS_USER))
						.append(", nlauth_signature=")
						.append(nsProps.getProperty(FSPConstants.NS_PWD));

				this.authHeader = auth.toString();
			} catch (Exception exc) {
				LOGGER.error("Error Occurred in creating auth header ", exc);
			}
		}
		return this.authHeader;
	}

	/**
	 * @param authHeader
	 *            the authHeader to set
	 */
	public void setAuthHeader(String authHeader) {
		this.authHeader = authHeader;
	}

	/**
	 * Method to get netsuite transaction type based on orderTrasnaction type
	 * 
	 * @param trasanctionType
	 */
	private String getNSType(String transactionType) {
		return (transactionType.equals(FSPConstants.INVOICE_TRANSACTION_TYPE) ? FSPConstants.INVOICE_NS_TRANSACTION_TYPE
				: FSPConstants.CASHSALE_NS_TRANSACTION_TYPE);
	}

	/**
	 * Method to get netsuite credit card id based on billingSchedule/order
	 * 
	 * @param orderTransaction
	 */
	private Long getNSCreditCardId(OrderTransaction orderTransaction) {
		Long retVal = null;
		if (orderTransaction.getBillingSchedule() == null) {
			if (orderTransaction.getOrderGroup().getOrders().getEntityCreditCard() != null)
				retVal = (long) orderTransaction.getOrderGroup().getOrders().getEntityCreditCard()
						.getNetsuiteCardId();

		} else {
			retVal = (long) orderTransaction.getBillingSchedule().getEntityCreditCard()
					.getNetsuiteCardId();
		}
		LOGGER.info("getNSCreditCardId(orderTransaction)- Credit card Id: " + retVal);

		return retVal;
	}

	/**
	 * Method to notify failure in processing billing transaction
	 * 
	 * @param orderTransaction
	 * @param code
	 * @param message
	 */
	private void notifyFailure(OrderTransaction orderTransaction, String code, String message) {
		this.notifyFailure(orderTransaction, code, message, FSPConstants.BILLING_ERROR_LEVEL);
	}

	/**
	 * Method to notify failure/warning in processing billing transaction
	 * 
	 * @param orderTransaction
	 * @param code
	 * @param message
	 */
	private void notifyFailure(OrderTransaction orderTransaction, String code, String message,
			String level) {
		Integer orderTransactionId = null;
		BillingSchedule billingSchedule = null;

		if (orderTransaction != null) {
			orderTransactionId = orderTransaction.getOrderTransactionId();
			billingSchedule = orderTransaction.getBillingSchedule();
		}

		if (billingSchedule != null) {
			failureHandler.notifyBillingFailure(billingSchedule, orderTransactionId, code, message,
					level);
		} else {
			failureMessages.append(message).append("\n");
		}
	}

	/**
	 * Method to email transaction and usage report to customer
	 * 
	 * @param orderTransaction
	 * @param cdrList
	 * @return boolean
	 */
	private boolean emailTransactionAndUsage(OrderTransaction orderTransaction) {
		boolean retVal = false;
		try {
			List<ServerCdrUsageDTO> serverCdrUsageDTOList = new ArrayList<ServerCdrUsageDTO>();
			for (OrderTransactionItem transactionItem : orderTransaction.getOrderTransactionItems()) {
				ServerCdrUsageDTO serverCdrUsageDTO = new ServerCdrUsageDTO(transactionItem
						.getOrderGroup().getOrderGroupId());

				if (!serverCdrUsageDTOList.contains(serverCdrUsageDTO)) {
					serverCdrUsageDTO = this.cdrUsageService.getBillableCdr(
							transactionItem.getOrderGroup(), orderTransaction.getBillingSchedule());
					if (serverCdrUsageDTO != null) {
						serverCdrUsageDTOList.add(serverCdrUsageDTO);
					}

				}

			}
			/*
			 * Check if billingSchedule object is set in orderTransaction. if yes 1) Create customer
			 * usage billing report using jasper service 2) Upload pdf on Netsuite file cabinet
			 */
			Long fileId = null;
			if (orderTransaction.getBillingSchedule() != null) {
				/* Generate report contents using jasper service */
				byte[] reportData = null;
				try {
					reportData = cdrUsageService.generateCdrUsageReport(
							orderTransaction.getBillingSchedule(), serverCdrUsageDTOList);
				} catch (Exception exc) {
					LOGGER.error(
							"Error occurred in generating customer usage report for cash sale/ invoice id:"
									+ orderTransaction.getNetsuiteTransId()
									+ " , orderTransactionId:"
									+ orderTransaction.getOrderTransactionId(), exc);
					this.notifyFailure(orderTransaction, FSPConstants.REPORT_ERROR,
							"Error occurred in generating customer usage report for cash sale/ invoice id:"
									+ orderTransaction.getNetsuiteTransId(),
							FSPConstants.BILLING_WARN_LEVEL);
				}

				if (reportData == null) {
					LOGGER.warn("Customer usage report data is EMPTY ");
				} else {
					fileId = this.createCustomerBillingReport(orderTransaction, reportData);
				}
			}

			/*
			 * Email transaction to the customer.Incluce customer usage report, if exists
			 */
			this.emailTransaction(orderTransaction, fileId, getNSType(orderTransaction.getType()));
			LOGGER.info("Email sent with transaction and usage report");
		} catch (Exception exc) {
			LOGGER.warn(
					"Error occurred in emailing transaction / generating usage report, orderTransactionId:"
							+ orderTransaction.getOrderTransactionId(), exc);
			this.notifyFailure(orderTransaction, FSPConstants.NETSUITE_ERROR, exc.getMessage(),
					FSPConstants.BILLING_WARN_LEVEL);
		}

		return retVal;
	}

	/**
	 * Method to get failure messages
	 * 
	 * @return failureMessages
	 */
	public String geFailureMessage() {
		return this.failureMessages.toString();
	}

	/**
	 * Method to get sales order RecordRef
	 * 
	 * @return recordRef
	 */
	private RecordRef initSalesOrderRecordRef(Long salesOrderId) {
		RecordRef recordRef = new RecordRef();
		recordRef.setInternalId(salesOrderId.toString());
		recordRef.setType(RecordType.salesOrder);
		return recordRef;
	}

	/**
	 * Method to get line item description
	 * 
	 * @return description
	 */
	private String getLineItemDescription(OrderTransactionItem item) {
		StringBuffer description = new StringBuffer(item.getDescription());
		Integer usageCategory = this.bundleDAO
				.getBundleCategoryIdByName(FSPConstants.BUNDLE_USAGE_CATEGORY);

		if (item.getOrderGroup().getOrders().getOrderGroups().size() > 1) {
			description.insert(0, item.getOrderGroup().getEntityAddressByShippingAddressId()
					.getAddr1()
					+ FSPConstants.COLON_SPACE);
		}

		if ((usageCategory != null)
				&& usageCategory.equals(item.getBundle().getBundleCategory().getBundleCategoryId())) {
			description.append(" (").append(item.getMonthlyUsage()).append(FSPConstants.SPACE)
					.append(FSPConstants.USAGE_MIN).append(")");
		}

		return description.toString();
	}

	/**
	 * Method to set values in cashSale/invoice objects based on orderTransactionItem data
	 * 
	 * @param orderTransactionItem
	 * @param invoice
	 */
	private void populateInvoiceData(OrderTransactionItem item, Object invoice) throws Exception {
		ObjectUtils.setFieldValue(invoice, "Item",
				this.netSuiteWS.initRecordRef(item.getNetsuiteItemId()));
		ObjectUtils.setFieldValue(invoice, "Amount", ObjectUtils.round(item.getAmount(), 2));
		ObjectUtils.setFieldValue(invoice, "Rate", item.getListPrice().toString());
		ObjectUtils.setFieldValue(invoice, "Description", this.getLineItemDescription(item));
		ObjectUtils.setFieldValue(invoice, "IsTaxable", false);
		ObjectUtils.setFieldValue(invoice, "Quantity", (double) ((item.getQuantity() == 0) ? 1
				: item.getQuantity()));
		ObjectUtils.setFieldValue(invoice, "Price",
				this.netSuiteWS.initRecordRef(FSPConstants.NETSUITE_PRICE_CUSTOM));

		if (item.getBundle().getName().equals(FSPConstants.BUNDLE_NAME_DOWNPAYMENT)) {
			Date contractStartDate = item.getOrderTransaction().getOrderGroup().getOrders()
					.getContractStartDate();

			if ((contractStartDate != null)
					&& (item.getOrderTransaction().getOrderGroup().getOrders().getTermInMonths() > 0)) {
				ObjectUtils.setFieldValue(invoice, "RevRecSchedule",
						this.netSuiteWS.initRecordRef(45));

				Calendar startDate = Calendar.getInstance();
				startDate.setTime(item.getOrderTransaction().getOrderGroup().getOrders()
						.getContractStartDate());

				Calendar endDate = Calendar.getInstance();
				endDate.setTime(item.getOrderTransaction().getOrderGroup().getOrders()
						.getContractStartDate());
				endDate.add(Calendar.MONTH, item.getOrderTransaction().getOrderGroup().getOrders()
						.getTermInMonths());

				if (invoice instanceof InvoiceItem) {
					((InvoiceItem) invoice).setRevRecStartDate(startDate);
					((InvoiceItem) invoice).setRevRecEndDate(endDate);
				} else if (invoice instanceof CashSaleItem) {
					((CashSaleItem) invoice).setRevRecStartDate(startDate);
					((CashSaleItem) invoice).setRevRecEndDate(endDate);
				}

			}

		}

	}

	/**
	 * Method to update order balance based on orderTransaction amount
	 * 
	 * @param orderTransaction
	 */
	private void updateOrderBalance(OrderTransaction orderTransaction) {
		try {
			Orders order = orderDAO.loadOrder(orderTransaction.getOrderGroup().getOrders()
					.getOrderId());

			if (order.getContractBalance().compareTo(orderTransaction.getAmount()) > 0) {
				order.setContractBalance(order.getContractBalance().subtract(orderTransaction.getAmount()));
			} else {
				LOGGER.warn("Order Balance is less than transaction amount, setting order balance to 0, current balance:  "
						+ order.getContractBalance()
						+ ", Transaction amount: "
						+ orderTransaction.getAmount());
				order.setContractBalance(BigDecimal.ZERO);
			}

			this.orderDAO.saveOrder(order);
		} catch (Exception exc) {
			LOGGER.error("Error occurred in updating order balance for cash sale/ invoice id:"
					+ orderTransaction.getNetsuiteTransId() + " , orderTransactionId:"
					+ orderTransaction.getOrderTransactionId(), exc);
			this.notifyFailure(orderTransaction, FSPConstants.REPORT_ERROR,
					"Error occurred in updating order balance for cash sale/ invoice id:"
							+ orderTransaction.getNetsuiteTransId(),
					FSPConstants.BILLING_WARN_LEVEL);
		}

	}

}
