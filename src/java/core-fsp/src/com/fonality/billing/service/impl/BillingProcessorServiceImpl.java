package com.fonality.billing.service.impl;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionException;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import com.fonality.billing.DTO.BillableCdrDTO;
import com.fonality.billing.service.BillingProcessorService;
import com.fonality.billing.service.CdrService;
import com.fonality.billing.util.BillingFailureHandler;
import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.Bundle;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.OrderTransaction;
import com.fonality.bu.entity.OrderTransactionItem;
import com.fonality.bu.entity.PaymentMethod;
import com.fonality.dao.BundleDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.OrderTransactionDAO;
import com.fonality.dao.OrderTransactionItemDAO;
import com.fonality.dao.UnboundCdrTestDAO;
import com.fonality.service.BillingScheduleService;
import com.fonality.service.InvoiceService;
import com.fonality.service.OrderTransactionLineItemService;
import com.fonality.util.FSPConstants;

//import org.hibernate.TransactionException;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      BillingProcessorServiceImpl.java
 //* Revision:      1.0
 //* Author:        Sam Chapiro
 //* Created On:    Feb 12, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   This Service class implements the major workflow of Billable Invoice 
 *        preparation for each schedule Customers.  
 *        It invokes CdrService, TaxCalucalatorService and InvoiceService
 *   	  needed to process Customer details to created a billable Invoice in Net Suite.
 */
/********************************************************************************/

@Service
@Transactional(propagation = Propagation.REQUIRED, rollbackFor = TransactionException.class)
public class BillingProcessorServiceImpl implements BillingProcessorService {

	private static final Logger LOGGER = Logger.getLogger(BillingScheduleService.class.getName());

	@Autowired
	private OrderTransactionDAO orderTransactionDAO;
	@Autowired
	public OrderTransactionItemDAO orderTransactionItemDAO;
	@Autowired
	public UnboundCdrTestDAO unboundCdrTestDAO;
	@Autowired
	public OrderTransactionLineItemService taxCalculatorService;
	@Autowired
	public InvoiceService invoiceService;
	@Autowired
	public CdrService cdrService;
	@Autowired
	public BundleDAO bundleDAO;
	@Autowired
	public BillingFailureHandler sendMail;
	@Autowired
	public OrderGroupDAO orderGroupDAO;

	/**
	 * Implements major workflow of creation invoice for scheduled Customer.
	 * 
	 * @param BillingSchedule
	 * @return long
	 */
	public long bsProcessor(BillingSchedule bs) {

		OrderTransaction ot = null;
		boolean taxReturn = false;
		boolean faxReturn = false;
		long status = FSPConstants.EXIT_BILLING_FAILURE;
		boolean invoiceReturn = false;
		List<BillableCdrDTO> billableCdrDTOList = null;
		List<OrderGroup> orderGroupList = null;
		boolean isFirstOrderGroup = true;

		// Usage related
		HashMap<String, Integer> hmUsage = new HashMap<String, Integer>();
		HashMap<String, BigDecimal> hmAmount = new HashMap<String, BigDecimal>();

		try {

			// Checking if this transaction has Tax processed in previous run
			if (bs.getStatus().equals(FSPConstants.BILLING_SCHEDULE_STATUS_NOT_PROCESSED)) {

				orderGroupList = orderGroupDAO.getOrderGroupListByOrderId(bs.getOrders()
						.getOrderId());
				if (orderGroupList != null && orderGroupList.size() !=0) {
					for (OrderGroup og : orderGroupList) {

						// Creating Order Transaction in Order_transaction table
						if (bs != null && isFirstOrderGroup) {
							isFirstOrderGroup = false;
							ot = createOrderTransaction(bs, og);
						}

						if (ot != null) {

							// 1.1 Process all unbound CDR for given Server and filter
							// out Billable CDR.
							billableCdrDTOList = cdrService.getBillableCDR(og.getServerId(), bs,
									hmUsage, hmAmount);

							// 1.2 Capture summary of FAX pages, sent / received.
							cdrService.getFaxUsage(ot.getServerId(), bs, hmUsage, hmAmount);

							// 2. Creating Usage Line Items in the OrderTransactionItems
							createUsageLineItems(ot, og, hmUsage, hmAmount);

							// 3. Running Tax Calculator
							taxReturn = taxCalculatorService.calculateTransactionTotal(
									ot.getOrderTransactionId(), og, billableCdrDTOList,
									bs.getType());

							if (taxReturn == false) {
								status = FSPConstants.EXIT_TAX_FAILURE;
								// Rollback previous transactions as Tax Calculator failed.
								TransactionAspectSupport.currentTransactionStatus()
										.setRollbackOnly();
								LOGGER.error("bsProcessor - Rolled back Transaction due to TaxCalculator failure."
										+ " Transaction Id: " + ot.getOrderTransactionId());
								LOGGER.error("bsProcessor - Create Order Transaction failed.");

								break;
							} else {
								status = FSPConstants.EXIT_BILLING_SUCCESS;
							}				
						} else {
							status = FSPConstants.EXIT_BILLING_FAILURE;
							LOGGER.error("bsProcessor - Create Order Transaction failed.");
						}
					} // end of - looping over orderGroup
					
 					// Running Invoice service.
					if (status == FSPConstants.EXIT_BILLING_SUCCESS) {
						status = runInvoiceService(bs, ot);
						if (status == FSPConstants.EXIT_BILLING_FAILURE) {
							status = FSPConstants.EXIT_TAX_SUCCESS;
						}
					}

				}
				// Running InvoiceServie for Order transaction having Usage and Tax done in previous run.	
			} else if (bs.getStatus().equals(FSPConstants.BILLING_SCHEDULE_PROCESSED_TAX)) {				
				ot = bs.getOrderTransactions().iterator().next();
				if (ot != null) {
					status = runInvoiceService(bs, ot);	
				}
			}
		} catch (Exception e) {
			status = FSPConstants.EXIT_BILLING_FAILURE;
			TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();

			LOGGER.error("bsProcessor - Exception: " + e.getMessage(), e);
			LOGGER.error("bsProcessor - Rolled back Transaction: " + bs.getBillingScheduleId());

			sendMail.notifyBillingFailure(bs, ot.getOrderTransactionId(), FSPConstants.DATA_ERROR,
					"Error in Billing Schedule Proccessing: " + e.getMessage(),
					FSPConstants.BILLING_ERROR_LEVEL);

		}

		return status;
	}

