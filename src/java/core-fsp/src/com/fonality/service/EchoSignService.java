package com.fonality.service;

/*********************************************************************************
 * Copyright (C) 2012 Fonality. All Rights Reserved.
 *
 * Filename:      EchoSignService.java
 * Revision:      1.0
 * Author:        Satya Boddu
 * Created On:    Jan 285, 2012
 * Modified by:   
 * Modified On:   
 *
 * Description:   Service class to encapsulate business operations on EchoSign 
 * 				  objects in NetSuite like create EchoSign agreement, document, signer, etc
 * 				  and emails the document to signer
 * 					
 ********************************************************************************/

import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.log4j.Logger;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.bu.entity.EntityContact;
import com.fonality.bu.entity.OrderBundle;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.dao.ContactDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.util.FSPConstants;
import com.fonality.util.NetSuiteProperties;
import com.fonality.util.ObjectUtils;
import com.fonality.util.ShippingMethodProperties;
import com.fonality.ws.NetSuiteWS;
import com.netsuite.webservices.documents.filecabinet_2012_2.File;
import com.netsuite.webservices.documents.filecabinet_2012_2.FileSearch;
import com.netsuite.webservices.documents.filecabinet_2012_2.FileSearchAdvanced;
import com.netsuite.webservices.platform.common_2012_2.CustomRecordSearchBasic;
import com.netsuite.webservices.platform.common_2012_2.FileSearchBasic;
import com.netsuite.webservices.platform.core_2012_2.CustomFieldList;
import com.netsuite.webservices.platform.core_2012_2.CustomFieldRef;
import com.netsuite.webservices.platform.core_2012_2.CustomRecordRef;
import com.netsuite.webservices.platform.core_2012_2.ListOrRecordRef;
import com.netsuite.webservices.platform.core_2012_2.LongCustomFieldRef;
import com.netsuite.webservices.platform.core_2012_2.Record;
import com.netsuite.webservices.platform.core_2012_2.RecordRef;
import com.netsuite.webservices.platform.core_2012_2.SearchCustomField;
import com.netsuite.webservices.platform.core_2012_2.SearchCustomFieldList;
import com.netsuite.webservices.platform.core_2012_2.SearchLongField;
import com.netsuite.webservices.platform.core_2012_2.SearchMultiSelectCustomField;
import com.netsuite.webservices.platform.core_2012_2.SelectCustomFieldRef;
import com.netsuite.webservices.platform.core_2012_2.StringCustomFieldRef;
import com.netsuite.webservices.platform.core_2012_2.types.SearchLongFieldOperator;
import com.netsuite.webservices.platform.core_2012_2.types.SearchMultiSelectFieldOperator;
import com.netsuite.webservices.setup.customization_2012_2.CustomRecord;
import com.netsuite.webservices.setup.customization_2012_2.CustomRecordSearch;
import com.netsuite.webservices.setup.customization_2012_2.CustomRecordSearchAdvanced;

@Service
@Transactional
public class EchoSignService {

	private static final Logger LOGGER = Logger.getLogger(EchoSignService.class.getName());

	@Autowired
	public NetSuiteWS netSuiteWS;

	@Autowired
	public OrderGroupDAO orderGroupDAO;

	@Autowired
	public OrderDAO orderDAO;

	@Autowired
	public ContactDAO contactDAO;

	@Autowired
	public TransformRecordService transformRecordService;

	private String authHeader;

