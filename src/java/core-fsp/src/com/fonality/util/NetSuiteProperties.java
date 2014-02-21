package com.fonality.util;

import java.io.IOException;
import java.util.Map;
import java.util.Properties;

public class NetSuiteProperties {

	private static Properties properties = null;
	public static final String NS_APP_URL = "nsappurl";
	public static final String NS_REST_URL = "nsresturl";
	public static final String NS_WS_URL = "nswsurl";
	public static final String NS_ADD_AGR_URL = "nsaddagrurl";
	public static final String NS_SEND_AGR_URL = "nssendagrurl";
	public static final String NS_UPD_AGR_URL = "nsupdateagrurl";
	public static final String NS_EMAIL_TRNS_URL = "nsemailtrnsurl";
	public static final String NS_PRINT_LABEL_URL = "nsprintlabelurl";
	public static final String NS_TRNSF_RCD_URL = "nstransformurl";

	/**
	 * Retrieve the properties associated with connections to NetSuite
	 * 
	 * @return The properties
	 * @throws IOException
	 */
	public static Properties getProperties() throws IOException {

		if (properties == null) {
			initProperties();
		}

		return properties;
	}

	public static void initProperties() throws IOException {

		ConfigReader dbConfigReader = new ConfigReader(FSPConstants.NETSUITE_CONFIG_FILE_NAME);
		// Retrieve entire config file as a map
		Map<String, Object> masterMap = dbConfigReader.getConfigMap();
		// Retrieve the list of transaction modes as a map
		Map<String, Object> modeMap = (Map<String, Object>) masterMap
				.get(FSPConstants.DEFAULT_CONF);
		Map<String, Object> detailMap;
		if (true) { // Change me!
			detailMap = (Map<String, Object>) modeMap.get(FSPConstants.CONFIG_SERVER_DEV);
		} else {
			detailMap = (Map<String, Object>) modeMap.get(FSPConstants.CONFIG_SERVER_PROD);
		}
		properties = new Properties();
		properties.setProperty(FSPConstants.NS_USER, (String) detailMap.get(FSPConstants.NS_USER));
		properties.setProperty(FSPConstants.NS_ACCOUNT,
				Integer.toString((Integer) detailMap.get(FSPConstants.NS_ACCOUNT)));
		properties.setProperty(FSPConstants.NS_PWD, (String) detailMap.get(FSPConstants.NS_PWD));
		properties.setProperty(FSPConstants.NS_ROLE,
				Integer.toString((Integer) detailMap.get(FSPConstants.NS_ROLE)));
		properties.setProperty(FSPConstants.NS_WS_URL, (String) detailMap.get(NS_WS_URL));

		String nsAppURL = (String) detailMap.get(NS_APP_URL);
		String nsRestURL = (String) detailMap.get(NS_REST_URL);

		properties.setProperty(FSPConstants.NS_ECHO_SIGN_ADD_AGR_URL_PARAM, nsAppURL
				+ (String) detailMap.get(NS_ADD_AGR_URL));
		properties.setProperty(FSPConstants.NS_ECHO_SIGN_SEND_AGR_URL_PARAM, nsAppURL
				+ (String) detailMap.get(NS_SEND_AGR_URL));
		properties.setProperty(FSPConstants.NS_ECHO_SIGN_UPDATE_AGR_URL_PARAM, nsAppURL
				+ (String) detailMap.get(NS_UPD_AGR_URL));
		properties.setProperty(FSPConstants.NS_EMAIL_TRANSACTION_URL_PARAM, nsAppURL
				+ (String) detailMap.get(NS_EMAIL_TRNS_URL));
		properties.setProperty(FSPConstants.NS_ITEM_FULFIL_PRINT_LABEL_URL_PARAM, nsAppURL
				+ (String) detailMap.get(NS_PRINT_LABEL_URL));
		properties.setProperty(FSPConstants.NS_TRANSFORM_RECORD_URL_PARAM, nsRestURL
				+ (String) detailMap.get(NS_TRNSF_RCD_URL));
		properties.setProperty(FSPConstants.TIME_OUT_IN_MILLIS,
				FSPConstants.NS_SESSION_TIMEOUT_MILLIS);
	}
}
