package com.fonality.util;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      ObjectUtils.java
 //* Revision:      1.0
 //* Author:        Satya Boddu
 //* Created On:    Nov 27, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   Obejct Utils
 /********************************************************************************/

import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.StringTokenizer;

import org.apache.commons.lang.StringUtils;
import org.json.JSONException;
import org.json.JSONObject;

import com.fonality.bu.entity.EntityAddress;

public class ObjectUtils {

	private static final String VALUE_SEPARATOR = ",";

	/**
	 * Checks if the array has any values.
	 * 
	 * @param <T>
	 * @param objs
	 * @return
	 */
	public static <T> boolean notEmpty(T[] objs) {
		return (objs != null && objs.length > 0 && objs[0] != null ? true : false);
	}

	/**
	 * Creates a List with the data from the given array.
	 * 
	 * @param items
	 * @return
	 */
	public static <T> List<T> createList(T[] items) {

		List<T> returnValue = null;

		if (isValid(items)) {
			returnValue = Arrays.asList(items);
		}

		return returnValue;
	}

	/**
	 * Checks if the object has been initialized.
	 * 
	 * @param value
	 * @return True if non-null; false otherwise.
	 */
	public static boolean isValid(Object value) {
		return value != null;
	}

	/**
	 * Checks if the int has been initialized and greater than 0
	 * 
	 * @param value
	 * @return True if non-null and greater than 0; false otherwise.
	 */
	public static boolean isValid(Integer value) {
		return ((value != null) && (value > 0));
	}

	/**
	 * Checks if the long has been initialized and greater than 0
	 * 
	 * @param value
	 * @return True if non-null and greater than 0; false otherwise.
	 */
	public static boolean isValid(Long value) {
		return ((value != null) && (value > 0));
	}

	/**
	 * Checks if the collection has been initialized and contains any values.
	 * 
	 * @param collection
	 * @return True if non-null and non-zero-length; false otherwise.
	 */
	public static <T> boolean isValid(Collection<T> collection) {
		return collection != null && !collection.isEmpty();
	}

	/**
	 * Checks if the collection has been initialized and contains any values.
	 * 
	 * @param map
	 * @return True if non-null and non-empty; false otherwise.
	 */
	public static <K, V> boolean isValid(Map<K, V> map) {
		return map != null && !map.isEmpty();
	}

	/**
	 * Checks if the array has been initialized and contains any values.
	 * 
	 * @param array
	 * @return True if non-null and non-zero-length; false otherwise.
	 */
	public static <T> boolean isValid(T[] array) {
		return array != null && array.length > 0;
	}

	/**
	 * Checks if the string has been initialized and is not empty. If it contains all spaces, it
	 * will be considered empty.
	 * 
	 * @param string
	 * @return True if non-null and non-zero-length; false otherwise.
	 */
	public static boolean isValid(String string) {
		return string != null && string.trim().length() > 0;
	}

	/**
	 * Checks if the given Date object is non-null and occurs after the given minimum threshold
	 * Date.
	 * 
	 * @param date
	 * @param minimum
	 * @return True if non-null and >= to the given minimum Date.
	 */
	public static boolean isValid(Date date, Date minimum) {

		boolean isValid = false;

		if (date != null && minimum != null) {
			isValid = date.compareTo(minimum) > 0;
		}

		return isValid;
	}

	/**
	 * Helper method to determine whether there is a single Object is the collection. Used for Area
	 * and Airport searches to determine if there are multiple Area's or Airport's that match the
	 * users search criteria. Method assumes the collection being checked is not null or the
	 * ObjectUtils.isValid() method has been applied to it.
	 * 
	 * @param <Z>
	 * @param collection
	 * @return
	 */
	public static <Z> boolean hasOnlyOneObject(java.util.Collection<Z> collection) {
		if (collection.size() == 1) {
			return true;
		}
		return false;
	}

	/**
	 * Helper method to create a Set from a given list of Z objects
	 * 
	 * @param <Z>
	 * @param inList
	 * @return
	 */
	public static <Z> Set<Z> createUniqueSet(List<Z> inList) {
		Set<Z> uniqueSet = null;
		if (ObjectUtils.isValid(inList)) {
			uniqueSet = new HashSet<Z>();
			uniqueSet.addAll(inList);
		}
		return uniqueSet;
	}

