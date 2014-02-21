package com.fonality.billing.DTO;

/*********************************************************************************
 * Copyright (C) 2012 Fonality. All Rights Reserved.
 *
 * Filename:      ServerCdrUsageDTO.java
 * Revision:      1.0
 * Author:        Satya Boddu
 * Created On:    Mar 06, 2013
 * Modified by:   
 * Modified On:   
 *
 * Description:   DTO to hold cdr usage data like address, orderGroup, serverId, billable cdr list
 *
 ********************************************************************************/

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import com.fonality.util.FSPConstants;
import com.fonality.util.ObjectUtils;

public class ServerCdrUsageDTO implements Serializable {

	private static final long serialVersionUID = 673865475643423291L;
	private String addr1;
	private Integer orderGroupId;
	private Integer serverId;
	private List<CallTypeCdrDTO> callTypeCdrList;
	private List<BillableCdrDTO> billableCdrList;

	/**
	 * @param orderGroupId
	 */
	public ServerCdrUsageDTO(Integer orderGroupId) {
		super();
		this.orderGroupId = orderGroupId;
	}

	/**
	 * @param addr1
	 * @param orderGroupId
	 * @param serverId
	 * @param billableCdrList
	 */
	public ServerCdrUsageDTO(String addr1, Integer orderGroupId, Integer serverId,
			List<BillableCdrDTO> billableCdrList) {
		super();
		this.addr1 = addr1;
		this.orderGroupId = orderGroupId;
		this.serverId = serverId;
		this.billableCdrList = billableCdrList;
	}

	/**
	 * @return the addr1
	 */
	public String getAddr1() {
		return addr1;
	}

	/**
	 * @param addr1
	 *            the addr1 to set
	 */
	public void setAddr1(String addr1) {
		this.addr1 = addr1;
	}

	/**
	 * @return the orderGroupId
	 */
	public Integer getOrderGroupId() {
		return orderGroupId;
	}

	/**
	 * @param orderGroupId
	 *            the orderGroupId to set
	 */
	public void setOrderGroupId(Integer orderGroupId) {
		this.orderGroupId = orderGroupId;
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
	 * @return the billableCdrList
	 */
	public List<BillableCdrDTO> getBillableCdrList() {
		return billableCdrList;
	}

	/**
	 * @param billableCdrList
	 *            the billableCdrList to set
	 */
	public void setBillableCdrList(List<BillableCdrDTO> billableCdrList) {
		this.billableCdrList = billableCdrList;
	}

	/*
	 * (non-Javadoc)
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = FSPConstants.HASHCODE_PRIME;
		int result = 1;
		result = prime * result + ((orderGroupId == null) ? 0 : orderGroupId.hashCode());
		return result;
	}

	/*
	 * (non-Javadoc)
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		ServerCdrUsageDTO other = (ServerCdrUsageDTO) obj;
		if (orderGroupId == null) {
			if (other.orderGroupId != null)
				return false;
		} else if (!orderGroupId.equals(other.orderGroupId))
			return false;
		return true;
	}

	/**
	 * Round up to closer up number minutes find in individual billable CDR.
	 * 
	 * @param usage
	 * @return Integer
	 */
	private Integer roundUp(Integer usage) {
		if (usage == null) {
			usage = 0;
		}

		return (usage + 59) / 60;
	}

	/**
	 * Method to get the duration sum based on the generated cdr list
	 * 
	 * @param cdrList
	 * @return durationSum
	 */
	public Integer getDurationSum() {
		int durationSum = 0;
		if (ObjectUtils.isValid(billableCdrList)) {
			for (BillableCdrDTO cdrDTO : billableCdrList) {
				durationSum += roundUp(cdrDTO.getBillableDuration());
			}
		}
		return durationSum;
	}

	/**
	 * Method to get the amount sum based on the generated cdr list
	 * 
	 * @param cdrList
	 * @return amountSum
	 */
	public BigDecimal getBilledAmount() {
		float amountSum = 0;
		if (ObjectUtils.isValid(billableCdrList)) {
			for (BillableCdrDTO cdrDTO : billableCdrList) {
				amountSum += cdrDTO.getCustomerBilledAmount();
			}
		}

		return new BigDecimal(amountSum);
	}

	/**
	 * @return the callTypeCdrList
	 */
	public List<CallTypeCdrDTO> getCallTypeCdrList() {
		return callTypeCdrList;
	}

	/**
	 * @param callTypeCdrList
	 *            the callTypeCdrList to set
	 */
	public void setCallTypeCdrList(List<CallTypeCdrDTO> callTypeCdrList) {
		this.callTypeCdrList = callTypeCdrList;
	}

	/**
	 * Adds callTypeCdr to the list
	 * 
	 * @param callTypeCdr
	 *            the callTypeCdr to add
	 */
	public void addCallTypeCdr(CallTypeCdrDTO callTypeCdr) {
		if (this.callTypeCdrList == null)
			this.callTypeCdrList = new ArrayList<CallTypeCdrDTO>();

		this.callTypeCdrList.add(callTypeCdr);
	}

}
