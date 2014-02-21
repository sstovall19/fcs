package com.fonality.test;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      FCSTestSuite.java
 //* Revision:      1.0
 //* Author:        Satya Boddu
 //* Created On:    Feb 11, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:  JUnit test suite class to encapsulate all individual junit test classes 
 * 				   associated with all DAO and service classes.
 */

/********************************************************************************/

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

import com.fonality.test.dao.TestAddressDAO;
import com.fonality.test.dao.TestBillingScheduleDAO;
import com.fonality.test.dao.TestBundleDAO;
import com.fonality.test.dao.TestBundlePriceModelDAO;
import com.fonality.test.dao.TestContactDAO;
import com.fonality.test.dao.TestOrderBundleDAO;
import com.fonality.test.dao.TestOrderCategoryDAO;
import com.fonality.test.dao.TestOrderDAO;
import com.fonality.test.dao.TestOrderGroupDAO;
import com.fonality.test.dao.TestOrderTransactionDAO;
import com.fonality.test.dao.TestPaymentMethodDAO;
import com.fonality.test.dao.TestProductDAO;
import com.fonality.test.dao.TestTaxMappingDAO;
import com.fonality.test.service.TestCdrUsageService;
import com.fonality.test.service.TestEchoSignService;
import com.fonality.test.service.TestInvoiceService;
import com.fonality.test.service.TestOrderService;
import com.fonality.test.service.TestTaxCalculationService;
import com.fonality.test.util.TestObjectUtils;
import com.fonality.test.util.TestTransactionItemComparator;

@RunWith(Suite.class)
@SuiteClasses({ TestAddressDAO.class, TestBillingScheduleDAO.class, TestBundleDAO.class,
		TestBundlePriceModelDAO.class, TestContactDAO.class, TestOrderBundleDAO.class,
		TestOrderCategoryDAO.class, TestOrderDAO.class, TestOrderGroupDAO.class,
		TestOrderTransactionDAO.class, TestPaymentMethodDAO.class, TestProductDAO.class,
		TestTaxMappingDAO.class, TestCdrUsageService.class, TestEchoSignService.class,
		TestInvoiceService.class, TestTaxCalculationService.class, TestOrderService.class,
		TestTransactionItemComparator.class, TestObjectUtils.class })
public class FCSTestSuite {

}
