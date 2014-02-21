package com.fonality.bu.entity.json;

import org.json.JSONException;
import org.json.JSONObject;

public class Address extends Input {

	private static final long serialVersionUID = -3197128254222338361L;

	private String address1;
	private String address2;
	private String city;
	private String state;
	private String country;
	private String zipCode;

	public Address() throws JSONException {
		super();
	}

	public Address(JSONObject jsonObject) throws JSONException {
		super(jsonObject);
	}

	@Override
	protected void populateJSONData() {
		try {
			this.address1 = this.getString("addr1");
			this.address2 = this.getString("addr2");
			this.city = this.getString("city");
			this.state = this.getString("state_prov");
			this.country = this.getString("country");
			this.zipCode = this.getString("postal");

		} catch (Exception exc) {
			// exc.printStackTrace();
		}
	}

	/**
	 * @return the address1
	 */
	public String getAddress1() {
		return address1;
	}

	/**
	 * @param address1
	 *            the address1 to set
	 */
	public void setAddress1(String address1) {
		this.address1 = address1;
		this.setJSONValue("addr1", this.address1);
	}

	/**
	 * @return the address2
	 */
	public String getAddress2() {
		return address2;
	}

	/**
	 * @param address2
	 *            the address2 to set
	 */
	public void setAddress2(String address2) {
		this.address2 = address2;
		this.setJSONValue("addr2", this.address2);
	}

	/**
	 * @return the city
	 */
	public String getCity() {
		return city;
	}

	/**
	 * @param city
	 *            the city to set
	 */
	public void setCity(String city) {
		this.city = city;
		this.setJSONValue("city", this.city);
	}

	/**
	 * @return the state
	 */
	public String getState() {
		return state;
	}

	/**
	 * @param state
	 *            the state to set
	 */
	public void setState(String state) {
		this.state = state;
		this.setJSONValue("state_prov", this.state);
	}

	/**
	 * @return the zipCode
	 */
	public String getZipCode() {
		return zipCode;
	}

	/**
	 * @param zipCode
	 *            the zipCode to set
	 */
	public void setZipCode(String zipCode) {
		this.zipCode = zipCode;
		this.setJSONValue("postal", this.zipCode);
	}

	/**
	 * @return the country
	 */
	public String getCountry() {
		return country;
	}

	/**
	 * @param country
	 *            the country to set
	 */
	public void setCountry(String country) {
		this.country = country;
		this.setJSONValue("country", this.country);
	}

}