	/**
	 * Method to generate and email echo sign agreement in Netsuite
	 * 
	 * @param orderGroupId
	 * @return retVal
	 */
	public JSONObject emailEchoSignAgreement(int orderGroupId) throws JSONException {
		String message = FSPConstants.SUCCESS;
		int status = 0;
		JSONObject retVal = new JSONObject();

		try {
			// Load order object with the order Id
			OrderGroup orderGroup = this.orderGroupDAO.loadOrderGroup(orderGroupId);
			if (orderGroup == null) {
				// If orderGroup is null, set the error message
				message = FSPConstants.INVALID_ORDER_GROUP;
			} else {
				// Validate orderGroup data
				if (this.validateOrder(orderGroup)) {
					long opportunityId = orderGroup.getNetsuiteSalesOrderId().longValue();
					Long estimateId = null;
					Integer numberOfUsers = getNumberOfUsers(orderGroup);

					if (numberOfUsers == null) {
						message = "Unable to find number of users for the orderGroup, orderGroup ID: "
								+ orderGroup.getOrderGroupId();
					} else {
						estimateId = this.transformRecordService.createEstimateFromOpportunity(
								opportunityId,
								Integer.parseInt(ShippingMethodProperties.getProperties()
										.get(orderGroup.getOrderShipping().getShippingText())
										.toString()), orderGroup.getOrders().getTermInMonths(),
								numberOfUsers);

						if (estimateId == null) {
							message = "Unable to convert opportunity into estimate for the orderGroup, orderGroup ID: "
									+ orderGroup.getOrderGroupId();
						} else {
							/*
							 * Create EchoSign agreement, document and attach to estimate in
							 * NetSuite
							 */
							Long agreementId = this.createEchoSignAgreement(estimateId);
							LOGGER.info(" Echo Sign agreement created: " + agreementId);
							if (agreementId != null) {
								/* Create EchSign signer with customer and sales rep details */
								Long signerId = this.createEchoSigner(agreementId, orderGroup);
								if (signerId != null) {
									/* Send/Email EchoSign Agreement to signer */
									boolean sentStatus = sendEchoSignAgreement(agreementId,
											orderGroup.getOrders().getNetsuiteSalespersonId());
									/* Update status on orderGroup, if success */
									if (sentStatus) {
										orderGroup.setNetsuiteSalesOrderId(estimateId);
										orderGroup.setNetsuiteEchosignId(agreementId);
										this.orderGroupDAO.saveOrderGroup(orderGroup);
										status = 1;
										message = "Echo Sign document sent and Order group updated with agreement Id Successfully ";
									} else {
										message = "Could not send EchoSign Agreement agreement Id: "
												+ agreementId
												+ ", orderGroup ID "
												+ orderGroup.getOrderGroupId();
									}
								} else {
									message = "Could not create EchoSign Signer record for agreement Id: "
											+ agreementId
											+ ", orderGroup Id: "
											+ orderGroup.getOrderGroupId();
								}
							} else {
								message = "Could not create EchoSign Agreement record for orderGroup Id: "
										+ orderGroup.getOrderGroupId();
							}
						}
					}
				}

			}

			if (StringUtils.equals(message, FSPConstants.SUCCESS)) {
				LOGGER.info(message);
			} else {
				LOGGER.error(message);
			}

		} catch (Exception exc) {
			LOGGER.error("Error occurred in sending echo sign agreement for orderGroup Id: "
					+ String.valueOf(orderGroupId), exc);
			message = "Error occurred in sending echo sign agreement for orderGroup Id: "
					+ orderGroupId + "\n" + exc.getLocalizedMessage();
		}

		retVal.put(FSPConstants.STATUS, status);
		retVal.put(FSPConstants.MESSAGE, message);
		return retVal;
	}

