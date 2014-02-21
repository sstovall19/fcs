package com.fonality.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.msgpack.MessagePack;
import org.msgpack.template.Template;
import org.msgpack.template.Templates;
import org.msgpack.type.Value;

import static org.msgpack.template.Templates.TString;
import static org.msgpack.template.Templates.TValue;
import org.yaml.snakeyaml.Yaml;

/**
 * ConfigReader enables the reading of FCS YAML configuration files. This class is meant for use by the various
 * utility "properties" classes within FCS.
 * 
 * Instances of this class will expect an appropriately-name YAML config file with the extension ".conf" to exist.
 * This class is intended to also work with an optional ".mp" MessagePack config file
 * @author jvannorman
 *
 */
public class ConfigReader {
	
	private File configFile;
	private File mPackFile;
	
	/**
	 * Initializes a new ConfigReader object using the provided config file name. All FCS config files
	 * are assumed to exist under the same directory, defined by FSPConstants.CONFIG_PATH_ENV_NAME
	 * 
	 * @param configName The relative path (including file name) to the configuration file from the configuration root
	 */
	public ConfigReader(String configName) {
		String configFileStub = System.getenv(FSPConstants.CONFIG_PATH_ENV_NAME) + "/" + configName;

		String configFileName = configFileStub + FSPConstants.CONFIG_FILE_EXTENSION;
		configFile = new File(configFileName);			
		String mPackFileName = configFileStub + FSPConstants.CONFIG_FILE_PACK_EXTENSION;
		mPackFile = new File(mPackFileName);
		
	}

	/**
	 * Reads the configuration file, creating an object map representation of the file contents
	 * This method is meant to try reading the MessagePack file first. If that file does not exist, it
	 * will read the YAML file instead.
	 * Currently, MessagePack read functionality is not working, and this method always defaults to YAML
	 * @return An Object map with String keys
	 * @throws FileNotFoundException If no YAML config file with the expected name exists
	 */
	public Map<String, Object> getConfigMap() throws FileNotFoundException {

//		if (mPackFile.exists()) {
//			long mPackModDate = mPackFile.lastModified();
//			if (mPackModDate >= configFile.lastModified()) {
//				try {
//					return getMapFromMessagePack();
//				} catch (IOException e) {
//					return getMapFromConfigFile();
//				}
//			}
//		}
		/* Ideally, we'd like to try to get the info from the message pack, but we'll 
		 * have to leave the above code commented out until someone figures out how to
		 * make that work
		 */
		return getMapFromConfigFile();
	}
	
	/**
	 * Returns the "last modified" date of the most up-to-date version of the config file
	 * @return the modification date, in milliseconds
	 */
	public long getConfigModifiedDate() {

		long configModDate = configFile.lastModified();
		if (mPackFile.exists()) {
			long mPackModDate = mPackFile.lastModified();
			if (mPackModDate >= configModDate) {
				return mPackModDate;
			}
		}
		return configModDate;
	}
	
	/**
	 * Reads the YAML configuration file, creating an object map representation of the file contents. In addition,
	 * this method will cteate a new messagePack config file with contents matching those of the YAMP file
	 * @return An Object map with String keys 
	 * @throws FileNotFoundException If no YAML config file with the expected name exists
	 */
	private Map<String, Object> getMapFromConfigFile() throws FileNotFoundException {
		Map<String, Object> confMap = null;
		FileInputStream fis = null;
		MessagePack mPack = new MessagePack();
		try {
			Yaml yaml = new Yaml();
			fis = new FileInputStream(configFile);
			confMap = (Map<String, Object>) yaml.load(fis);
			FileOutputStream fos = new FileOutputStream(mPackFile);
			try {
				mPack.write(fos, confMap);
			} catch (IOException e) {
				// Just give up
			} finally {
				if (fos != null) {
					try {
						fos.close();
					} catch (IOException e) {
					}
				}

			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (fis != null) {
				try {
					fis.close();
				} catch (IOException e) {
				}
			}
		}
		return confMap;
	}

	/**
	 * Reads the MessagePack configuration file, creating an object map representation of the file contents.
	 * This method does function correctly at this time
	 * @return An Object map with String keys 
	 * @throws IOException
	 */
	private Map<String, Object> getMapFromMessagePack() throws IOException {

		Map<String, Object> confMap = new HashMap<String, Object>();
		FileInputStream fis = null;
		MessagePack mPack = new MessagePack();
//		Template<Map<String, Value>> mapTmpl = Templates.tMap(TString, TValue);
		try {
			fis = new FileInputStream(mPackFile);
			confMap = (Map<String, Object>)mPack.read(fis, confMap.getClass());
		} finally {
			if (fis != null) {
				try {
					fis.close();
				} catch (IOException e) {
				}
			}
		}
		System.out.println("Got map with keys: " + confMap.keySet().size());
		return confMap;

	}
}
