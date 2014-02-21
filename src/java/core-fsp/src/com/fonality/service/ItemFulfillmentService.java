package com.fonality.service;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      OrderService.java
 //* Revision:      1.0
 //* Author:        Satya Boddu
 //* Created On:    Nov 27, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   Service class to encapsulate business operations on Item Fulfillment
 /********************************************************************************/

import java.io.InputStreamReader;
import java.io.Reader;
import java.util.Properties;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.util.FSPConstants;
import com.fonality.util.NetSuiteProperties;
import com.fonality.ws.NetSuiteWS;

@Service
@Transactional
public class ItemFulfillmentService {

	@Autowired
	public NetSuiteWS netSuiteWS;

	private String authHeader;

	private static final Logger LOGGER = Logger.getLogger(ItemFulfillmentService.class.getName());

	/**
	 * Method to get print label EPL file for item fulfillment transaction
	 * 
	 * @param orderId
	 * @param fulfillmentId
	 * @return epl file contents
	 */
	public byte[] getPrintLabelContents(Integer orderId, Integer fulfillmentId) throws Exception {
		byte[] eplData = null;
		GetMethod httpGet = null;
		Properties nsProps = NetSuiteProperties.getProperties();
		HttpClient client = new HttpClient();

		int statusCode = -1;
		try {
			String getUrl = nsProps.getProperty(FSPConstants.NS_ITEM_FULFIL_PRINT_LABEL_URL_PARAM);
			getUrl = getUrl.replaceAll(FSPConstants.NS_ORDER_ID_PARAM, orderId.toString());
			getUrl = getUrl.replaceAll(FSPConstants.NS_ITMFLMNT_ID_PARAM, fulfillmentId.toString());
			LOGGER.info(" Item Fulfillment Print Label URL " + getUrl);

			httpGet = new GetMethod(getUrl);
			httpGet.setRequestHeader(FSPConstants.AUTH_HEADER, this.getAuthHeader());
			statusCode = client.executeMethod(httpGet);
			if (statusCode != -1) {
				Reader reader = null;
				String response = null;
				try {
					reader = new InputStreamReader(httpGet.getResponseBodyAsStream(),
							httpGet.getResponseCharSet());
					response = IOUtils.toString(reader);

					System.out.println(" response " + response);

				} catch (Exception exc) {
					LOGGER.error("Error occurred in creating Echo Sign Agreement", exc);
					throw exc;
				} finally {
					if (reader != null)
						reader.close();
				}

			}

		} finally {
			if (httpGet != null)
				httpGet.releaseConnection();
		}
		return eplData;
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
