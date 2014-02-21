package com.fonality.util;

/*********************************************************************************
 * //* Copyright (C) 2011 Fonality. All Rights
 * Reserved.
 * //*
 * //* Filename: ReportScriplet
 * //* Revision: 1.0
 * //* Author: Satya Boddu
 * //* Created On: Jan 21, 2013
 * //* Modified by:
 * //* Modified On:
 * //*
 * //* Description: Jasper report scriplet class to handle utility operations in
 * jasper report
 * /
 ********************************************************************************/

import java.util.Date;

import net.sf.jasperreports.engine.JRDefaultScriptlet;

public class ReportScriplet extends JRDefaultScriptlet {

	public ReportScriplet() {

	}

	/**
	 * Returns the duration formatted in hours, minutes and seconds
	 * 
	 * @param seconds
	 * @return formatted string
	 */
	public String formatDuration(Integer minutes) {

		StringBuffer formattedDuration = new StringBuffer();
		int hours = (int) minutes / 60;
		int remainder = (int) minutes - hours * 60;
		int mins = remainder;

		formattedDuration

		.append((hours > 0) ? ((hours <= 9) ? (FSPConstants.ZERO + hours) : hours)
				+ FSPConstants.COLON : "00:").append(
				((mins <= 9) ? (FSPConstants.ZERO + mins) : mins));
		return formattedDuration.toString();

	}

	/**
	 * Returns the date formatted in MM/dd/YYYY
	 * 
	 * @param date
	 * @return formatted date string
	 */
	public String formatDate(Date date) {
		return DateUtils.convertDateToString(date, DateUtils.USA_DATETIME);
	}

}