	/**
	 * Convenience method to convert a collection into a comma separated value. If one of the values
	 * in the collection has a comma in it, make sure it is encoded/decoded appropriately otherwise
	 * it will return incorrect values.
	 * 
	 * @param <T>
	 * @param collection
	 * @return
	 */
	public static <T> String convertToCommaSeparatedValue(Collection<T> collection) {

		if (!isValid(collection)) {
			return null;
		}

		StringBuffer commaSeparatedValue = new StringBuffer();
		Iterator<T> collectionIterator = collection.iterator();

		while (collectionIterator.hasNext()) {
			Object o = collectionIterator.next();
			commaSeparatedValue.append(o);

			if (collectionIterator.hasNext()) {
				commaSeparatedValue.append(VALUE_SEPARATOR);
			}
		}

		return commaSeparatedValue.toString();
	}

	/**
	 * Convenience method to convert a comma separated value into a collection If one of the values
	 * in the comma separated value has a comma in it, make sure it is encoded/decoded appropriately
	 * otherwise it will return incorrect values.
	 * 
	 * @param <T>
	 * @param collection
	 * @return
	 */
	public static Set<String> convertCommaSeparatedValueToCollection(String commaSeparatedValue) {

		return convertDelimitedValueToCollection(commaSeparatedValue, VALUE_SEPARATOR);
	}

	/**
	 * Convenience method to convert a delimited value into a collection If one of the values in the
	 * delimited value has the delimitor in it, make sure it is encoded/decoded appropriately
	 * otherwise it will return incorrect values.
	 * 
	 * @param delimitedValue
	 * @param delimiter
	 * @return
	 */
	public static Set<String> convertDelimitedValueToCollection(String delimitedValue,
			String delimiter) {

		if (!isValid(delimitedValue) || !isValid(delimiter)) {
			return null;
		}

		Set<String> set = new HashSet<String>();
		StringTokenizer st = new StringTokenizer(delimitedValue, delimiter);

		while (st.hasMoreTokens()) {
			String token = st.nextToken();
			if (ObjectUtils.isValid(token)) {
				set.add(token.trim());
			}
		}

		return set;
	}

	/**
	 * Utility method to access getter method by name
	 * 
	 * @param object
	 * @param methodName
	 * @return method value
	 */
	public static Object getMethodValue(Object object, String methodName) {
		Object retVal = null;
		try {
			Method m = object.getClass().getMethod(methodName, new Class[] {});
			retVal = m.invoke(object, new Object[] {});
		} catch (Exception exc) {

		}

		return retVal;

	}

	/**
	 * Utility method to get the random number between 1 and specified number
	 * 
	 * @param limit
	 * @param methodName
	 * @return String
	 */
	public static Integer getRandomNumber(Integer limit) {
		Integer retVal = 1;
		try {
			// pass in the current time as as seed
			Random random = new Random(System.currentTimeMillis());
			retVal = random.nextInt(limit);
		} catch (Exception exc) {

		}

		return retVal;
	}

	/**
	 * Utility method to check if email address is valid
	 * 
	 * @param email
	 * @return boolean
	 */
	public static boolean isValidEmailAddress(String email) {
		try {
			new javax.mail.internet.InternetAddress(email, true);
		} catch (javax.mail.internet.AddressException e) {
			return false;
		}
		return true;
	}

	/**
	 * Utility method to get string value from JSONObject
	 * 
	 * @param email
	 * @param key
	 * @return boolean
	 */
	public static String getJSONString(JSONObject jsonObj, String key) {
		String retVal = null;
		try {
			if ((jsonObj != null) && !jsonObj.isNull(key)) {
				retVal = jsonObj.getString(key);
			}
		} catch (Exception exc) {
			System.err.println("Problem occurred on getting string value from json (key:" + key
					+ ")");
		}

		return retVal;

	}

