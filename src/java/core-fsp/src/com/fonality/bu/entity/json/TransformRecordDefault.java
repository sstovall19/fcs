package com.fonality.bu.entity.json;

import org.json.JSONException;
import org.json.JSONObject;

import com.fonality.util.FSPConstants;

public class TransformRecordDefault extends Input {

	private static final long serialVersionUID = -4643419067306007372L;

	// Sales Order default fields
	private long locationId;
	private String expectedShipDate;

	// Estimate default fields;
	private int termsInMonths;
	private long shippingMethod;
	private int numberOfUsers;

	/**
	 * @throws JSONException
	 */
	public TransformRecordDefault() throws Exception {
		super(new JSONObject());
	}

	/**
	 * Method to set default values for sales order record
	 * 
	 * @param locationId
	 * @param expectedShipDate
	 * @throws JSONException
	 */
	public void setSalesOrderDefaults(long locationId, String expectedShipDate) {
		try {
			this.setLocationId(locationId);
			this.setExpectedShipDate(expectedShipDate);
		} catch (Exception exc) {
			exc.printStackTrace();
		}
	}

	/**
	 * Method to set default values for estimate record
	 * 
	 * @param locationId
	 * @param expectedShipDate
	 * @throws JSONException
	 */
	public void setEstimateDefaults(int numberOfUsers, int termsInMonths, long shippingMethod) {
		try {
			this.setNumberOfUsers(numberOfUsers);
			this.setTermsInMonths(termsInMonths);
			this.setShippingMethod(shippingMethod);
		} catch (Exception exc) {
			exc.printStackTrace();
		}
	}

	/**
	 * @return the locationId
	 */
	public long getLocationId() {
		return locationId;
	}

	/**
	 * @param locationId
	 *            the locationId to set
	 */
	public void setLocationId(long locationId) {
		this.locationId = locationId;
		this.setJSONValue(FSPConstants.CUSTOM_ORDER_LOCATION_FLD, this.locationId);
	}

	/**
	 * @return the expectedShipDate
	 */
	public String getExpectedShipDate() {
		return expectedShipDate;
	}

	/**
	 * @param expectedShipDate
	 *            the expectedShipDate to set
	 */
	public void setExpectedShipDate(String expectedShipDate) {
		this.expectedShipDate = expectedShipDate;
		this.setJSONValue(FSPConstants.CUSTOM_ORDER_EXP_SHIP_DATE_FLD, this.expectedShipDate);
	}

	/**
	 * @return the termsInMonths
	 */
	public int getTermsInMonths() {
		return termsInMonths;
	}

	/**
	 * @param termsInMonths
	 *            the termsInMonths to set
	 */
	public void setTermsInMonths(int termsInMonths) {
		this.termsInMonths = termsInMonths;
		this.setJSONValue(FSPConstants.CUSTOM_EST_TERMS_FLD, this.termsInMonths);
	}

	/**
	 * @return the shippingMethod
	 */
	public long getShippingMethod() {
		return shippingMethod;
	}

	/**
	 * @param shippingMethod
	 *            the shippingMethod to set
	 */
	public void setShippingMethod(long shippingMethod) {
		this.shippingMethod = shippingMethod;
		this.setJSONValue(FSPConstants.CUSTOM_EST_SHIP_METHOD_FLD, this.shippingMethod);
	}

	/**
	 * @return the numberOfUsers
	 */
	public int getNumberOfUsers() {
		return numberOfUsers;
	}

	/**
	 * @param numberOfUsers
	 *            the numberOfUsers to set
	 */
	public void setNumberOfUsers(int numberOfUsers) {
		this.numberOfUsers = numberOfUsers;
		this.setJSONValue(FSPConstants.CUSTOM_EST_USERS_FLD, this.numberOfUsers);
	}

}
