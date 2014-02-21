package com.fonality.util;

import java.io.IOException;
import java.net.InetAddress;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Properties;

public class BillSoftProperties {
	
	private static Properties properties = null;
	private static boolean testMode;
	
	/**
	 * Retrieve the properties associated with connections to BillSoft
	 * @param testFlag An flag indicating whether or not we will be connecting to BillSoft in test mode (true for test mode, false for live)
	 * @return The properties
	 * @throws IOException
	 */
	public static Properties getProperties(boolean testFlag) throws IOException {
		
		if (properties == null) {
			testMode = testFlag;
			initProperties();
		}
		
		return properties;
	}
	
	public static void initProperties() throws IOException {
		
		ConfigReader dbConfigReader = new ConfigReader(FSPConstants.BILLSOFT_CONFIG_FILE_NAME);
		//Retrieve entire config file as a map
		Map<String, Object> masterMap = dbConfigReader.getConfigMap(); 
		//Map Billsoft properties
		//Retrieve the list of transaction modes as a map
		Map<String, Object> modeMap = (Map<String, Object>)masterMap.get("billsoft");
		Map<String, String> detailMap;
		if (testMode) { 
			detailMap = (Map<String, String>)modeMap.get("test");
		} else {
			detailMap = (Map<String, String>)modeMap.get("live");
		}
		properties = new Properties();
		properties.setProperty("xmlns", detailMap.get("xmlns"));
		properties.setProperty("user", detailMap.get("user"));
		properties.setProperty("pass", detailMap.get("pass"));
		properties.setProperty("namespaceURI", detailMap.get("namespaceURI"));
		String companyID = detailMap.get("companyID");
		if (ObjectUtils.isValid(companyID))
			properties.setProperty("companyID", companyID);
		//Map VATs
		Map<String, Double> vatMap = (Map<String, Double>)masterMap.get("VAT");
		for (Entry<String, Double> keyValuePair : vatMap.entrySet()) {
			properties.setProperty(keyValuePair.getKey(), Double.toString(keyValuePair.getValue()));
		}
	}
	
}
