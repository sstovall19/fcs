package com.fonality.billing.service.impl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionException;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.billing.DTO.BillableCdrDTO;
import com.fonality.billing.service.CdrService;
import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.ConcordCdrTest;
import com.fonality.bu.entity.UnboundCdrTest;
import com.fonality.dao.ConcordCdrDAO;
import com.fonality.dao.UnboundCdrTestDAO;
import com.fonality.util.FSPConstants;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      CdrServiceImpl.java
 //* Revision:      1.0
 //* Author:        Sam Chapiro
 //* Created On:    Feb 12, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   This Service class process unbound CDR, detects billable cdr and forms a 
 *        Billable CDR collections for further processing and summary of usage.
 *        It also process FAX transmitted records (sent /received) usage.
 */
/********************************************************************************/

@Service
@Transactional(propagation = Propagation.REQUIRED, rollbackFor = TransactionException.class)
public class CdrServiceImpl implements CdrService {

	@Autowired
	public UnboundCdrTestDAO unboundCdrTestDAO;
	@Autowired
	public ConcordCdrDAO concordCdrDAO;
	
	private static final Logger LOGGER = Logger.getLogger(CdrServiceImpl.class.getName());
	

	/**
	 * Reads in Unbound CDRs. For each Invokes processing rules to filter out and create list of
	 * Billable CDR
	 * 
	 * @param BillingSchedule
	 *            bs
	 * @param hmUsage
	 * @param hmAmount
	 * @return List<BillableCdrDTO>
	 */
	public List<BillableCdrDTO> getBillableCDR(Integer serverId, BillingSchedule bs,
			HashMap<String, Integer> hmUsage, HashMap<String, BigDecimal> hmAmount)
			throws Exception {

		List<UnboundCdrTest> unboundCdrList = null;
		List<BillableCdrDTO> billableCdrList = new ArrayList<BillableCdrDTO>();
		BillableCdrDTO billableCdrDTO = null;

		// Usage processing Initialization
		usageProcessingInit(hmUsage, hmAmount);

		// Getting Voice unboundCdrList 
		unboundCdrList = unboundCdrTestDAO.getCdrList(serverId, bs.getStartDate(), bs.getEndDate());

		LOGGER.info("getBillableCDR(): Number of Unbound CDR - " + unboundCdrList.size());
		
		// Processing unbound Voice CDRs
		for (UnboundCdrTest unboundCdr : unboundCdrList) {

			billableCdrDTO = processingCdr(unboundCdr);

			if (billableCdrDTO != null) {
				billableCdrList.add(billableCdrDTO);
				summarizeUsageAndAmounts(billableCdrDTO, hmUsage, hmAmount);
			}
		}

		LOGGER.info("getBillableCDR(): Number of Billable CDR - " + billableCdrList.size());

		return billableCdrList;

	}

