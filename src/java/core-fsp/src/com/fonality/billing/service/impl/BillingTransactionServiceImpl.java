package com.fonality.billing.service.impl;

import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fonality.billing.service.BillingProcessorService;
import com.fonality.billing.service.BillingTransactionService;
import com.fonality.billing.util.BillingFailureHandler;
import com.fonality.bu.entity.BillingSchedule;
import com.fonality.dao.BillingScheduleDAO;
import com.fonality.util.FSPConstants;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      BillingTransactionServiceImpl.java
 //* Revision:      1.0
 //* Author:        Sam Chapiro
 //* Created On:    Feb 12, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   This Service class gets all Scheduled to Bill Customers /Servers 
 *               and invokes BiilingProcecssorService to process each the records.
 */
/********************************************************************************/

@Service
public class BillingTransactionServiceImpl implements BillingTransactionService {

	private static final Logger LOGGER = Logger.getLogger(BillingTransactionServiceImpl.class
			.getName());

	@Autowired
	public BillingProcessorService billingProcessorService;
	@Autowired
	public BillingScheduleDAO billingScheduleDAO;
	@Autowired
	public BillingFailureHandler sendMail;

	/**
	 * Get BillingSchedule records, ready to be billed. Invokes BillingProcessor to process each of
	 * them.
	 * 
	 * @param no
	 *            parameters taken
	 * @return void
	 */
	public void processAllScheduled() {

		long status = 0;
		List<BillingSchedule> billingScheduleItems = null;

		try {
			// Reading SCHEDULE_TRANSACTION table
			billingScheduleItems = getScheduledToBill();

			if (billingScheduleItems == null || billingScheduleItems.size() == 0) {
				LOGGER.info("No Scheduled Billing found");

			}
			for (BillingSchedule billingSchedule : billingScheduleItems) {

				LOGGER.info("Start processing - BillingScheduleId: "
						+ billingSchedule.getBillingScheduleId());

				status = billingProcessorService.bsProcessor(billingSchedule);
				if (status == FSPConstants.EXIT_BILLING_SUCCESS) {
					// Setting billing_schedule.status to PROCESSED_ALL. 
					billingSchedule.setBillingScheduleId(billingSchedule.getBillingScheduleId());
					billingSchedule.setStatus(FSPConstants.BILLING_SCHEDULE_PROCESSED_ALL);
					billingScheduleDAO.saveBillingSchedule(billingSchedule);

					LOGGER.info("Scheduled transaction Successful - - BillingScheduleId: "
							+ billingSchedule.getBillingScheduleId());

				} else if (status == FSPConstants.EXIT_TAX_SUCCESS) {
					billingSchedule.setBillingScheduleId(billingSchedule.getBillingScheduleId());
					billingSchedule.setStatus(FSPConstants.BILLING_SCHEDULE_PROCESSED_TAX);
					billingScheduleDAO.saveBillingSchedule(billingSchedule);

					LOGGER.info("Scheduled transaction Tax processed. BillingScheduleId: "
							+ billingSchedule.getBillingScheduleId());
				} else {
					/*
					 * sendMail.notifyBillingFailure(billingSchedule, null, FSPConstants.DATA_ERROR,
					 * "Processing BillingSchedule record Failed ",
					 * FSPConstants.BILLING_ERROR_LEVEL);
					 */
					LOGGER.error("Processing BillingSchedule record Failed - - BillingScheduleId: "
							+ billingSchedule.getBillingScheduleId());
				}

			}
		} catch (Exception e) {
			sendMail.notifyBillingFailure(null, null, FSPConstants.DATA_ERROR,
					"Failure to read/process  Billing Schedule records ",
					FSPConstants.BILLING_ERROR_LEVEL);
			LOGGER.error(
					"Failure to read/process  Billing Schedule records - Exception: "
							+ e.getMessage(), e);
		}

	}

	/**
	 * Reads BillingSchedule records, ready to b billed.
	 * 
	 * @param no
	 *            parameters taken
	 * @return collection of BillingSchedule objects.
	 */
	public List<BillingSchedule> getScheduledToBill() throws Exception {

		List<BillingSchedule> billingCustomers;

		billingCustomers = billingScheduleDAO.getCustomerListId();

		//Test output only.	
		for (BillingSchedule bs : billingCustomers) {
			// System.out.println("BillingTransactionImpl.getScheduledToBill(): Scheduled serverId -  "+bs.getServerId());
		}
		return billingCustomers;
	}

}
