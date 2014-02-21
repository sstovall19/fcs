package com.fonality.util;

import java.io.IOException;
import java.util.Map;
import java.util.Properties;

public class ShippingMethodProperties {

	private static Properties properties = null;

	public static Properties getProperties() throws IOException {

		if (properties == null) {
			initProperties();
		}

		return properties;
	}

	public static void initProperties() throws IOException {

		ConfigReader shippingMethodConfigReader = new ConfigReader(
				FSPConstants.SHIPPING_METHOD_CONFIG_FILE_NAME);

		// Retrieve entire config file as a map
		Map<String, Object> shippingMethodMap = shippingMethodConfigReader.getConfigMap();

		properties = new Properties();

		if (ObjectUtils.isValid(shippingMethodMap)) {
			for (String method : shippingMethodMap.keySet()) {
				properties.setProperty(method, shippingMethodMap.get(method).toString());

			}
		}

	}

}