	/**
	 * Get BillingSchedule records, ready to be billed. Invokes BillingProcessor to process each of
	 * them.
	 * 
	 * @param no
	 *            parameters taken
	 * @return void
	 */
	private long runInvoiceService(BillingSchedule bs, OrderTransaction ot) {

		boolean invoiceReturn = false;
		long status = FSPConstants.EXIT_BILLING_FAILURE;

		try {
			invoiceReturn = invoiceService.createInvoice(ot.getOrderTransactionId());
			if (invoiceReturn) {
				status = FSPConstants.EXIT_BILLING_SUCCESS;
				LOGGER.info("bsProcessor - Inoice generated for Transaction: "
						+ ot.getOrderTransactionId());
				// Loading the updated orderTransaction object
				ot = orderTransactionDAO.loadOrderTransaction(ot.getOrderTransactionId());

			} else {
				LOGGER.error("bsProcessor - Inoice failed for Transaction: "
						+ ot.getOrderTransactionId());
			}
		} catch (Exception e) {
			sendMail.notifyBillingFailure(bs, ot.getOrderTransactionId(), FSPConstants.DATA_ERROR,
					"Error during  Run Invoice Service: " + e.getMessage(),
					FSPConstants.BILLING_ERROR_LEVEL);
			LOGGER.error("bsProcessor - Exception from Invoice Service: " + e.getMessage());
		}

		return status;
	}

	/**
	 * Create OrderTransaction Invokes BillingProcessor to process each of them.
	 * 
	 * @param no
	 *            parameters taken
	 * @return void
	 */
	private OrderTransaction createOrderTransaction(BillingSchedule bs, OrderGroup orderGroup)
			throws Exception {

		OrderTransaction ot = null;

		LOGGER.info("Start Creating OT for serverId - " + orderGroup.getServerId());
		
		// Creating OrderTransaction
		ot = new OrderTransaction();
		OrderTransaction createdOT = null;

		PaymentMethod paymentMethod = bs.getPaymentMethod();

		BigDecimal bd = new BigDecimal(0);

		ot.setServerId(orderGroup.getServerId());
		ot.setCustomerId(bs.getCustomerId());
		ot.setOrderGroup(orderGroup);
		ot.setPaymentMethod(paymentMethod);
		ot.setAmount(bd);
		ot.setBillingSchedule(bs);
		if (paymentMethod.getPaymentMethodId() == 1) {
			ot.setType(FSPConstants.CASHSALE_TRANSACTION_TYPE);
		} else {
			ot.setType(FSPConstants.INVOICE_TRANSACTION_TYPE);
		} 
		// Status not used in Billing system, but only when the Order_transaction 
		//records processed by outside of billing services forming invoice.
		ot.setStatus(FSPConstants.ORDER_TRANSACTION_STATUS_READY);
		createdOT = orderTransactionDAO.saveOrderTransaction(ot);

		if (createdOT != null) {
			LOGGER.info("Created Order Transaction. Id - " + createdOT.getOrderTransactionId());
		}

		return createdOT;
	}

	/**
	 * Create OrderTransaction Line Items, using usage summary, if available.
	 * 
	 * @param orderTransaction
	 * @param hmUsage
	 * @param hmAmount
	 * @return void
	 */
	private void createUsageLineItems(OrderTransaction ot, OrderGroup og,
			HashMap<String, Integer> hmUsage, HashMap<String, BigDecimal> hmAmount)
			throws Exception {

		OrderTransactionItem oti = null;
		long netSuiteItemId = 0;

		// 2. Getting from DB BundleId and Bundle Description per usage type
		String bundleName = "%_usage";

		List<Bundle> usageBundleList = bundleDAO.getBundleByPartialName(bundleName);

		for (Bundle usageBundle : usageBundleList) {

			oti = new OrderTransactionItem();

			oti.setOrderTransaction(ot);
			oti.setBundle(usageBundle);
			oti.setDescription(usageBundle.getDescription());
			oti.setAmount(hmAmount.get(usageBundle.getName()));
			oti.setMonthlyUsage(hmUsage.get(usageBundle.getName()));
			oti.setListPrice(BigDecimal.ZERO);
			oti.setOrderGroup(og);
			if (usageBundle.getNetsuiteMrcId() == null) {
				oti.setNetsuiteItemId(0);
			} else {
				oti.setNetsuiteItemId(usageBundle.getNetsuiteMrcId());
			}
			oti = orderTransactionItemDAO.saveOrderTransactionItem(oti);
			if (oti != null) {
				LOGGER.info(" Created Order Transaction Item. Id - " + oti.getOrderTransactionItemId());
			}
		}

	}

}
