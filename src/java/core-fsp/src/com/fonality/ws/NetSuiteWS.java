package com.fonality.ws;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      NetSuiteWS.java
 //* Revision:      1.0
 //* Author:        Satya Boddu
 //* Created On:    Jan 30, 2013
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   Java service to perform WS operations on NetSuite Records
 /********************************************************************************/

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;

import com.fonality.service.common.NetSuiteService;
import com.netsuite.webservices.platform.core_2012_2.CustomRecordRef;
import com.netsuite.webservices.platform.core_2012_2.Record;
import com.netsuite.webservices.platform.core_2012_2.RecordRef;
import com.netsuite.webservices.platform.core_2012_2.SearchRecord;
import com.netsuite.webservices.platform.core_2012_2.SearchResult;
import com.netsuite.webservices.platform.messages_2012_2.ReadResponse;
import com.netsuite.webservices.platform.messages_2012_2.WriteResponse;
import com.netsuite.webservices.setup.customization_2012_2.CustomRecord;

public class NetSuiteWS {

	@Autowired
	public NetSuiteService netSuiteService;

	private static final Logger LOGGER = Logger.getLogger(NetSuiteWS.class.getName());

	/***
	 * Method to create record in NetSuite
	 * 
	 * @return return internalId
	 */
	public Long createRecord(Record record) throws Exception {
		Long retVal = null;
		try {
			this.netSuiteService.initializeAndLogin();
			WriteResponse response = netSuiteService.getPort().add(record);

			if (response.getStatus().isIsSuccess()) {
				LOGGER.info("createRecord Type: "
						+ ((RecordRef) response.getBaseRef()).getType().getValue());
				LOGGER.info("createRecord Internal Id: "
						+ ((RecordRef) response.getBaseRef()).getInternalId());
				retVal = new Long(((RecordRef) response.getBaseRef()).getInternalId());

			} else {
				LOGGER.error("createRecord status message:  "
						+ response.getStatus().getStatusDetail(0).getMessage());
				LOGGER.error("createRecord Status type:  "
						+ response.getStatus().getStatusDetail(0).getType().getValue());
				LOGGER.error("createRecord Status Value:  "
						+ response.getStatus().getStatusDetail(0).getCode().getValue());
				throw new Exception(response.getStatus().getStatusDetail(0).getCode().getValue()
						+ ":" + response.getStatus().getStatusDetail(0).getMessage());

			}
		} catch (Exception e) {
			// LOGGER.error("Error occurred in creating record: ", e);
			throw e;
		} finally {
			try {
				this.netSuiteService.logout();
			} catch (Exception e) {
				LOGGER.error("Error occurred in logging out: ", e);
			}
		}
		return retVal;
	}

	/***
	 * Method to create custom record in NetSuite
	 * 
	 * @return internalId
	 */
	public Long createCustomRecord(Record record) throws Exception {
		Long retVal = null;
		try {
			this.netSuiteService.initializeAndLogin();
			WriteResponse response = netSuiteService.getPort().add(record);

			if (response.getStatus().isIsSuccess()) {
				LOGGER.info("createCustomRecord Type: "
						+ ((CustomRecordRef) response.getBaseRef()).getTypeId());
				LOGGER.info("createCustomRecord Internal Id: "
						+ ((CustomRecordRef) response.getBaseRef()).getInternalId());
				retVal = new Long(((CustomRecordRef) response.getBaseRef()).getInternalId());

			} else {
				LOGGER.error("createCustomRecord status message:  "
						+ response.getStatus().getStatusDetail(0).getMessage());
				LOGGER.error("createCustomRecord Status type:  "
						+ response.getStatus().getStatusDetail(0).getType().getValue());
				LOGGER.error("createCustomRecord Status Value:  "
						+ response.getStatus().getStatusDetail(0).getCode().getValue());

			}
		} catch (Exception e) {
			LOGGER.error("Error occurred in creating custom record: ", e);
			throw e;
		} finally {
			try {
				this.netSuiteService.logout();
			} catch (Exception e) {
				LOGGER.error("Error occurred on logging out: ", e);
			}
		}
		return retVal;
	}

