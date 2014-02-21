package com.fonality.bu.entity.json;

import org.json.JSONException;
import org.json.JSONObject;

import com.fonality.util.BillingProperties;
import com.fonality.util.DateUtils;
import com.fonality.util.FSPConstants;
import com.netsuite.webservices.lists.relationships_2012_2.CustomerCreditCards;

public class CreditCard extends Input {

	private static final long serialVersionUID = -4838723978819534938L;

	private String ccType;
	private String ccNumber;
	private String ccExpireDate;
	private String ccName;

	private String paymentMethodId;
	private Integer customerId;
	private Long customerNetSuiteId;
	private Integer creditCardId;

	/**
	 * @throws JSONException
	 */
	public CreditCard() throws JSONException {
		super();
	}

	public CreditCard(JSONObject jsonObject) throws JSONException {
		super(jsonObject);
	}

	/**
	 * @param customerCreditCard
	 * @throws Exception
	 */
	public CreditCard(CustomerCreditCards customerCreditCard) throws Exception {
		this.ccType = customerCreditCard.getPaymentMethod().getName();
		this.ccNumber = customerCreditCard.getCcNumber();
		this.ccExpireDate = DateUtils.convertDateToString(customerCreditCard.getCcExpireDate()
				.getTime(), DateUtils.USA_DATETIME_YYYY);
		this.ccName = customerCreditCard.getCcName();

		this.paymentMethodId = customerCreditCard.getPaymentMethod().getInternalId();
	}

	@Override
	protected void populateJSONData() {
		try {
			this.ccType = this.getString("type");
			this.ccNumber = this.getString("number");
			this.ccExpireDate = this.getString("expire_date");
			this.ccName = this.getString("name");

			this.paymentMethodId = (String) BillingProperties.getProperties().get(this.ccType);

		} catch (Exception exc) {
			// exc.printStackTrace();
		}
	}

	/**
	 * @return the ccType
	 */
	public String getCcType() {
		return ccType;
	}

	/**
	 * @param ccType
	 *            the ccType to set
	 */
	public void setCcType(String ccType) {
		this.ccType = ccType;
		this.setJSONValue("type", this.ccType);
	}

	/**
	 * @return the ccNumber
	 */
	public String getCcNumber() {
		return ccNumber;
	}

	/**
	 * @param ccNumber
	 *            the ccNumber to set
	 */
	public void setCcNumber(String ccNumber) {
		this.ccNumber = ccNumber;
		this.setJSONValue("number", this.ccNumber);
	}

	/**
	 * @return the ccExpireDate
	 */
	public String getCcExpireDate() {
		return ccExpireDate;
	}

	/**
	 * @return the ccExpireDate
	 */
	public boolean getExpireDate() {
		return (ccExpireDate.equals("1") ? true : false);
	}

	/**
	 * @param ccExpireDate
	 *            the ccExpireDate to set
	 */
	public void setCcExpireDate(String ccExpireDate) {
		this.ccExpireDate = ccExpireDate;
		this.setJSONValue("expire_date", this.ccExpireDate);
	}

	/**
	 * @return the ccName
	 */
	public String getCcName() {
		return ccName;
	}

	/**
	 * @param ccName
	 *            the ccName to set
	 */
	public void setCcName(String ccName) {
		this.ccName = ccName;
		this.setJSONValue("name", this.ccName);
	}

	/**
	 * @return the customerId
	 */
	public Integer getCustomerId() {
		return customerId;
	}

	/**
	 * @param customerId
	 *            the customerId to set
	 */
	public void setCustomerId(Integer customerId) {
		this.customerId = customerId;
	}

	/**
	 * @return the paymentMethodId
	 */
	public String getPaymentMethodId() {
		return paymentMethodId;
	}

	/**
	 * @param paymentMethodId
	 *            the paymentMethodId to set
	 */
	public void setPaymentMethodId(String paymentMethodId) {
		this.paymentMethodId = paymentMethodId;
	}

	/**
	 * @return the creditCardId
	 */
	public Integer getCreditCardId() {
		return creditCardId;
	}

	/**
	 * @param creditCardId
	 *            the creditCardId to set
	 */
	public void setCreditCardId(Integer creditCardId) {
		this.creditCardId = creditCardId;
	}

	/**
	 * @return the customerNetSuiteId
	 */
	public Long getCustomerNetSuiteId() {
		return customerNetSuiteId;
	}

	/**
	 * @param customerNetSuiteId
	 *            the customerNetSuiteId to set
	 */
	public void setCustomerNetSuiteId(Long customerNetSuiteId) {
		this.customerNetSuiteId = customerNetSuiteId;
	}

	/*
	 * (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "CreditCard [ccType=" + ccType + ", ccNumber=" + ccNumber + ", ccExpireDate="
				+ ccExpireDate + ", ccName=" + ccName + ", customerId=" + customerId
				+ ", paymentMethodId=" + paymentMethodId + "]";
	}

	/*
	 * (non-Javadoc)
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		int result = 1;
		result = FSPConstants.HASHCODE_PRIME * result
				+ ((ccNumber == null) ? 0 : ccNumber.hashCode());
		return result;
	}

	/*
	 * (non-Javadoc)
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		CreditCard other = (CreditCard) obj;
		if (ccNumber == null) {
			if (other.ccNumber != null)
				return false;
		} else if (!ccNumber.equals(other.ccNumber))
			return false;
		return true;
	}

}