	/**
	 * Method to get signed echo sign document in Netsuite
	 * 
	 * @param orderGroupId
	 * @return retVal
	 */
	public JSONObject getSignedEchoSignDocument(int orderGroupId) throws JSONException {
		String message = FSPConstants.SUCCESS;
		int status = 0;
		JSONObject retVal = new JSONObject();

		try {
			// Load orderGroup object 
			OrderGroup orderGroup = this.orderGroupDAO.loadOrderGroup(orderGroupId);
			if (orderGroup == null) {
				// If orderGroup is null, set the error message
				message = FSPConstants.INVALID_ORDER_GROUP;
			} else if (!ObjectUtils.isValid(orderGroup.getNetsuiteEchosignId())) {
				// If orderGroup is null, set the error message
				message = FSPConstants.INVALID_ECHO_SIGN_ID;
			} else {
				// Validate orderGroup data
				if (this.validateOrder(orderGroup)) {
					/*
					 * Update EchoSign agreement status in NetSuite
					 */
					boolean updateStatus = this.updateEchoSignAgreementStatus(orderGroup
							.getNetsuiteEchosignId());
					LOGGER.info(" Echo Sign agreement update status: " + updateStatus);
					if (updateStatus) {
						CustomRecord agreement = getEchoSignAgreement(orderGroup
								.getNetsuiteEchosignId());
						if (agreement == null) {
							message = "Unable to find EchoSign Agreement record in Netsuite, agreementId: "
									+ orderGroup.getNetsuiteEchosignId();
						} else {
							String signedStatus = this.getAgreementStatus(agreement);
							LOGGER.info(" Echo Sign agreement signed status: " + signedStatus);
							if (StringUtils.equals(FSPConstants.NETSUITE_SIGNED_STATUS,
									signedStatus)) {
								String fileId = this.getSignedAgreementId(agreement);
								if (fileId != null) {
									File file = (File) this.searchFile(Long.parseLong(fileId));
									LOGGER.info("Echo Sign Signed Document URL " + file.getUrl());
									retVal.put(FSPConstants.SIGNED_STATUS, signedStatus);
									retVal.put(FSPConstants.URL, file.getUrl());
									status = 1;

								} else {
									message = "Unable to find Signed EchoSign Document record in Netsuite, agreementId: "
											+ orderGroup.getNetsuiteEchosignId();
								}

							} else {
								status = 1;
								message = "EchoSign Agreement is not signed, the current status is "
										+ signedStatus;
								retVal.put(FSPConstants.SIGNED_STATUS, signedStatus);
							}
						}
					} else {
						message = "Unable to update EchoSign Agreement status in Netsuite, agreementId: "
								+ orderGroup.getNetsuiteEchosignId();
					}

				}

			}
			if (StringUtils.equals(message, FSPConstants.SUCCESS)) {
				LOGGER.info(message);
			} else {
				LOGGER.error(message);
			}
		} catch (Exception exc) {
			LOGGER.error("Error occurred in sending echo sign agreement for orderGroup Id: "
					+ orderGroupId, exc);
			message = "Error occurred in sending echo sign agreement for orderGroup Id: "
					+ orderGroupId + "\n" + exc.getLocalizedMessage();
		}

		retVal.put(FSPConstants.STATUS, status);
		retVal.put(FSPConstants.MESSAGE, message);
		return retVal;
	}

	/**
	 * Method to validate the orderGroup data
	 * 
	 * @param orderGroup
	 * @param orderGroupId
	 * @return boolean
	 */
	private boolean validateOrder(OrderGroup orderGroup) throws Exception {
		boolean retVal = false;
		/*
		 * Checks for valid netsuite id associated with orderGroup Checks for valid netsuite sales
		 * person id associated with orders Checks for valid contact associated with orders Checks
		 * for valid email associated with contact
		 */
		if (orderGroup.getNetsuiteSalesOrderId() == null) {
			LOGGER.error("Invalid Data: NetSuite Id is blank/null for orderGroup Id: "
					+ orderGroup.getOrderGroupId());
		} else if (orderGroup.getOrders().getNetsuiteSalespersonId() == null) {
			LOGGER.error("Invalid Data: Netsuite Sales Rep Id is blank/null for orderGroup Id: "
					+ orderGroup.getOrderGroupId());
		} else if (orderGroup.getOrderShipping() == null) {
			LOGGER.error("Invalid Data: Chosen Shipping Id is blank/null for orderGroup Id: "
					+ orderGroup.getOrderGroupId());
		} else if (ShippingMethodProperties.getProperties().getProperty(
				orderGroup.getOrderShipping().getShippingText()) == null) {
			LOGGER.error("Invalid Data: Netsuite shipping method Id is blank/null for chosen shipping method: "
					+ orderGroup.getOrderShipping().getShippingText()
					+ ", orderGroup Id: "
					+ orderGroup.getOrderGroupId());
		} else {
			EntityContact contact = orderGroup.getOrders().getEntityContact();
			if (contact == null) {
				LOGGER.error("Invalid Data: Contact is missing for customer: "
						+ orderGroup.getOrders().getCustomerId() + ", orderGroup Id: "
						+ orderGroup.getOrderGroupId());
			} else if (StringUtils.isEmpty(contact.getEmail())) {
				LOGGER.error("Invalid Data: Email address is blank/null for contact: "
						+ contact.getEntityContactId() + ", orderGroup Id: "
						+ orderGroup.getOrderGroupId());
			} else {
				retVal = true;
			}
		}
		return retVal;
	}

