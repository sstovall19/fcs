package com.fonality.util;

import java.io.IOException;
import java.net.InetAddress;
import java.util.List;
import java.util.Map;
import java.util.Properties;

/**
 * MemcachedProperties is a singleton class that loads a configuration file into a Java Properties
 * object, making Memcached-specific properties available for consumption by other FCS classes
 * 
 * @author jvannorman
 */
public class MemcachedProperties {

	private static Properties properties = null;

	/**
	 * Retrieve the properties associated with connections to Memcached
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

	/**
	 * Initializes the properties object by creating a series of nested maps from the known
	 * structure of the base configuration file. The key/value pairs of one "leaf" map are used to
	 * populate the properties object.
	 * 
	 * @throws IOException
	 */
	public static void initProperties() throws IOException {

		ConfigReader dbConfigReader = new ConfigReader(FSPConstants.MEMCACHED_CONFIG_FILE_NAME);
		//Retrieve entire config file as a map
		Map<String, Object> masterMap = dbConfigReader.getConfigMap();
		//Retrieve the list of servers as a map
		Map<String, Object> serverMap = (Map<String, Object>) masterMap.get("servers");
		List hostStrings;
		if (true) { //Change me!
			hostStrings = (List) serverMap.get(FSPConstants.CONFIG_SERVER_DEV);
		} else {
			hostStrings = (List) serverMap.get(FSPConstants.CONFIG_SERVER_PROD);
		}
		String hostPort = (String) hostStrings.get(0);
		int colonPos = hostPort.indexOf(':');
		properties = new Properties();
		String host = hostPort.substring(0, colonPos);

		String hostName = InetAddress.getLocalHost().getHostName();
		if (!hostName.contains("dev")) {
			host = "127.0.0.1";
		}
		properties.setProperty("host", host);
		properties.setProperty("port", hostPort.substring(colonPos + 1));

	}

}
