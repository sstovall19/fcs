package com.fonality.util;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Map;
import java.util.Properties;

/**
 * HibernateProperties is a singleton class that loads a configuration file into a Java Properties object, making 
 * Hibernate-specific properties available for consumption by other FCS classes
 * @author jvannorman
 *
 */
public class HibernateProperties {
	
	private static Properties properties = null;
	
	/**
	 * Retrieves the hibernate properties, initializing if necessary
	 * @return The hibernate properties object
	 * @throws IOException If any read errors occur while loading the properties object from the configuration file
	 */
	public static Properties getProperties() throws IOException {
		
		if (properties == null) {
			initProperties();
		}
		
		return properties;
	}
	
	/**
	 * Initializes the properties object by creating a series of nested maps from the known structure of the base
	 * configuration file. The key/value pairs of one "leaf" map are used to populate the properties object.
	 * In addition, this method creates a hibernate.properties file in the same directory as the base config file.
	 * The properties file is necessary for bootstrapping Spring
	 * @throws IOException
	 */
	public static void initProperties() throws IOException {
		
		File propFile = new File(System.getenv(FSPConstants.CONFIG_PATH_ENV_NAME) + "/hibernate.properties");
		ConfigReader dbConfigReader = new ConfigReader(FSPConstants.DB_CONFIG_FILE_NAME);
		//Only create new properties file if it does not exist or config file is more recent
		if (!propFile.exists() || propFile.lastModified() < dbConfigReader.getConfigModifiedDate()) {
			//Retrieve entire config file as a map
			Map<String, Object> masterMap = dbConfigReader.getConfigMap(); 
			//Retrieve the list of database hosts as a map
			Map<String, Object> hostMap = (Map<String, Object>)masterMap.get("databases");
			Map<String, Object> typeMap;
			String hostName = InetAddress.getLocalHost().getHostName();
			if (hostMap.containsKey(hostName)) {
				typeMap = (Map<String, Object>)hostMap.get(hostName);
			} else {
				typeMap = (Map<String, Object>)hostMap.get("default");
			}
			Map<String, String> detailMap;
			String windir = System.getenv("windir");
			//Development servers will have the name "dev" or be windows machines
			if (hostName.contains("dev") || ObjectUtils.isValid(windir)) { 
				detailMap = (Map<String, String>)typeMap.get("devel");
			} else {
				detailMap = (Map<String, String>)typeMap.get("production");
			}
			properties = new Properties();
			properties.setProperty("host", detailMap.get("host"));
			properties.setProperty("uname", detailMap.get("user"));
			properties.setProperty("pass", detailMap.get("pass"));
			String testFlag = System.getenv("FCS_TEST");
			if (ObjectUtils.isValid(testFlag) && testFlag.equals("1")) {
				properties.setProperty("dbname", "fcstest");
			} else {
				properties.setProperty("dbname", "fcs");
			}
			
			FileOutputStream fos = new FileOutputStream(propFile);
			properties.store(fos, "");
		}		
	}
	
}