	/**
	 * Method to return number of users with orderGroup
	 * 
	 * @param orderGroup
	 * @return numberOfUsers
	 */
	private Integer getNumberOfUsers(OrderGroup orderGroup) {
		Integer numberOfUsers = null;
		if (ObjectUtils.isValid(orderGroup.getOrderBundles())) {
			for (OrderBundle orderBundle : orderGroup.getOrderBundles()) {
				if (orderBundle.getBundle().getName().equals(FSPConstants.BUNDLE_NAME_FCS)
						|| orderBundle.getBundle().getName()
								.equals(FSPConstants.BUNDLE_NAME_FCS_PRO)) {
					numberOfUsers = orderBundle.getQuantity();
					break;
				}
			}
		}

		return numberOfUsers;
	}

	/**
	 * Method to search document by agreementId
	 * 
	 * @param agreementId
	 * @return customRecord
	 * @throws Exception
	 */
	@SuppressWarnings("unused")
	public CustomRecord searchDocument(long agreementId) throws Exception {
		CustomRecordSearchAdvanced recordSearch = new CustomRecordSearchAdvanced();
		CustomRecordSearch criteria = new CustomRecordSearch();
		CustomRecordSearchBasic basic = new CustomRecordSearchBasic();
		SearchCustomFieldList customFieldList = new SearchCustomFieldList();
		List<SearchCustomField> customFieldRefList = new ArrayList<SearchCustomField>();
		SearchMultiSelectCustomField agreementFieldRef = new SearchMultiSelectCustomField();

		agreementFieldRef.setInternalId(FSPConstants.CUSTOM_ECHOSIGNDOC_AGREEMENT);

		List<ListOrRecordRef> listRefList = new ArrayList<ListOrRecordRef>();
		ListOrRecordRef listRef = new ListOrRecordRef();
		listRef.setInternalId(String.valueOf(agreementId));
		listRef.setTypeId(FSPConstants.CUSTOM_ECHOSIGNAGREEMENT_TYPE_ID);
		listRefList.add(listRef);

		agreementFieldRef
				.setSearchValue(listRefList.toArray(new ListOrRecordRef[listRefList.size()]));
		agreementFieldRef.setOperator(SearchMultiSelectFieldOperator.anyOf);

		customFieldRefList.add(agreementFieldRef);
		customFieldList.setCustomField(customFieldRefList
				.toArray(new SearchCustomField[customFieldRefList.size()]));

		basic.setCustomFieldList(customFieldList);
		criteria.setBasic(basic);

		recordSearch.setCriteria(criteria);
		basic.setRecType(this.initRecordRef(FSPConstants.CUSTOM_ECHOSIGNDOCUMENT_TYPE_ID));

		return this.netSuiteWS.searchCustomRecord(recordSearch);
	}

	/**
	 * Method to search file by fileId
	 * 
	 * @param fileId
	 * @return record
	 * @throws Exception
	 */
	@SuppressWarnings("unused")
	public Record searchFile(long fileId) throws Exception {
		FileSearchAdvanced recordSearch = new FileSearchAdvanced();
		FileSearch criteria = new FileSearch();
		FileSearchBasic basic = new FileSearchBasic();

		SearchLongField internalField = new SearchLongField();
		internalField.setSearchValue(fileId);
		internalField.setOperator(SearchLongFieldOperator.equalTo);

		basic.setInternalIdNumber(internalField);
		criteria.setBasic(basic);
		recordSearch.setCriteria(criteria);
		return this.netSuiteWS.searchRecord(recordSearch);
	}

