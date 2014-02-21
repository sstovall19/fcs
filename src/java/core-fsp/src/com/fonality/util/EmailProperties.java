package com.fonality.util;

import java.io.IOException;
import java.net.InetAddress;
import java.util.Map;
import java.util.Properties;

public class EmailProperties {

	private static Properties properties = null;

	public static Properties getProperties() throws IOException {

		if (properties == null) {
			initProperties();
		}

		return properties;
	}

	public static void initProperties() throws IOException {

		ConfigReader dbConfigReader = new ConfigReader(
				FSPConstants.MAIL_CONFIG_FILE_NAME);
		// Retrieve entire config file as a map
		Map<String, Object> masterMap = dbConfigReader.getConfigMap();
		// Retrieve the list of host types as a map
		Map<String, Object> typeMap = (Map<String, Object>) masterMap
				.get(FSPConstants.MAIL_CONFIG_HEADER);
		String hostName = InetAddress.getLocalHost().getHostName();
		Map<String, Object> detailMap;
		if (hostName.contains("dev") || true) { // Yes this is terrible, but
												// hopefully temporary
			detailMap = (Map<String, Object>) typeMap.get("devel");
		} else {
			detailMap = (Map<String, Object>) typeMap.get("production");
		}

		properties = new Properties();
		properties.setProperty("host", (String) detailMap.get("host"));
		properties.setProperty("user", (String) detailMap.get("user"));
		properties.setProperty("pass", (String) detailMap.get("pass"));
		properties.setProperty("from", (String) detailMap.get("from"));
		properties.setProperty("port",
				Integer.toString((Integer) detailMap.get("port")));
		properties.setProperty(FSPConstants.QUOTE_EMAIL_TO,
				getValue(detailMap, FSPConstants.QUOTE_EMAIL_TO));
		properties.setProperty(FSPConstants.QUOTE_EMAIL_CC,
				getValue(detailMap, FSPConstants.QUOTE_EMAIL_CC));
		properties.setProperty(FSPConstants.QUOTE_EMAIL_FROM,
				getValue(detailMap, FSPConstants.QUOTE_EMAIL_FROM));
		properties.setProperty(FSPConstants.ORDER_EMAIL_TO,
				getValue(detailMap, FSPConstants.ORDER_EMAIL_TO));
		properties.setProperty(FSPConstants.ORDER_EMAIL_CC,
				getValue(detailMap, FSPConstants.ORDER_EMAIL_CC));
		properties.setProperty(FSPConstants.ORDER_EMAIL_FROM,
				getValue(detailMap, FSPConstants.ORDER_EMAIL_FROM));
		properties.setProperty(FSPConstants.PROV_EMAIL_TO,
				getValue(detailMap, FSPConstants.PROV_EMAIL_TO));
		properties.setProperty(FSPConstants.PROV_EMAIL_CC,
				getValue(detailMap, FSPConstants.PROV_EMAIL_CC));
		properties.setProperty(FSPConstants.PROV_EMAIL_FROM,
				getValue(detailMap, FSPConstants.PROV_EMAIL_FROM));
		properties.setProperty(FSPConstants.BILLING_FAILURE_TO_ADDRESS,
				getValue(detailMap, FSPConstants.BILLING_FAILURE_TO_ADDRESS));
		properties.setProperty(FSPConstants.BILLING_FAILURE_CC_ADDRESS,
				getValue(detailMap, FSPConstants.BILLING_FAILURE_CC_ADDRESS));
		properties.setProperty(FSPConstants.BILLING_WARNING_TO_ADDRESS,
				getValue(detailMap, FSPConstants.BILLING_WARNING_TO_ADDRESS));
		properties.setProperty(FSPConstants.BILLING_FAILURE_FROM_ADDRESS,
				getValue(detailMap, FSPConstants.BILLING_FAILURE_FROM_ADDRESS));
		properties.setProperty(FSPConstants.BILLING_WARNING_CC_ADDRESS,
				getValue(detailMap, FSPConstants.BILLING_WARNING_CC_ADDRESS));
		properties.setProperty(FSPConstants.CDR_USAGE_EMAIL_CC,
				getValue(detailMap, FSPConstants.CDR_USAGE_EMAIL_CC));
		properties.setProperty(FSPConstants.CDR_USAGE_EMAIL_FROM,
				getValue(detailMap, FSPConstants.CDR_USAGE_EMAIL_FROM));

	}

	private static String getValue(Map<String, Object> map, String key) {
		String retVal = FSPConstants.EMPTY;
		try {
			retVal = (String) map.get(key);
		} catch (Exception exc) {
			// Suppress warning
		}

		return (retVal == null) ? FSPConstants.EMPTY : retVal;
	}

}