	/***
	 * Method to get record in NetSuite
	 * 
	 * @return return internalId
	 */
	public Record getRecord(RecordRef recordRef) throws Exception {
		Record retVal = null;
		try {
			this.netSuiteService.initializeAndLogin();
			ReadResponse response = netSuiteService.getPort().get(recordRef);

			if (response.getStatus().isIsSuccess()) {
				retVal = response.getRecord();

			} else {
				LOGGER.error("getRecord status message:  "
						+ response.getStatus().getStatusDetail(0).getMessage());
				LOGGER.error("getRecord Status type:  "
						+ response.getStatus().getStatusDetail(0).getType().getValue());
				LOGGER.error("getRecord Status Value:  "
						+ response.getStatus().getStatusDetail(0).getCode().getValue());
				throw new Exception(response.getStatus().getStatusDetail(0).getCode().getValue()
						+ ":" + response.getStatus().getStatusDetail(0).getMessage());

			}
		} catch (Exception e) {
			LOGGER.error("Error occurred in getting record: ", e);
			throw e;
		} finally {
			try {
				this.netSuiteService.logout();
			} catch (Exception e) {
				LOGGER.error("Error occurred in logging out: ", e);
			}
		}
		return retVal;
	}

	/***
	 * Method to get record in NetSuite
	 * 
	 * @return return internalId
	 */
	public CustomRecord getCustomRecord(CustomRecordRef recordRef) throws Exception {
		CustomRecord retVal = null;
		try {
			this.netSuiteService.initializeAndLogin();
			ReadResponse response = netSuiteService.getPort().get(recordRef);

			if (response.getStatus().isIsSuccess()) {
				retVal = (CustomRecord) response.getRecord();
			} else {
				LOGGER.error("getCustomRecord status message:  "
						+ response.getStatus().getStatusDetail(0).getMessage());
				LOGGER.error("getCustomRecord Status type:  "
						+ response.getStatus().getStatusDetail(0).getType().getValue());
				LOGGER.error("getCustomRecord Status Value:  "
						+ response.getStatus().getStatusDetail(0).getCode().getValue());
				throw new Exception(response.getStatus().getStatusDetail(0).getCode().getValue()
						+ ":" + response.getStatus().getStatusDetail(0).getMessage());

			}
		} catch (Exception e) {
			LOGGER.error("Error occurred in getting custom record: ", e);
			throw e;
		} finally {
			try {
				this.netSuiteService.logout();
			} catch (Exception e) {
				LOGGER.error("Error occurred in logging out: ", e);
			}
		}
		return retVal;
	}

	/***
	 * Method to update custom record in NetSuite
	 * 
	 * @return return internalId
	 */
	public Long updateCustomRecord(Record record) throws Exception {
		Long retVal = null;
		try {
			this.netSuiteService.initializeAndLogin();
			WriteResponse response = netSuiteService.getPort().update(record);

			if (response.getStatus().isIsSuccess()) {
				LOGGER.info("updateCustomRecord Type: "
						+ ((CustomRecordRef) response.getBaseRef()).getTypeId());
				LOGGER.info("updateCustomRecord Internal Id: "
						+ ((CustomRecordRef) response.getBaseRef()).getInternalId());
				retVal = new Long(((CustomRecordRef) response.getBaseRef()).getInternalId());

			} else {
				LOGGER.error("updateRecord status message:  "
						+ response.getStatus().getStatusDetail(0).getMessage());
				LOGGER.error("updateRecord Status type:  "
						+ response.getStatus().getStatusDetail(0).getType().getValue());
				LOGGER.error("updateRecord Status Value:  "
						+ response.getStatus().getStatusDetail(0).getCode().getValue());

			}
		} catch (Exception e) {
			LOGGER.error("Error occurredin updating custom record: ", e);
			throw e;
		} finally {
			try {
				this.netSuiteService.logout();
			} catch (Exception e) {
				LOGGER.error("Error occurred on logging out: ", e);
			}
		}
		return retVal;
	}