	/**
	 * Method to create EchoSigner record in Netsuite
	 * 
	 * @param agreementId
	 * @return orderGroup
	 * @return signerId
	 * @throws Exception
	 */
	private long createEchoSigner(long agreementId, OrderGroup orderGroup) throws Exception {
		CustomRecord echoSignerRecord = new CustomRecord();
		echoSignerRecord.setRecType(this.initRecordRef(FSPConstants.CUSTOM_ECHOSIGNER_TYPE_ID));
		echoSignerRecord.setCustomFieldList(this.getEchoSignerCustomFieldList(agreementId,
				orderGroup));

		return this.netSuiteWS.createCustomRecord(echoSignerRecord);
	}

	/**
	 * Method to update EchoSign agreement in Netsuite
	 * 
	 * @param agreementId
	 * @return agreementId
	 * @throws Exception
	 */
	@SuppressWarnings("unused")
	private long updateEchoSignAgreement(long agreementId) throws Exception {
		CustomRecord echoSignAgreementRecord = new CustomRecord();
		echoSignAgreementRecord.setRecType(this
				.initRecordRef(FSPConstants.CUSTOM_ECHOSIGNAGREEMENT_TYPE_ID));
		echoSignAgreementRecord.setInternalId(String.valueOf(agreementId));
		return this.netSuiteWS.updateCustomRecord(echoSignAgreementRecord);
	}

	/**
	 * Method to update EchoSign agreement in Netsuite
	 * 
	 * @param agreementId
	 * @return agreementId
	 * @throws Exception
	 */
	@SuppressWarnings("unused")
	private CustomRecord getEchoSignAgreement(long agreementId) throws Exception {
		CustomRecordRef recordRef = new CustomRecordRef();
		recordRef.setInternalId(String.valueOf(agreementId));
		recordRef.setTypeId(FSPConstants.CUSTOM_ECHOSIGNAGREEMENT_TYPE_ID);
		return this.netSuiteWS.getCustomRecord(recordRef);
	}

	/**
	 * Method to create EchoSign Agreement record in Netsuite
	 * 
	 * @param estimateId
	 * @return agreementId
	 * @throws Exception
	 */
	private Long createEchoSignAgreement(long estimateId) throws Exception {
		Long agreementId = null;
		HttpGet httpGet = null;
		Properties nsProps = NetSuiteProperties.getProperties();
		HttpClient client = new DefaultHttpClient();

		HttpResponse response = null;
		try {
			String getUrl = nsProps.getProperty(FSPConstants.NS_ECHO_SIGN_ADD_AGR_URL_PARAM)
					+ estimateId;
			LOGGER.info(" EchoSign Agreement URL " + getUrl);

			httpGet = new HttpGet(getUrl);
			httpGet.setHeader(FSPConstants.AUTH_HEADER, this.getAuthHeader());
			response = client.execute(httpGet);
			if (response != null) {
				Reader reader = null;
				String agrInternalId = null;
				String responseBody = null;
				try {
					reader = new InputStreamReader(response.getEntity().getContent());
					responseBody = IOUtils.toString(reader);
					agrInternalId = this.getAgreementId(responseBody);
				} catch (Exception exc) {
					LOGGER.error("Error occurred in creating Echo Sign Agreement", exc);
					throw exc;
				} finally {
					if (reader != null)
						reader.close();
				}

				if (!((agrInternalId == null) || !StringUtils.isNumeric(agrInternalId))) {
					agreementId = Long.parseLong(agrInternalId);
				}
			}

		} finally {
			if (httpGet != null)
				httpGet.releaseConnection();
		}

		return agreementId;
	}

