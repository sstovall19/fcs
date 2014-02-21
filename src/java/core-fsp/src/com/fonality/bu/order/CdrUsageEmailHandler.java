package com.fonality.bu.order;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      CdrUsageEmailHandler.java
 //* Revision:      1.1
 //* Author:        Satya Boddu
 //* Created On:    Feb 15, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   BU to email cdr usage data 
 */
/********************************************************************************/

import java.io.IOException;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import com.fonality.bu.AbstractBusinessUnit;
import com.fonality.bu.entity.json.Input;
import com.fonality.search.CdrUsageVO;
import com.fonality.service.CdrUsageService;
import com.fonality.util.FSPConstants;
import com.fonality.util.ObjectUtils;

public class CdrUsageEmailHandler extends AbstractBusinessUnit {

	public CdrUsageService cdrUsageService = null;
	private static final Logger LOGGER = Logger.getLogger(CdrUsageEmailHandler.class.getName());

	/**
	 * @param args
	 * @throws IOException
	 */
	public static void main(String[] args) throws IOException {
		CdrUsageEmailHandler self = new CdrUsageEmailHandler();
		self.mainMethod(args);
	}

	@Override
	public String execute(Input inputObj) {
		String retVal = null;
		this.cdrUsageService = (CdrUsageService) context.getBean("cdrUsageService");

		if (!ObjectUtils.isValid(inputObj)) {
			retVal = FSPConstants.INPUT_EMPTY;
		} else if (!ObjectUtils.isValid(inputObj.getCustomerId())) {
			retVal = FSPConstants.CUSTOMER_EMPTY;
		} else if (!ObjectUtils.isValid(inputObj.getServerId())) {
			retVal = FSPConstants.SERVER_EMPTY;
		} else if (!StringUtils.isNumeric(inputObj.getServerId())) {
			retVal = FSPConstants.INVALID_SERVER;
		} else if (!ObjectUtils.isValid(inputObj.getStartDate())) {
			retVal = FSPConstants.START_DATE_EMPTY;
		} else if (!ObjectUtils.isValid(inputObj.getEndDate())) {
			retVal = FSPConstants.END_DATE_EMPTY;
		} else {
			try {
				CdrUsageVO usageVO = new CdrUsageVO(inputObj);
				if (usageVO.getStartDate() == null)
					retVal = FSPConstants.INVALID_START_DATE;
				else if (usageVO.getEndDate() == null)
					retVal = FSPConstants.INVALID_END_DATE;
				else {
					// This task is currently blocked by accessing mutliple DB configurations
					// The following hard coded values MUST be removed once we have access to pbXtra DB
					usageVO.setFirstName("Satya");
					usageVO.setLastName("Boddu");
					usageVO.setEmailAddress("satya_veni@yahoo.com");
					retVal = cdrUsageService.emailCdrUsageReport(usageVO);
				}
			} catch (Exception exc) {
				LOGGER.error("Error occurred in processing order invoice", exc);
				retVal = ("Error occurred in processing order invoice \n " + exc
						.getLocalizedMessage());
			}
		}

		return retVal;
	}

	@Override
	public String rollback(Input inputObj) {
		// This unit does not do anything that can be rolled back
		return null;
	}

}
