package com.fonality.service;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      TransformRecordService.java
 //* Revision:      1.0
 //* Author:        Satya Boddu
 //* Created On:    Mar 13, 2013
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   Service class to encapsulate business operations on transforming record type into different
 * 				record type using Netsuite suite script API
 */
/********************************************************************************/

import java.io.InputStreamReader;
import java.io.Reader;
import java.util.Date;
import java.util.Properties;

import org.apache.commons.io.IOUtils;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.log4j.Logger;
import org.json.JSONObject;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.bu.entity.json.Input;
import com.fonality.bu.entity.json.TransformEstimate;
import com.fonality.bu.entity.json.TransformOpportunity;
import com.fonality.util.DateUtils;
import com.fonality.util.FSPConstants;
import com.fonality.util.NetSuiteProperties;

@Service
@Transactional
public class TransformRecordService {

	private String authHeader;

	private static final Logger LOGGER = Logger.getLogger(TransformRecordService.class.getName());

	/**
	 * Method to create sales order from estimate record
	 * 
	 * @param estimateId
	 * @return locationId
	 * @return expectedShipDate
	 * @throws Exception
	 */
	public Long createOrderFromEstimate(long estimateId, long locationId, Date expectedShipDate)
			throws Exception {
		Long transformedId = this.transformRecod(new TransformEstimate(estimateId, locationId,
				DateUtils.convertDateToString(expectedShipDate, DateUtils.USA_DATETIME)));
		LOGGER.info(" Estimate " + estimateId + " converted into Sales Order Id:" + transformedId);

		return transformedId;
	}

	/**
	 * Method to create estimate from opportunity record
	 * 
	 * @param opportunityId
	 * @return estimateId
	 * @throws Exception
	 */
	public Long createEstimateFromOpportunity(long opportunityId, long shippingMethod,
			int termsInMonths, int numberOfUsers) throws Exception {
		Long transformedId = this.transformRecod(new TransformOpportunity(opportunityId,
				shippingMethod, termsInMonths, numberOfUsers));

		LOGGER.info(" Opportunity " + opportunityId + " converted into Estimate Id:"
				+ transformedId);

		return transformedId;
	}

	/**
	 * Method to create sales order from estimate record
	 * 
	 * @param estimateId
	 * @return locationId
	 * @return expectedShipDate
	 * @throws Exception
	 */
	public Long transformRecod(Input inputObj) throws Exception {

		Long transformedId = null;
		HttpPost httpPost = null;
		Properties nsProps = NetSuiteProperties.getProperties();
		HttpClient client = new DefaultHttpClient();

		HttpResponse response = null;
		try {
			String postUrl = nsProps.getProperty(FSPConstants.NS_TRANSFORM_RECORD_URL_PARAM);
			LOGGER.info(" Record Transform URL " + postUrl);

			httpPost = new HttpPost(postUrl);
			httpPost.setHeader(FSPConstants.AUTH_HEADER, this.getAuthHeader());
			httpPost.setHeader(FSPConstants.NS_SCRIPT_CONTENT_TYPE_PARAM,
					FSPConstants.NS_SCRIPT_CONTENT_TYPE_JSON);

			httpPost.setEntity((new ByteArrayEntity(inputObj.getJSONObject().toString()
					.getBytes(FSPConstants.NS_SCRIPT_UTF_ENCODING))));

			response = client.execute(httpPost);
			if (response != null) {
				Reader reader = null;
				try {
					reader = new InputStreamReader(response.getEntity().getContent());
					String responseBody = IOUtils.toString(reader);
					JSONObject responseJson = new JSONObject(responseBody);
					if ((boolean) responseJson.get(FSPConstants.STATUS)) {
						transformedId = Long.valueOf((String) responseJson.get(FSPConstants.ID));
					} else {
						throw new Exception("Error occurred in transforming "
								+ inputObj.getJSONObject().getString(
										FSPConstants.NS_SCRIPT_FROM_TYPE_PARAM)
								+ " Id: "
								+ inputObj.getJSONObject().getLong(
										FSPConstants.NS_SCRIPT_FROM_ID_PARAM)
								+ " to "
								+ inputObj.getJSONObject().getString(
										FSPConstants.NS_SCRIPT_TO_TYPE_PARAM) + ":"
								+ (String) responseJson.get(FSPConstants.NS_SCRIPT_ERROR));
					}

				} finally {
					if (reader != null)
						reader.close();
				}

			} else {
				throw new Exception("Error occurred in transforming "
						+ inputObj.getJSONObject()
								.getString(FSPConstants.NS_SCRIPT_FROM_TYPE_PARAM) + " Id: "
						+ inputObj.getJSONObject().getLong(FSPConstants.NS_SCRIPT_FROM_ID_PARAM)
						+ " to "
						+ inputObj.getJSONObject().getString(FSPConstants.NS_SCRIPT_TO_TYPE_PARAM)
						+ ", Http Post response is null");
			}

		} finally {
			if (httpPost != null)
				httpPost.releaseConnection();
		}

		return transformedId;
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

}