	/**
	 * Method to get document data in byte[]
	 * 
	 * @param url
	 * @return byte[]
	 * @throws Exception
	 */
	@SuppressWarnings("unused")
	private byte[] getDocumentData(String url) throws Exception {
		byte[] documentData = null;
		HttpGet httpGet = null;
		Properties nsProps = NetSuiteProperties.getProperties();
		HttpClient client = new DefaultHttpClient();
		HttpResponse response = null;

		try {
			LOGGER.info(" File URL " + url);
			httpGet = new HttpGet(url);
			httpGet.setHeader(FSPConstants.AUTH_HEADER, this.getAuthHeader());
			response = client.execute(httpGet);
			if (response != null) {
				Reader reader = null;
				try {
					reader = new InputStreamReader(response.getEntity().getContent());
					documentData = IOUtils.toByteArray(reader);
				} finally {
					if (reader != null)
						reader.close();
				}
			}

		} finally {
			if (httpGet != null)
				httpGet.releaseConnection();

		}

		return documentData;
	}

	/**
	 * Method to send EchoSign Agreement to signer account in Netsuite
	 * 
	 * @param agreementId
	 * @return sentStatus
	 * @throws Exception
	 */
	private boolean sendEchoSignAgreement(long agreementId, Integer salesRepId) throws Exception {
		boolean sentStatus = false;
		Properties nsProps = NetSuiteProperties.getProperties();
		HttpClient client = new DefaultHttpClient();
		HttpResponse response = null;
		HttpGet httpGet = null;
		try {
			// this.updateEchoSignAgreementOwner(agreementId);
			StringBuffer getUrl = new StringBuffer(
					nsProps.getProperty(FSPConstants.NS_ECHO_SIGN_SEND_AGR_URL_PARAM))
					.append(agreementId);

			if (salesRepId != null)
				getUrl.append("&").append(FSPConstants.NS_SENDERID_PARAM).append("=")
						.append(salesRepId);

			LOGGER.info(" EchoSign Agreement Send URL " + getUrl.toString());
			httpGet = new HttpGet(getUrl.toString());
			httpGet.setHeader(FSPConstants.AUTH_HEADER, this.getAuthHeader());
			response = client.execute(httpGet);

			if (response != null) {
				Reader reader = null;
				try {
					reader = new InputStreamReader(response.getEntity().getContent());
					String responseBody = IOUtils.toString(reader);
					JSONObject json = new JSONObject(responseBody);
					sentStatus = (Boolean) json.get(FSPConstants.NS_ECHO_SIGN_STATUS_SUCCESS);
					if (!sentStatus) {
						LOGGER.error("Error occurred in sending EchoSign document, Agreement Id: "
								+ agreementId + ", ERROR: " + json.get("msg"));

					}
				} finally {
					if (reader != null)
						reader.close();
				}
			}

		} finally {
			if (httpGet != null)
				httpGet.releaseConnection();

		}
		return sentStatus;
	}

	/**
	 * Method to send update EchoSign Agreement status in Netsuite
	 * 
	 * @param agreementId
	 * @return updateStatus
	 * @throws Exception
	 */
	private boolean updateEchoSignAgreementStatus(long agreementId) throws Exception {
		boolean updateStatus = false;
		Properties nsProps = NetSuiteProperties.getProperties();
		HttpClient client = new DefaultHttpClient();
		HttpResponse response = null;
		HttpGet httpGet = null;
		try {
			// this.updateEchoSignAgreementOwner(agreementId);
			StringBuffer getUrl = new StringBuffer(
					nsProps.getProperty(FSPConstants.NS_ECHO_SIGN_UPDATE_AGR_URL_PARAM))
					.append(agreementId);

			LOGGER.info(" EchoSign Agreement Update Status URL " + getUrl.toString());
			httpGet = new HttpGet(getUrl.toString());
			httpGet.setHeader(FSPConstants.AUTH_HEADER, this.getAuthHeader());
			response = client.execute(httpGet);

			if (response != null) {
				Reader reader = null;
				try {
					reader = new InputStreamReader(response.getEntity().getContent());
					String responseBody = IOUtils.toString(reader);
					JSONObject json = new JSONObject(responseBody);
					updateStatus = (Boolean) json.get(FSPConstants.NS_ECHO_SIGN_STATUS_SUCCESS);
					if (!updateStatus) {
						LOGGER.error("Error occurred in updating EchoSign document status, Agreement Id: "
								+ agreementId + ", ERROR: " + json.get("msg"));

					}
				} finally {
					if (reader != null)
						reader.close();
				}
			}

		} finally {
			if (httpGet != null)
				httpGet.releaseConnection();

		}
		return updateStatus;
	}

