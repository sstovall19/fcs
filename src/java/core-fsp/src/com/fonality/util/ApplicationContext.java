package com.fonality.util;

/*********************************************************************************
 * //* Copyright (C) 2012 Fonality. All Rights Reserved. //* //* Filename:
 * ApplicationContext.java //* Revision: 1.0 //* Author: Satya Boddu //* Created
 * On: Nov 27, 2012 //* Modified by: //* Modified On: //* //* Description:
 * Wrapper for local text properties file /
 ********************************************************************************/

public class ApplicationContext {

	private static ApplicationContext _INSTANCE = new ApplicationContext();

	/**
	 * Returns singleton instance
	 * 
	 * @return ApplicationContext
	 */
	public static ApplicationContext getInstance() {
		return _INSTANCE;
	}

	/**
	 * private Constructor initializes resource bundle
	 */
	private ApplicationContext() {
		super();
	}

}
