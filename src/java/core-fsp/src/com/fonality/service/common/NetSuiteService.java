package com.fonality.service.common;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.URL;
import java.util.Properties;

import javax.xml.rpc.ServiceException;

import net.spy.memcached.MemcachedClient;

import org.apache.log4j.Logger;

import com.fonality.util.MemcachedProperties;
import com.fonality.util.NetSuiteProperties;
import com.netsuite.webservices.platform.core_2012_2.Passport;
import com.netsuite.webservices.platform.core_2012_2.RecordRef;
import com.netsuite.webservices.platform.core_2012_2.Status;
import com.netsuite.webservices.platform_2012_2.NetSuiteBindingStub;
import com.netsuite.webservices.platform_2012_2.NetSuitePortType;
import com.netsuite.webservices.platform_2012_2.NetSuiteServiceLocator;

public class NetSuiteService {

	private static final Logger LOGGER = Logger.getLogger(NetSuiteService.class
			.getName());
	private static int RETRY_MILLIS = 5000;

	private NetSuitePortType port;

	public void initializeAndLogin() throws IOException, ServiceException,
			InterruptedException {

		System.setProperty("axis.socketSecureFactory",
				"org.apache.axis.components.net.SunFakeTrustSocketFactory");
		// Locate the NetSuite web service.
		NetSuiteServiceLocator service = new NetSuiteServiceLocator();
		// Enable client cookie management. This is required.
		service.setMaintainSession(true);

		Properties nsProps = NetSuiteProperties.getProperties();
		port = service.getNetSuitePort(new URL(nsProps.getProperty("ws.url")));
		// Setting client timeout
		((NetSuiteBindingStub) port).setTimeout(Integer.parseInt(nsProps
				.getProperty("timeout.millis")));

		Passport passport = new Passport();
		RecordRef role = new RecordRef();
		passport.setAccount(nsProps.getProperty("account"));
		passport.setEmail(nsProps.getProperty("user"));
		passport.setPassword(nsProps.getProperty("pass"));
		role.setInternalId(nsProps.getProperty("role"));
		passport.setRole(role);

		// setPreferences(port);
		// Here we need to check for a lock on the login
		Properties cacheProps = MemcachedProperties.getProperties();
		String host = cacheProps.getProperty("host");
		String portNum = cacheProps.getProperty("port");
		MemcachedClient cache = new MemcachedClient(new InetSocketAddress(host,
				Integer.parseInt(portNum)));
		Boolean isLocked = (Boolean) cache.get("nsLoginLocked");
		while (isLocked != null && isLocked) {
			LOGGER.debug("NetSuite login locked. Retrying in " + RETRY_MILLIS
					+ " milliseconds...");
			Thread.sleep(5000);
			isLocked = (Boolean) cache.get("nsLoginLocked");
		}
		// System.out.println("Host = " + host + ", port = " + portNum);
		Status status = (port.login(passport)).getStatus();
		if (status.isIsSuccess()) {
			cache.set("nsLoginLocked", 0, true);
		} else {
			throw new RuntimeException(
					"NetSuiteService: Unable to login to NetSuite");
		}
	}

	public void logout() throws IOException {

		Properties cacheProps = MemcachedProperties.getProperties();
		String host = cacheProps.getProperty("host");
		String portNum = cacheProps.getProperty("port");
		MemcachedClient cache = new MemcachedClient(new InetSocketAddress(host,
				Integer.parseInt(portNum)));
		cache.set("nsLoginLocked", 0, false);
		port.logout();
	}

	/**
	 * @return the port
	 */
	public NetSuitePortType getPort() {
		return port;
	}

	/**
	 * @param port
	 *            the port to set
	 */
	public void setPort(NetSuitePortType port) {
		this.port = port;
	}

}