	/**
	 * Takes in an unbound CDR, and applys rules to filter out and create Billable CDR
	 * Here BillableDuration is set in sec, as it is in orignal CDR.
	 * @param unboundCdr
	 * @return BillableCdrDTO
	 */
	public BillableCdrDTO processingCdr(UnboundCdrTest unboundCdr) throws Exception {

		BillableCdrDTO billableCdrDTO = new BillableCdrDTO();

		// 1. Setting Direction
		if (unboundCdr.getDirection() == null || unboundCdr.getDirection().length() == 0) {
			if (unboundCdr.getDid().equals("")) {
				billableCdrDTO.setDirection(FSPConstants.UNBOUND_CDR_CALL_DIRECTIONS_OUTBOUND);
			} else {
				billableCdrDTO.setDirection(FSPConstants.UNBOUND_CDR_CALL_DIRECTIONS_INBOUND);
			}
		}
		
		
		// 2. Setting international.
		if (isInternational(billableCdrDTO.getDirection(), unboundCdr.getCountry(), unboundCdr.getDialedNumber())) {
			billableCdrDTO.setInternational(true);
		} else {
			billableCdrDTO.setInternational(false);
		}

		// 3.Setting Mobile
		if (unboundCdr.getIsMobile().equals("1")) {
			billableCdrDTO.setCallType(FSPConstants.UNBOUND_CDR_CALL_TYPE_MOBILE);
		} 
		
		// 4. Setting ToolFree
		if (isTollFree(unboundCdr.getDid())) {
			billableCdrDTO.setCallType(FSPConstants.UNBOUND_CDR_CALL_TYPE_TOLLFREE);
		}

		// 5. Setting Emergency
		if (isEmergency(unboundCdr.getDialedNumber())) {
			billableCdrDTO.setCallType(FSPConstants.UNBOUND_CDR_CALL_TYPE_EMERGENCY);
		}

		// 6. Setting Premium
		if (isPremium(unboundCdr.getDialedNumber())) {
			billableCdrDTO.setCallType(FSPConstants.UNBOUND_CDR_CALL_TYPE_PREMIUM);
		}

		// 7. Setting Standard
		if (billableCdrDTO.getCallType() == null || billableCdrDTO.getCallType().equals("")) {
			billableCdrDTO.setCallType(FSPConstants.UNBOUND_CDR_CALL_TYPE_STANDARD);
		}

		//  Checking if CDR is  OUT PLAN
		if (isOutOfPlan(unboundCdr, billableCdrDTO)) {

			// Forming  billableCdrDTO
			billableCdrDTO.setUniqueId(unboundCdr.getUniqueId());
			billableCdrDTO.setServerId(unboundCdr.getServerId());
			billableCdrDTO.setCalldate(unboundCdr.getCalldate());
			billableCdrDTO.setDid(unboundCdr.getDid());
			billableCdrDTO.setAni(unboundCdr.getAni());
			billableCdrDTO.setDialedNumber(unboundCdr.getDialedNumber());
			billableCdrDTO.setBillableDuration(unboundCdr.getBillableDuration());
			billableCdrDTO.setCustomerBilledAmount(unboundCdr.getCustomerBilledAmount());
			billableCdrDTO.setCountry(unboundCdr.getCountry());

			return billableCdrDTO;

		} else {
			return billableCdrDTO = null;
		}

	}

	/**
	 * Initializes hash tables containing minutes usage and amount for variety of Line items
	 * 
	 * @param hmUsage
	 * @param hmAmount
	 * @return void
     *
	 */
	private void usageProcessingInit(HashMap<String, Integer> hmUsage,
			HashMap<String, BigDecimal> hmAmount) {

		// 1. Initializing Usage Hashmaps
		hmUsage.put(FSPConstants.BUNDLE_INTERNATIONAL_STD_USAGE, 0);
		hmUsage.put(FSPConstants.BUNDLE_INTERNATIONAL_MOBILE_USAGE, 0);
		hmUsage.put(FSPConstants.BUNDLE_TOLLFREE_USAGE, 0);
		hmUsage.put(FSPConstants.BUNDLE_NAME_FAX, 0);
		hmUsage.put(FSPConstants.BUNDLE_PREMIUM_USAGE, 0);
		hmUsage.put(FSPConstants.BUNDLE_EMERGENCY_USAGE, 0);
		hmUsage.put(FSPConstants.BUNDLE_STANDARD_USAGE, 0);

		hmAmount.put(FSPConstants.BUNDLE_INTERNATIONAL_STD_USAGE, BigDecimal.valueOf(0));
		hmAmount.put(FSPConstants.BUNDLE_INTERNATIONAL_MOBILE_USAGE, BigDecimal.valueOf(0));
		hmAmount.put(FSPConstants.BUNDLE_TOLLFREE_USAGE, BigDecimal.valueOf(0));
		hmAmount.put(FSPConstants.BUNDLE_NAME_FAX, BigDecimal.valueOf(0));
		hmAmount.put(FSPConstants.BUNDLE_PREMIUM_USAGE, BigDecimal.valueOf(0));
		hmAmount.put(FSPConstants.BUNDLE_EMERGENCY_USAGE, BigDecimal.valueOf(0));
		hmAmount.put(FSPConstants.BUNDLE_STANDARD_USAGE, BigDecimal.valueOf(0));

	}

