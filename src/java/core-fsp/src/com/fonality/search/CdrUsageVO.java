package com.fonality.search;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      CdrUsageVO.java
 //* Revision:      1.0
 //* Author:        Satya Boddu
 //* Created On:    Jan 21, 2013
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   Value object used to search cdr usage data by customer 
 /********************************************************************************/

import java.util.Date;

import com.fonality.bu.entity.json.Input;
import com.fonality.util.DateUtils;

public class CdrUsageVO {
	Integer customerId;
	Integer serverId;
	String lastName;
	String firstName;
	String emailAddress;
	Date startDate;
	Date endDate;

	/**
	 * 
	 */
	public CdrUsageVO() {
		super();
	}

	/**
	 * @param inoutObj
	 * @param serverId
	 * @param startDate
	 * @param endDate
	 */
	public CdrUsageVO(Input input) throws Exception {
		super();
		this.customerId = input.getCustomerId();
		this.serverId = Integer.parseInt(input.getServerId());
		this.startDate = DateUtils.formatDate(input.getStartDate(), DateUtils.USA_DATETIME_YYYY);
		this.endDate = DateUtils.formatDate(input.getEndDate(), DateUtils.USA_DATETIME_YYYY);
	}

	/**
	 * @param customerId
	 * @param serverId
	 * @param startDate
	 * @param endDate
	 */
	public CdrUsageVO(Integer customerId, Integer serverId, Date startDate, Date endDate) {
		super();
		this.customerId = customerId;
		this.serverId = serverId;
		this.startDate = startDate;
		this.endDate = endDate;
	}

	/**
	 * @return the customerId
	 */
	public Integer getCustomerId() {
		return customerId;
	}

	/**
	 * @param customerId
	 *            the customerId to set
	 */
	public void setCustomerId(Integer customerId) {
		this.customerId = customerId;
	}

	/**
	 * @return the lastName
	 */
	public String getLastName() {
		return lastName;
	}

	/**
	 * @param lastName
	 *            the lastName to set
	 */
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	/**
	 * @return the firstName
	 */
	public String getFirstName() {
		return firstName;
	}

	/**
	 * @param firstName
	 *            the firstName to set
	 */
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	/**
	 * @return the startDate
	 */
	public Date getStartDate() {
		return startDate;
	}

	/**
	 * @param startDate
	 *            the startDate to set
	 */
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	/**
	 * @return the endDate
	 */
	public Date getEndDate() {
		return endDate;
	}

	/**
	 * @param endDate
	 *            the endDate to set
	 */
	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	/**
	 * @return the serverId
	 */
	public Integer getServerId() {
		return serverId;
	}

	/**
	 * @param serverId
	 *            the serverId to set
	 */
	public void setServerId(Integer serverId) {
		this.serverId = serverId;
	}

	/**
	 * @return the emailAddress
	 */
	public String getEmailAddress() {
		return emailAddress;
	}

	/**
	 * @param emailAddress
	 *            the emailAddress to set
	 */
	public void setEmailAddress(String emailAddress) {
		this.emailAddress = emailAddress;
	}

	/*
	 * (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "CdrUsageVO [customerId=" + customerId + ", serverId=" + serverId + ", lastName="
				+ lastName + ", firstName=" + firstName + ", emailAddress=" + emailAddress
				+ ", startDate=" + startDate + ", endDate=" + endDate + "]";
	}

}
