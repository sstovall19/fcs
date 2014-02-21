package com.fonality.service;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      EmailService.java
 //* Revision:      1.0
 //* Author:        Satya Boddu
 //* Created On:    Nov 27, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   Application email service
 /********************************************************************************/

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang.StringUtils;
import org.apache.velocity.VelocityContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.bu.entity.BillingSchedule;
import com.fonality.dao.ContactDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.search.CdrUsageVO;
import com.fonality.service.common.ContentService;
import com.fonality.util.DateUtils;
import com.fonality.util.EmailProperties;
import com.fonality.util.FSPConstants;
import com.fonality.util.ObjectUtils;
import com.fonality.util.SendMail;

@Service
@Transactional
public class EmailService {

	@Autowired
	public ContactDAO contactDAO;

	@Autowired
	public ContentService contentService;

	@Autowired
	public OrderDAO orderDAO;

	private static final Map<String, HashMap<String, String>> emailConfigMap = new HashMap<String, HashMap<String, String>>();

	/**
	 * This helper method will grab the necessary properties for sending the email notification to
	 * the specified addresses. It will also determine the format in which the email will be sent
	 * [Plain Text | HTML].
	 * 
	 * @param subject
	 * @param message
	 * @param sendToAddresses
	 * @throws Exception
	 * @return void
	 */
	public void sendMail(String subject, String message, String fromAddress,
			String[] sendToAddresses) throws Exception {
		this.sendMail(subject, message, fromAddress, sendToAddresses, null, null);
	}

	/**
	 * This helper method will grab the necessary properties for sending the email notification to
	 * the specified addresses. It will also determine the format in which the email will be sent
	 * [Plain Text | HTML].
	 * 
	 * @param subject
	 * @param message
	 * @param sendToAddresses
	 * @param sendCCAddresses
	 * @throws Exception
	 * @return void
	 */
	public void sendMail(String subject, String message, String fromAddress,
			String[] sendToAddresses, String[] sendCCAddresses, Map<String, byte[]> attachmentMap)
			throws Exception {
		SendMail.getInstance().postMail(message, sendToAddresses, sendCCAddresses, subject,
				fromAddress, attachmentMap);
	}

	/**
	 * Method to send quote notification failure email
	 * 
	 * @param inputObj
	 * @param type
	 * @throws Exception
	 * @return void
	 */
	public void sendFailureEmail(String errorMessage, Date date, String type) throws Exception {

		VelocityContext context = new VelocityContext();
		context.put(FSPConstants.TIME,
				DateUtils.convertDateToString(date, DateUtils.USA_DATETIME_AMPM));
		context.put(FSPConstants.ERROR_DESC, errorMessage);

		String message = contentService.loadEmailContent(context,
				this.getConfigValue(type, FSPConstants.EMAIL_TEMPLATE));

		this.sendMail(this.getConfigValue(type, FSPConstants.EMAIL_SUBJECT), message, this
				.getConfigValue(type, FSPConstants.EMAIL_FROM), StringUtils.split(
				this.getConfigValue(type, FSPConstants.EMAIL_TO), FSPConstants.COMMA), StringUtils
				.split(this.getConfigValue(type, FSPConstants.EMAIL_CC), FSPConstants.COMMA), null);

	}

	/**
	 * Method to send cdr usage email
	 * 
	 * @param pdfBytes
	 * @param usageVO
	 * @throws Exception
	 * @return void
	 */
	public void sendCustomerCdrUsageEmail(byte[] pdfBytes, CdrUsageVO usageVO) throws Exception {

		String[] sendToAddresses = new String[] { usageVO.getEmailAddress() };
		String[] sendCcAddresses = new String[] { (String) EmailProperties.getProperties().get(
				FSPConstants.CDR_USAGE_EMAIL_CC) };

		StringBuffer custName = new StringBuffer(usageVO.getLastName()).append(
				FSPConstants.COMMA_SPACE).append(usageVO.getFirstName());

		VelocityContext context = new VelocityContext();
		context.put(FSPConstants.CUSTOMER_NAME, custName.toString());
		context.put(FSPConstants.START_DATE,
				DateUtils.convertDateToString(usageVO.getStartDate(), DateUtils.USA_DATETIME));
		context.put(FSPConstants.END_DATE,
				DateUtils.convertDateToString(usageVO.getEndDate(), DateUtils.USA_DATETIME));

		String message = contentService.loadEmailContent(context, FSPConstants.CDR_USAGE_TEMPLATE);

		Map<String, byte[]> attachmentMap = new HashMap<String, byte[]>();
		attachmentMap.put(FSPConstants.CDR_USAGE_ATTACHMENT_NAME, pdfBytes);

		this.sendMail(FSPConstants.CDR_USAGE_EMAIL_SUBJECT, message, (String) EmailProperties
				.getProperties().get(FSPConstants.CDR_USAGE_EMAIL_FROM), sendToAddresses,
				sendCcAddresses, attachmentMap);

	}

	/**
	 * Method to send billing notification failure email
	 * 
	 * @param message
	 * @param type
	 * @throws Exception
	 * @return void
	 */
	public void sendBillingFailureEmail(BillingSchedule billingSchedule,
			Integer orderTransactionId, String code, String errorMessage, String level)
			throws Exception {

		VelocityContext context = new VelocityContext();
		context.put(
				FSPConstants.BILLING_SCHEDULE_ID,
				(billingSchedule == null) ? FSPConstants.EMPTY : String.valueOf(billingSchedule
						.getBillingScheduleId()));
		context.put(FSPConstants.ORDER_TRANS_ID, (orderTransactionId == null) ? FSPConstants.EMPTY
				: String.valueOf(orderTransactionId));
		context.put(FSPConstants.ERROR_TYPE, code);
		context.put(FSPConstants.ERROR_DESC, errorMessage);

		String message = contentService.loadEmailContent(context,
				this.getBillingFailureTemplate(level));

		this.sendMail(this.getBillingFailureSubject(level), message, (String) EmailProperties
				.getProperties().get(FSPConstants.BILLING_FAILURE_FROM_ADDRESS), StringUtils.split(
				this.getBillingFailureTo(level), FSPConstants.COMMA), StringUtils.split(
				this.getBillingFailureCc(level), FSPConstants.COMMA), null);

	}