	/***
	 * Method to update record in NetSuite
	 * 
	 * @return return internalId
	 */
	public Long updateRecord(Record record) throws Exception {
		Long retVal = null;
		try {
			this.netSuiteService.initializeAndLogin();
			WriteResponse response = netSuiteService.getPort().update(record);

			if (response.getStatus().isIsSuccess()) {
				LOGGER.info("updateRecord Type: "
						+ ((RecordRef) response.getBaseRef()).getType().getValue());
				LOGGER.info("updateRecord Internal Id: "
						+ ((RecordRef) response.getBaseRef()).getInternalId());
				retVal = new Long(((RecordRef) response.getBaseRef()).getInternalId());

			} else {
				LOGGER.error("updateRecord status message:  "
						+ response.getStatus().getStatusDetail(0).getMessage());
				LOGGER.error("updateRecord Status type:  "
						+ response.getStatus().getStatusDetail(0).getType().getValue());
				LOGGER.error("updateRecord Status Value:  "
						+ response.getStatus().getStatusDetail(0).getCode().getValue());

				throw new Exception(response.getStatus().getStatusDetail(0).getCode().getValue()
						+ ":" + response.getStatus().getStatusDetail(0).getMessage());

			}
		} catch (Exception e) {
			LOGGER.error("Error occurredin updating record: ", e);
			throw e;
		} finally {
			try {
				this.netSuiteService.logout();
			} catch (Exception e) {
				LOGGER.error("Error occurred on logging out: ", e);
			}
		}
		return retVal;
	}

	/***
	 * Method to search custom Record by searchRecord
	 * 
	 * @param searchRecord
	 * @return customRecord
	 */
	public CustomRecord searchCustomRecord(SearchRecord record) throws Exception {
		CustomRecord customRecord = null;
		try {
			this.netSuiteService.initializeAndLogin();
			SearchResult searchResult = netSuiteService.getPort().search(record);

			if (searchResult.getStatus().isIsSuccess()) {
				customRecord = (CustomRecord) searchResult.getRecordList().getRecord(0);
				LOGGER.info("searchCustomRecord Document Id:  " + customRecord.getInternalId());
			} else {
				LOGGER.error("searchCustomRecord status message:  "
						+ searchResult.getStatus().getStatusDetail(0).getMessage());
				LOGGER.error("searchDocument Status type:  "
						+ searchResult.getStatus().getStatusDetail(0).getType().getValue());
				LOGGER.error("searchCustomRecord Status Value:  "
						+ searchResult.getStatus().getStatusDetail(0).getCode().getValue());

			}

		} catch (Exception e) {
			LOGGER.error("Error occurred in searching custom record: ", e);
			throw e;
		} finally {
			try {
				this.netSuiteService.logout();
			} catch (Exception e) {
				LOGGER.error("Error occurred on logging out: ", e);
			}
		}
		return customRecord;
	}

	/***
	 * Method to search Record by searchRecord
	 * 
	 * @param serachRecord
	 * @return record
	 */
	public Record searchRecord(SearchRecord searchRecord) throws Exception {
		Record record = null;
		try {
			this.netSuiteService.initializeAndLogin();
			SearchResult searchResult = netSuiteService.getPort().search(searchRecord);

			if (searchResult.getStatus().isIsSuccess()) {
				record = searchResult.getRecordList().getRecord(0);
				LOGGER.info("searchRecord internalId:  " + record);
			} else {
				LOGGER.error("searchRecord status message:  "
						+ searchResult.getStatus().getStatusDetail(0).getMessage());
				LOGGER.error("searchRecord Status type:  "
						+ searchResult.getStatus().getStatusDetail(0).getType().getValue());
				LOGGER.error("searchRecord Status Value:  "
						+ searchResult.getStatus().getStatusDetail(0).getCode().getValue());
			}

		} catch (Exception e) {
			LOGGER.error("Error occurred in searching record: ", e);
			throw e;
		} finally {
			try {
				this.netSuiteService.logout();
			} catch (Exception e) {
				LOGGER.error("Error occurred on logging out: ", e);
			}
		}
		return record;
	}

	/**
	 * Method to initialize record ref with internal id
	 * 
	 * @param internalId
	 * @return recordRef
	 */
	public RecordRef initRecordRef(long internalId) {
		return this.initRecordRef(String.valueOf(internalId));
	}

	/**
	 * Method to initialize record ref with internal id
	 * 
	 * @param internalId
	 * @return recordRef
	 */
	public RecordRef initRecordRef(String internalId) {
		RecordRef recordRef = new RecordRef();
		recordRef.setInternalId(internalId);
		return recordRef;
	}
}
