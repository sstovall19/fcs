package com.fonality.bu.order;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      OrderMRCHandler.java
 //* Revision:      1.1
 //* Author:        Satya Boddu
 //* Created On:    Feb 22, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   BU to create MRC billing schedule for the order
 */
/********************************************************************************/

import java.io.IOException;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import com.fonality.bu.AbstractBusinessUnit;
import com.fonality.bu.entity.json.Input;
import com.fonality.service.OrderService;
import com.fonality.util.FSPConstants;
import com.fonality.util.ObjectUtils;

public class OrderMRCHandler extends AbstractBusinessUnit {

	private OrderService orderService = null;

	private static final Logger LOGGER = Logger.getLogger(OrderMRCHandler.class
			.getName());

	/**
	 * @param args
	 * @throws IOException
	 */
	public static void main(String[] args) throws IOException {
		OrderMRCHandler self = new OrderMRCHandler();
		self.mainMethod(args);
	}

	@Override
	public String execute(Input inputObj) {
		String retVal = null;
		this.orderService = (OrderService) context.getBean("orderService");

		if (!ObjectUtils.isValid(inputObj)) {
			retVal = FSPConstants.INPUT_EMPTY;
		} else if (!ObjectUtils.isValid(inputObj.getOrderId())
				|| !StringUtils.isNumeric(inputObj.getOrderId())) {
			retVal = FSPConstants.INVALID_ORDER;
		} else {
			if (retVal == null) {
				try {
					retVal = orderService.createMRCBillingSchedule(inputObj);
				} catch (Exception exc) {
					LOGGER.error(
							"Error occurred in creating MRC billing schedule",
							exc);
					retVal = ("Error occurred in creating MRC billing schedule \n " + exc
							.getLocalizedMessage());
				}
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