	/**
	 * Method to get billing failure template based on error level
	 * 
	 * @param level
	 * @return template
	 */
	private String getBillingFailureTemplate(String level) {
		return level.equals(FSPConstants.BILLING_WARN_LEVEL) ? FSPConstants.BILLING_WARNING_TEMPLATE
				: FSPConstants.BILLING_FAILURE_TEMPLATE;
	}

	/**
	 * Method to get billing failure subject based on error level
	 * 
	 * @param level
	 * @return subject
	 */
	private String getBillingFailureSubject(String level) {
		return level.equals(FSPConstants.BILLING_WARN_LEVEL) ? FSPConstants.BILLING_WARNING_EMAIL_SUBJECT
				: FSPConstants.BILLING_FAILURE_EMAIL_SUBJECT;
	}

	/**
	 * Method to get billing failure to address based on error level
	 * 
	 * @param level
	 * @return subject
	 */
	private String getBillingFailureTo(String level) throws Exception {
		return level.equals(FSPConstants.BILLING_WARN_LEVEL) ? (String) EmailProperties
				.getProperties().get(FSPConstants.BILLING_WARNING_TO_ADDRESS)
				: (String) EmailProperties.getProperties().get(
						FSPConstants.BILLING_FAILURE_TO_ADDRESS);
	}

	/**
	 * Method to get billing failure to address based on error level
	 * 
	 * @param level
	 * @return subject
	 */
	private String getBillingFailureCc(String level) throws Exception {
		return level.equals(FSPConstants.BILLING_WARN_LEVEL) ? (String) EmailProperties
				.getProperties().get(FSPConstants.BILLING_WARNING_CC_ADDRESS)
				: (String) EmailProperties.getProperties().get(
						FSPConstants.BILLING_FAILURE_CC_ADDRESS);
	}

	/**
	 * Method to initialize email config map. Add config parameters based on each failure type
	 */
	private void initializeMap() {
		try {
			HashMap<String, String> quoteMap = new HashMap<String, String>();
			quoteMap.put(FSPConstants.EMAIL_SUBJECT, FSPConstants.QUOTE_EMAIL_SUBJECT);
			quoteMap.put(FSPConstants.EMAIL_TEMPLATE, FSPConstants.QUOTE_FAILURE_TEMPLATE);
			quoteMap.put(FSPConstants.EMAIL_TO,
					(String) EmailProperties.getProperties().get(FSPConstants.QUOTE_EMAIL_TO));
			quoteMap.put(FSPConstants.EMAIL_CC,
					(String) EmailProperties.getProperties().get(FSPConstants.QUOTE_EMAIL_CC));
			quoteMap.put(FSPConstants.EMAIL_FROM,
					(String) EmailProperties.getProperties().get(FSPConstants.QUOTE_EMAIL_FROM));

			HashMap<String, String> orderMap = new HashMap<String, String>();
			orderMap.put(FSPConstants.EMAIL_SUBJECT, FSPConstants.ORDER_EMAIL_SUBJECT);
			orderMap.put(FSPConstants.EMAIL_TEMPLATE, FSPConstants.ORDER_FAILURE_TEMPLATE);
			orderMap.put(FSPConstants.EMAIL_TO,
					(String) EmailProperties.getProperties().get(FSPConstants.ORDER_EMAIL_TO));
			orderMap.put(FSPConstants.EMAIL_CC,
					(String) EmailProperties.getProperties().get(FSPConstants.ORDER_EMAIL_CC));
			orderMap.put(FSPConstants.EMAIL_FROM,
					(String) EmailProperties.getProperties().get(FSPConstants.ORDER_EMAIL_FROM));

			HashMap<String, String> provMap = new HashMap<String, String>();
			provMap.put(FSPConstants.EMAIL_SUBJECT, FSPConstants.PROV_EMAIL_SUBJECT);
			provMap.put(FSPConstants.EMAIL_TEMPLATE, FSPConstants.PROV_FAILURE_TEMPLATE);
			provMap.put(FSPConstants.EMAIL_TO,
					(String) EmailProperties.getProperties().get(FSPConstants.PROV_EMAIL_TO));
			provMap.put(FSPConstants.EMAIL_CC,
					(String) EmailProperties.getProperties().get(FSPConstants.PROV_EMAIL_CC));
			provMap.put(FSPConstants.EMAIL_FROM,
					(String) EmailProperties.getProperties().get(FSPConstants.PROV_EMAIL_FROM));

			emailConfigMap.put(FSPConstants.EMAIL_QUOTE_FAILURE_TYPE, quoteMap);
			emailConfigMap.put(FSPConstants.EMAIL_ORDER_FAILURE_TYPE, orderMap);
			emailConfigMap.put(FSPConstants.EMAIL_PROV_FAILURE_TYPE, provMap);

		} catch (Exception exc) {
			exc.printStackTrace();
		}
	}

	/**
	 * Method to get email config value based on type and key
	 * 
	 * @param type
	 * @param key
	 * @return value
	 */
	private String getConfigValue(String type, String key) {
		if (!ObjectUtils.isValid(emailConfigMap))
			this.initializeMap();
		return emailConfigMap.get(type).get(key);
	}

}