	/**
	 * Method to get agreement id from redirect location path
	 * 
	 * @param location
	 * @return agreementId
	 */
	private String getAgreementId(String location) throws Exception {
		String retVal = null;
		if (StringUtils.isNotEmpty(location)) {
			String[] splitTokens = location.split(FSPConstants.DOUBLE_QUOTE);
			if (ObjectUtils.isValid(splitTokens)) {
				for (int i = 0; i < splitTokens.length; i++) {
					if (splitTokens[i].contains(FSPConstants.NS_ECHO_SIGN_RECTYPE_TOKEN)) {
						String agreementUrl = splitTokens[i];
						if (agreementUrl.contains(FSPConstants.NS_ID_TOKEN)) {
							String idTokens[] = agreementUrl.split(FSPConstants.NS_ID_TOKEN);
							if (ObjectUtils.isValid(idTokens) && idTokens.length > 1) {
								retVal = idTokens[1];
							}
						}
					}
				}
			}
		}

		return retVal;
	}

	/**
	 * Method to get custom fields list for EchoSigner Record
	 * 
	 * @param agreementId
	 * @return customerId
	 * @return emailAddress
	 * @return customeFieldList
	 */
	private CustomFieldList getEchoSignerCustomFieldList(long agreementId, OrderGroup orderGroup) {

		CustomFieldList customFieldList = new CustomFieldList();

		List<CustomFieldRef> customFieldRefList = new ArrayList<CustomFieldRef>();

		StringCustomFieldRef emailFieldRef = new StringCustomFieldRef();
		emailFieldRef.setInternalId(FSPConstants.CUSTOM_ECHOSIGN_EMAIL);
		emailFieldRef.setValue(orderGroup.getOrders().getEntityContact().getEmail());

		SelectCustomFieldRef agreementFieldRef = new SelectCustomFieldRef();
		agreementFieldRef.setInternalId(FSPConstants.CUSTOM_ECHOSIGNER_AGREEMENT);
		ListOrRecordRef listRef = new ListOrRecordRef();
		listRef.setInternalId(String.valueOf(agreementId));
		listRef.setTypeId(FSPConstants.CUSTOM_ECHOSIGNAGREEMENT_TYPE_ID);
		agreementFieldRef.setValue(listRef);

		SelectCustomFieldRef roleFieldRef = new SelectCustomFieldRef();
		roleFieldRef.setInternalId(FSPConstants.CUSTOM_ECHOSIGN_ROLE);
		ListOrRecordRef roleListRef = new ListOrRecordRef();
		roleListRef.setInternalId(FSPConstants.CUSTOM_ECHOSIGNER_ROLE_ID);
		roleListRef.setTypeId(FSPConstants.CUSTOM_ECHOSIGNER_ROLE_TYPE_ID);
		roleFieldRef.setValue(roleListRef);

		SelectCustomFieldRef signerFieldRef = new SelectCustomFieldRef();
		signerFieldRef.setInternalId(FSPConstants.CUSTOM_ECHOSIGN_SIGNER);
		ListOrRecordRef signerRef = new ListOrRecordRef();
		signerRef.setInternalId(String.valueOf(orderGroup.getOrders().getNetsuiteSalespersonId()));
		signerRef.setTypeId(FSPConstants.CUSTOM_ECHOSIGNER_SIGNER_TYPE_ID);
		signerFieldRef.setValue(signerRef);

		LongCustomFieldRef orderFieldRef = new LongCustomFieldRef();
		orderFieldRef.setInternalId(FSPConstants.CUSTOM_ECHOSIGN_SIGNER_ORDER);
		orderFieldRef.setValue(1);

		LongCustomFieldRef toOrderFieldRef = new LongCustomFieldRef();
		toOrderFieldRef.setInternalId(FSPConstants.CUSTOM_ECHOSIGN_SIGNER_TO_ORDER);
		toOrderFieldRef.setValue(0);

		customFieldRefList.add(emailFieldRef);
		customFieldRefList.add(agreementFieldRef);
		customFieldRefList.add(roleFieldRef);
		customFieldRefList.add(signerFieldRef);
		// customFieldRefList.add(orderFieldRef);
		customFieldRefList.add(toOrderFieldRef);

		customFieldList.setCustomField(customFieldRefList
				.toArray(new CustomFieldRef[customFieldRefList.size()]));

		return customFieldList;
	}

