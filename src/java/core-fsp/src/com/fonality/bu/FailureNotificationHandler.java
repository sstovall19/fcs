package com.fonality.bu;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      FailureNotificationHandler.java
 //* Revision:      1.1
 //* Author:        Satya Boddu
 //* Created On:    Nov 27, 2012
 //* Modified by:   Jason VanNorman
 //* Modified On:   Nov 29, 2012
 //*
 //* Description:   BU to handle failures
 /********************************************************************************/

import java.io.IOException;
import java.util.Calendar;

import org.apache.commons.lang.StringUtils;

import com.fonality.bu.entity.json.Input;
import com.fonality.service.EmailService;
import com.fonality.util.FSPConstants;
import com.fonality.util.ObjectUtils;

public class FailureNotificationHandler extends AbstractBusinessUnit {

	/**
	 * @param args
	 * @throws IOException
	 */
	public static void main(String[] args) throws IOException {
		FailureNotificationHandler self = new FailureNotificationHandler();
		self.mainMethod(args);
	}

	@Override
	public String execute(Input inputObj) {
		String retVal = null;
		EmailService emailService = (EmailService) context
				.getBean("emailService");

		if (!ObjectUtils.isValid(inputObj)) {
			retVal = FSPConstants.INPUT_EMPTY;
		} else if (StringUtils.isEmpty(inputObj.getErrorMessage())) {
			retVal = (FSPConstants.INPUT_ERROR_MESSAGE_EMPTY);
		} else if (StringUtils.isEmpty(inputObj.getErrorModule())) {
			retVal = (FSPConstants.INPUT_ERROR_MODULE_EMPTY);
		} else if (!(inputObj.getErrorModule().equals(
				FSPConstants.EMAIL_QUOTE_FAILURE_TYPE)
				|| inputObj.getErrorModule().equals(
						FSPConstants.EMAIL_ORDER_FAILURE_TYPE) || inputObj
				.getErrorModule().equals(FSPConstants.EMAIL_PROV_FAILURE_TYPE))) {
			retVal = (FSPConstants.INVALID_ERROR_MODULE);
		} else {
			try {
				emailService.sendFailureEmail(inputObj.getErrorMessage(),
						Calendar.getInstance().getTime(),
						inputObj.getErrorModule());

			} catch (Exception exc) {
				retVal = ("Error occurred on sending failure notification email\n "
						+ FSPConstants.EMAIL_FAILURE + exc
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