	/**
	 * Summarizes minutes usage and amount find in individual billable CDR.
	 * 
	 * @param billableCdrDTO
	 * @param hmUsage
	 * @param hmAmount
	 * @return void
	 */
	private void summarizeUsageAndAmounts(BillableCdrDTO billableCdrDTO,
			HashMap<String, Integer> hmUsage, HashMap<String, BigDecimal> hmAmount) {

		BigDecimal bdTemp = null;

		if (billableCdrDTO.getInternational() && !billableCdrDTO.getCallType().equals(FSPConstants.UNBOUND_CDR_CALL_TYPE_MOBILE)) {
			hmUsage.put(FSPConstants.BUNDLE_INTERNATIONAL_STD_USAGE, hmUsage.get(FSPConstants.BUNDLE_INTERNATIONAL_STD_USAGE)
					+ roundUp(billableCdrDTO.getBillableDuration()));
			bdTemp = hmAmount.get(FSPConstants.BUNDLE_INTERNATIONAL_STD_USAGE).add(
					BigDecimal.valueOf(billableCdrDTO.getCustomerBilledAmount()));
			hmAmount.put(FSPConstants.BUNDLE_INTERNATIONAL_STD_USAGE, bdTemp);
			billableCdrDTO.setCallUsageDisplayName(FSPConstants.INTERNATIONAL_STD_TYPE);
		} else if (billableCdrDTO.getInternational() && billableCdrDTO.getCallType().equals(FSPConstants.UNBOUND_CDR_CALL_TYPE_MOBILE)) {
			hmUsage.put(FSPConstants.BUNDLE_INTERNATIONAL_MOBILE_USAGE, hmUsage.get(FSPConstants.BUNDLE_INTERNATIONAL_MOBILE_USAGE)
					+ roundUp(billableCdrDTO.getBillableDuration()));
			bdTemp = hmAmount.get(FSPConstants.BUNDLE_INTERNATIONAL_MOBILE_USAGE).add(
					BigDecimal.valueOf(billableCdrDTO.getCustomerBilledAmount()));
			hmAmount.put(FSPConstants.BUNDLE_INTERNATIONAL_MOBILE_USAGE, bdTemp);
			billableCdrDTO.setCallUsageDisplayName(FSPConstants.INTERNATIONAL_MOBILE_TYPE);
		} else if (billableCdrDTO.getCallType().equals(FSPConstants.UNBOUND_CDR_CALL_TYPE_TOLLFREE)) {
			hmUsage.put(FSPConstants.BUNDLE_TOLLFREE_USAGE, hmUsage.get(FSPConstants.BUNDLE_TOLLFREE_USAGE) 
					+ roundUp(billableCdrDTO.getBillableDuration()));
			bdTemp = hmAmount.get(FSPConstants.BUNDLE_TOLLFREE_USAGE).add(
					BigDecimal.valueOf(billableCdrDTO.getCustomerBilledAmount()));
			hmAmount.put(FSPConstants.BUNDLE_TOLLFREE_USAGE, bdTemp);
			billableCdrDTO.setCallUsageDisplayName(FSPConstants.TOLLFREE_TYPE);
		} else if (billableCdrDTO.getCallType().equals(FSPConstants.UNBOUND_CDR_CALL_TYPE_PREMIUM)) {
			hmUsage.put(FSPConstants.BUNDLE_PREMIUM_USAGE, hmUsage.get(FSPConstants.BUNDLE_PREMIUM_USAGE) 
					+ roundUp(billableCdrDTO.getBillableDuration()));
			bdTemp = hmAmount.get(FSPConstants.BUNDLE_PREMIUM_USAGE).add(
					BigDecimal.valueOf(billableCdrDTO.getCustomerBilledAmount()));
			hmAmount.put(FSPConstants.BUNDLE_PREMIUM_USAGE, bdTemp);
			billableCdrDTO.setCallUsageDisplayName(FSPConstants.PREMIUM_TYPE);
		} else if (billableCdrDTO.getCallType().equals(FSPConstants.UNBOUND_CDR_CALL_TYPE_EMERGENCY)) {
			hmUsage.put(FSPConstants.BUNDLE_EMERGENCY_USAGE, hmUsage.get(FSPConstants.BUNDLE_EMERGENCY_USAGE) 
					+ roundUp(billableCdrDTO.getBillableDuration()));
			bdTemp = hmAmount.get(FSPConstants.BUNDLE_EMERGENCY_USAGE).add(
					BigDecimal.valueOf(billableCdrDTO.getCustomerBilledAmount()));
			hmAmount.put(FSPConstants.BUNDLE_EMERGENCY_USAGE, bdTemp);
			billableCdrDTO.setCallUsageDisplayName(FSPConstants.EMERGENCY_TYPE);
		} else if (billableCdrDTO.getCallType().equals(FSPConstants.UNBOUND_CDR_CALL_TYPE_STANDARD) && !billableCdrDTO.getInternational()) {
			hmUsage.put(FSPConstants.BUNDLE_STANDARD_USAGE, hmUsage.get(FSPConstants.BUNDLE_STANDARD_USAGE) 
					+ roundUp(billableCdrDTO.getBillableDuration()));
			bdTemp = hmAmount.get(FSPConstants.BUNDLE_STANDARD_USAGE).add(
					BigDecimal.valueOf(billableCdrDTO.getCustomerBilledAmount()));
			hmAmount.put(FSPConstants.BUNDLE_STANDARD_USAGE, bdTemp);
			billableCdrDTO.setCallUsageDisplayName(FSPConstants.STANDARD_TYPE);
		} else {
			LOGGER.info("summarizeUsageAndAmounts(): ***** LEFT OVER BillableCDR - " + billableCdrDTO.toString());
		}

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
	 * returns TRUE if call belong to international type of calls
	 * 
	 * @param dialedNumber
	 * @return boolean
	 */
	private boolean isInternational(String directions, String country, String dialedNumber) {

		boolean rt = false;
		
		/*
		 * 	When the call is inbound, the country code listed is the origination country
		 *	When the call is outbound, the country code listed is the destination country
		 */
		if (directions.equals(FSPConstants.UNBOUND_CDR_CALL_DIRECTIONS_OUTBOUND)) {
			if (country.equals("US")) {
				if (dialedNumber.startsWith(FSPConstants.ONE_US) || dialedNumber.startsWith(FSPConstants.US)) {
					rt = true;
				} else {
					rt = false;
				}
			} else if (country.equals("AU")) {
				if (dialedNumber.startsWith(FSPConstants.ONE_AU) || dialedNumber.startsWith(FSPConstants.AU)) {
					rt = true;
				} else {
					rt = false;
				}
			
			} else {
				rt = true;
			}
		} else if (!country.equals("US")) {
			rt=true;
		} 
		
		
		return rt;
	}

	/**
	 * Returns TRUE if call belong Toolfree type of calls
	 * 
	 * @param phoneNumber
	 * @return boolean
	 */
	private boolean isTollFree(String didNumber) {

		boolean rt = false;

		for (int i = 0; i < FSPConstants.TOLL_FREE_PREFIX.length; i++) {
			if (didNumber.startsWith(FSPConstants.TOLL_FREE_PREFIX[i])) {
				rt = true;
				return rt;
			}
		}

		return rt;
	}

	/**
	 * Returns TRUE if call belong Emergency type of calls
	 * 
	 * @param dialedNumber
	 * @return boolean
	 */
	private boolean isEmergency(String dialedNumber) {

		boolean rt = true;

		if (dialedNumber.startsWith(FSPConstants.US_EMERGENCY)) {
			rt = true;
		} else {
			rt = false;
		}

		return rt;
	}

	/**
	 * Returns TRUE if call belong Premium type of calls.
	 * 
	 * @param dialedNumber
	 * @return boolean
	 */
	private boolean isPremium(String dialedNumber) {

		boolean rt = true;

		if (dialedNumber.startsWith(FSPConstants.PREMIUM) || dialedNumber.startsWith(FSPConstants.ONE_PREMIUM)) {
			rt = true;
		} else {
			rt = false;
		}

		return rt;
	}

	/**
	 * Returns TRUE if call DOES belong to chargeable type of calls.
	 * 
	 * @param UnboundCdr cdr
	 * @param billableCdrDTO
	 * @return boolean
	 */
	private boolean isOutOfPlan(UnboundCdrTest cdr, BillableCdrDTO billableCdrDTO) {

		boolean rt = false;

		if (billableCdrDTO.getCallType().equals(FSPConstants.UNBOUND_CDR_CALL_TYPE_TOLLFREE)
				&& billableCdrDTO.getDirection().equals(FSPConstants.UNBOUND_CDR_CALL_DIRECTIONS_INBOUND)) {
			return true;

		} else if (billableCdrDTO.getInternational()
				&& billableCdrDTO.getDirection().equals(FSPConstants.UNBOUND_CDR_CALL_DIRECTIONS_OUTBOUND)) {
			if (billableCdrDTO.getCallType().equals(FSPConstants.UNBOUND_CDR_CALL_TYPE_STANDARD)
					&& isNotStandardCallFreeCountry(cdr.getCountry())) {
				return true;
			} else if (billableCdrDTO.getCallType().equals(FSPConstants.UNBOUND_CDR_CALL_TYPE_MOBILE)
					&& isNotMobileCallFreeCountry(cdr.getCountry())) {
				return true;
			}

		} else if ((billableCdrDTO.getCallType().equals(FSPConstants.UNBOUND_CDR_CALL_TYPE_PREMIUM) && cdr.getDirection().equals(
				FSPConstants.UNBOUND_CDR_CALL_DIRECTIONS_OUTBOUND))) {
			return true;
		} else if ((billableCdrDTO.getCallType().equals(FSPConstants.UNBOUND_CDR_CALL_TYPE_EMERGENCY) && cdr.getDirection().equals(
				FSPConstants.UNBOUND_CDR_CALL_DIRECTIONS_OUTBOUND))) {
			return true;
		} 
		
		
		return rt;
	}

	/**
	 * Returns TRUE if the country is not Free for standart call. see list of international
	 * services: http://www.fonality.com/legal/international-service.html
	 * 
	 * @param country
	 * @return boolean
	 */
	private boolean isNotStandardCallFreeCountry(String country) {

		boolean rt = true;

		for (int i = 0; i < FSPConstants.STANDARD_CALL_FREE_COUNTRY.length; i++) {
			if (FSPConstants.STANDARD_CALL_FREE_COUNTRY[i].toUpperCase().equals(country.toUpperCase())) {
				return false;
			}
		}

		return rt;

	}

	/**
	 * Returns TRUE if the country is not Free for mobile call. see list of international services:
	 * http://www.fonality.com/legal/international-service.html
	 * 
	 * @param country
	 * @return boolean
	 */
	private boolean isNotMobileCallFreeCountry(String country) {

		boolean rt = true;

		for (int i = 0; i < FSPConstants.MOBILE_CALL_FREE_COUNTRY.length; i++) {
			if (FSPConstants.MOBILE_CALL_FREE_COUNTRY[i].toUpperCase().equals(country.toUpperCase())) {
				return false;
			}
		}

		return rt;

	}

	/**
	 * Summarizes FAX pages and amount for processed server.
	 * 
	 * @param billingSchedule
	 * @param hmUsage
	 * @param hmAmount
	 * @return boolean
	 */
	public boolean getFaxUsage(int serverId, BillingSchedule billingSchedule, HashMap<String, Integer> hmUsage,
			HashMap<String, BigDecimal> hmAmount) throws Exception {

		List<ConcordCdrTest> concordCdrList = null;

		// Initializing.
		hmUsage.put(FSPConstants.BUNDLE_NAME_FAX, 0);
		hmAmount.put(FSPConstants.BUNDLE_NAME_FAX, BigDecimal.valueOf(0));

		//Getting list of pages transfered for given Server / Customer.
		concordCdrList = concordCdrDAO.getCdrList(serverId, billingSchedule.getStartDate(),
						billingSchedule.getEndDate());

		if (concordCdrList != null && concordCdrList.size() != 0) {
			// Loop over collections of fax cdrs and summarizing sent /received pages 
			for (ConcordCdrTest faxCdr : concordCdrList) {
				hmUsage.put(FSPConstants.BUNDLE_NAME_FAX, (hmUsage.get(FSPConstants.BUNDLE_NAME_FAX) + faxCdr.getPageCount()));

			}
			// Calculate the fax Amount.
			hmAmount.put(FSPConstants.BUNDLE_NAME_FAX,
					BigDecimal.valueOf(hmUsage.get(FSPConstants.BUNDLE_NAME_FAX) * FSPConstants.FAX_PAGE_COST));

		}
		
		LOGGER.info("getFaxUsage-  Number of FAX pages - " + hmUsage.get(FSPConstants.BUNDLE_NAME_FAX) + 
				"   Fax Usage Amount: " + hmAmount.get(FSPConstants.BUNDLE_NAME_FAX));
		
		return true;
	}

}