	/**
	 * Utility method to get integer value from JSONObject
	 * 
	 * @param email
	 * @param key
	 * @return boolean
	 */
	public static int getJSONInteger(JSONObject jsonObj, String key) {
		int retVal = 0;
		try {
			if ((jsonObj != null) && !jsonObj.isNull(key)) {
				retVal = jsonObj.getInt(key);
			}
		} catch (Exception exc) {
			System.err.println("Proble occurred on getting int value from json (key:" + key + ")");
		}

		return retVal;

	}

	/**
	 * Utility method to get integer value from JSONObject
	 * 
	 * @param email
	 * @param key
	 * @return boolean
	 */
	public static long getJSONLong(JSONObject jsonObj, String key) {
		long retVal = 0;
		try {
			if ((jsonObj != null) && !jsonObj.isNull(key)) {
				retVal = jsonObj.getLong(key);
			}
		} catch (Exception exc) {
			System.err
					.println("Problem occurred on getting long value from json (key:" + key + ")");
		}
		return retVal;
	}

	/**
	 * Utility method to get string value from JSONObject
	 * 
	 * @param email
	 * @param key
	 * @return boolean
	 */
	public static void setJSONValue(JSONObject jsonObj, String key, Object value)
			throws JSONException {
		jsonObj.put(key, value);

	}

	/**
	 * Utility method to round BigDecimal value
	 * 
	 * @param bigDecimal
	 * @param precision
	 * @return boolean
	 */
	public static double round(BigDecimal bigDecimal, int precision) {

		BigDecimal rounded = bigDecimal.setScale(precision, BigDecimal.ROUND_HALF_UP);
		return rounded.doubleValue();
	}

	/**
	 * Utility method to invoke setter method using reflection
	 * 
	 * @param object
	 * @param fieldName
	 * @param value
	 */
	public static void setFieldValue(Object object, String fieldName, Object value)
			throws Exception {
		Method method = object.getClass().getMethod("set" + fieldName,
				new Class[] { value.getClass() });
		method.invoke(object, value);

	}

	/**
	 * Utility method to check if two entity address objects match with each other
	 * 
	 * @param address1
	 * @param address2
	 * @return boolean
	 */
	public static boolean doesAddressMatch(EntityAddress address1, EntityAddress address2) {

		StringBuilder addr1 = new StringBuilder(StringUtils.replace(address1.getAddr1()
				.toLowerCase(), FSPConstants.SPACE, FSPConstants.EMPTY))
				.append((address1.getAddr2() != null) ? StringUtils.replace(address1.getAddr2()
						.toLowerCase(), FSPConstants.SPACE, FSPConstants.EMPTY)
						: FSPConstants.EMPTY)
				.append(StringUtils.replace(address1.getCity().toLowerCase(), FSPConstants.SPACE,
						FSPConstants.EMPTY))
				.append(StringUtils.replace(address1.getCountry().toLowerCase(),
						FSPConstants.SPACE, FSPConstants.EMPTY))
				.append(StringUtils.replace(address1.getPostal().toLowerCase(), FSPConstants.SPACE,
						FSPConstants.EMPTY))
				.append(StringUtils.replace(address1.getStateProv().toLowerCase(),
						FSPConstants.SPACE, FSPConstants.EMPTY));

		StringBuilder addr2 = new StringBuilder(StringUtils.replace(address2.getAddr1()
				.toLowerCase(), FSPConstants.SPACE, FSPConstants.EMPTY))
				.append((address2.getAddr2() != null) ? StringUtils.replace(address2.getAddr2()
						.toLowerCase(), FSPConstants.SPACE, FSPConstants.EMPTY)
						: FSPConstants.EMPTY)
				.append(StringUtils.replace(address2.getCity().toLowerCase(), FSPConstants.SPACE,
						FSPConstants.EMPTY))
				.append(StringUtils.replace(address2.getCountry().toLowerCase(),
						FSPConstants.SPACE, FSPConstants.EMPTY))
				.append(StringUtils.replace(address2.getPostal().toLowerCase(), FSPConstants.SPACE,
						FSPConstants.EMPTY))
				.append(StringUtils.replace(address2.getStateProv().toLowerCase(),
						FSPConstants.SPACE, FSPConstants.EMPTY));

		return StringUtils.equalsIgnoreCase(addr1.toString(), addr2.toString());
	}
}
