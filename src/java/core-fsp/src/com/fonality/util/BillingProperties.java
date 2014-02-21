package com.fonality.util;

import java.io.IOException;
import java.util.Map;
import java.util.Properties;

public class BillingProperties {

	private static Properties properties = null;

	public static Properties getProperties() throws IOException {

		if (properties == null) {
			initProperties();
		}

		return properties;
	}

	public static void initProperties() throws IOException {

		ConfigReader dbConfigReader = new ConfigReader(
				FSPConstants.BILLING_CONFIG_FILE_NAME);

		// Retrieve entire config file as a map
		Map<String, Object> masterMap = dbConfigReader.getConfigMap();
		// Retrieve the list of transaction modes as a map
		Map<String, Object> paymentMap = (Map<String, Object>) masterMap
				.get("netsuite_payment_ids");

		properties = new Properties();
		properties.setProperty(FSPConstants.NETSUITE_PAYMENT_METHOD_VISA,
				((Integer) paymentMap.get("visa")).toString());
		properties.setProperty(FSPConstants.NETSUITE_PAYMENT_METHOD_MASTERCARD,
				((Integer) paymentMap.get("mastercard")).toString());
		properties.setProperty(FSPConstants.NETSUITE_PAYMENT_METHOD_AMEX,
				((Integer) paymentMap.get("american_express")).toString());
		properties.setProperty(FSPConstants.NETSUITE_PAYMENT_METHOD_DISCOVER,
				((Integer) paymentMap.get("discover")).toString());

	}

}
