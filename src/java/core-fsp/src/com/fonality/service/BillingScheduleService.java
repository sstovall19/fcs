package com.fonality.service;

import java.util.Date;
import java.sql.Timestamp;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.EntityAddress;
import com.fonality.dao.BillingScheduleDAO;

/************************************************************************************************
//* Copyright (C) 2012 Fonality. All Rights Reserved.
//*
//* Filename:     BillingScheduleService.java
//* Revision:      1.0
//* Author:        Sam Chapiro
//* Created On:    Jan 18, 2013
//* Modified by:   
//* Modified On:   
//*
//* Description:   Service class to encapsulate business operations on BillingScheduleService data
/*************************************************************************************************/


@Service
@Transactional
public class BillingScheduleService {
	
	@Autowired
	public BillingScheduleDAO billingScheduleDAO;
	
	
	public List<BillingSchedule> getCustomerListIdByDate(String selectDate) { 
		return this.billingScheduleDAO.getCustomerListId();
	}

	public BillingSchedule getCustomerById(Integer billingScheduleId) { 
		return this.billingScheduleDAO.loadBuillingSchedule(billingScheduleId);
	}
	

}