	/**
	 * Method to initialize record ref with internal id
	 * 
	 * @param internalId
	 * @return recordRef
	 */
	private RecordRef initRecordRef(String internalId) {
		RecordRef recordRef = new RecordRef();
		recordRef.setInternalId(internalId);
		return recordRef;
	}

	/**
	 * @return the authHeader
	 */
	public String getAuthHeader() {
		if (this.authHeader == null) {
			try {
				Properties nsProps = NetSuiteProperties.getProperties();
				StringBuilder auth = new StringBuilder("NLAuth nlauth_account=")
						.append(nsProps.getProperty(FSPConstants.NS_ACCOUNT))
						.append(", nlauth_email=" + nsProps.getProperty(FSPConstants.NS_USER))
						.append(", nlauth_signature=")
						.append(nsProps.getProperty(FSPConstants.NS_PWD));

				this.authHeader = auth.toString();
			} catch (Exception exc) {
				LOGGER.error("Error Occurred in creating auth header ", exc);
			}
		}
		return this.authHeader;
	}

	/**
	 * @param authHeader
	 *            the authHeader to set
	 */
	public void setAuthHeader(String authHeader) {
		this.authHeader = authHeader;
	}

	/**
	 * Method to get status of EchoSign Agreement
	 * 
	 * @param echoSignAgreement
	 * @return status
	 */
	private String getAgreementStatus(CustomRecord echoSignAgreement) {
		CustomFieldRef[] cutomFieldList = echoSignAgreement.getCustomFieldList().getCustomField();
		String status = null;
		for (int i = 0; i < cutomFieldList.length; i++) {
			if (cutomFieldList[i] instanceof SelectCustomFieldRef) {
				SelectCustomFieldRef selectField = (SelectCustomFieldRef) cutomFieldList[i];
				if (selectField.getInternalId().equals(FSPConstants.CUSTOM_ECHOSIGNAGR_STATUS)) {
					status = selectField.getValue().getName();
				}
			}
		}

		return status;

	}

	/**
	 * Method to get file Id of signed agreement
	 * 
	 * @param echoSignAgreement
	 * @return fileId
	 */
	private String getSignedAgreementId(CustomRecord echoSignAgreement) {
		CustomFieldRef[] cutomFieldList = echoSignAgreement.getCustomFieldList().getCustomField();
		String fileId = null;
		for (int i = 0; i < cutomFieldList.length; i++) {
			if (cutomFieldList[i] instanceof SelectCustomFieldRef) {
				SelectCustomFieldRef selectField = (SelectCustomFieldRef) cutomFieldList[i];
				if (selectField.getInternalId().equals(
						FSPConstants.CUSTOM_ECHOSIGNAGR_SIGNED_FILE_ID)) {
					fileId = selectField.getValue().getInternalId();
				}
			}
		}

		return fileId;

	}

}
