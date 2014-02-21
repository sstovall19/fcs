package com.fonality.util;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      DateUtils.java
 //* Revision:      1.0
 //* Author:        Satya Boddu
 //* Created On:    Nov 28, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   Date Utils Class
 /********************************************************************************/

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.log4j.Logger;

public class DateUtils {

	private static final Logger LOGGER = Logger.getLogger(DateUtils.class
			.getName());
	public static final String USA_DATETIME_AMPM = "MM/dd/yy hh:mm a";
	public static final String USA_DATETIME = "MM/dd/yy";
	public static final String USA_DATETIME_YYYY = "MM/dd/yyyy";

	/**
	 * Convert Date to String based on User's Date Format.
	 * 
	 * @param searchDate
	 * @param dateFormat
	 * @return String
	 */
	public static String convertDateToString(Date searchDate, String dateFormat) {

		String date = null;
		SimpleDateFormat formatter;

		formatter = new SimpleDateFormat(dateFormat);
		if (searchDate != null) {
			date = formatter.format(searchDate);
		}

		return date;
	}

	/**
	 * Convert a String representation of a date into a Date object
	 * 
	 * @param dateString
	 * @return date
	 * @throws ParseException
	 */
	public static Date formatDate(String date, String format) {
		Date retVal = null;
		if (date != null) {
			try {
				SimpleDateFormat dateFormatter = new SimpleDateFormat(format);
				retVal = dateFormatter.parse(date);
			} catch (ParseException e) {
				LOGGER.error(" Error occurred in parsing date, date:" + date
						+ ", format: " + format, e);
			}
		}
		return retVal;
	}
}
