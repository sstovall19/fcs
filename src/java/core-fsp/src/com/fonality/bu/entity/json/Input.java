package com.fonality.bu.entity.json;

import org.apache.commons.lang.StringUtils;
import org.json.JSONException;
import org.json.JSONObject;

import com.fonality.util.FSPConstants;

public class Input extends BaseInput {

	private static final long serialVersionUID = -9072739226518106214L;

	private String orderId;
	private String orderGroupId;
	private String mode;
	private String orderStatus;
	private String orderComment;
	private String errorMessage;
	private String errorModule;
	private String customerId;
	private String startDate;
	private String endDate;
	private String serverId;
	private String status;
	private String url;
	private CreditCard creditCard;
	private Address billingAddress;

	public Input(JSONObject jsonObject) throws JSONException {
		super(jsonObject);
	}

	public Input() {
		super();
	}

	public String getOrderId() {
		return orderId;
	}

	public void setOrderId(String orderId) {
		this.orderId = orderId;
		this.setJSONValue("order_id", this.orderId);
	}

	@Override
	protected void populateJSONData() {
		try {
			try {
				this.orderId = getString(FSPConstants.INPUT_JSON_ORDER_ID);
			} catch (Exception exc) {
				// Suppress errors
				exc.printStackTrace();
			}

			// Parse OrderInvoiceHandler BU input data
			try {
				JSONObject creditCardObj = this.getJSONObject().getJSONObject(
						FSPConstants.INPUT_JSON_CREDIT_CARD);
				if (creditCardObj != null) {
					this.creditCard = new CreditCard(creditCardObj);
				}

				JSONObject billingAddressObj = this.getJSONObject().getJSONObject(
						FSPConstants.INPUT_JSON_BILLING);

				if (billingAddressObj != null) {
					this.billingAddress = new Address(billingAddressObj);
				}
			} catch (Exception exc) {
				// Suppress errors
			}

			// Parse Error handler BU input data
			try {
				this.errorMessage = getString("error_message");
				this.errorModule = getString("error_module");
			} catch (Exception exc) {
				// Suppress errors
			}

			// Parse Usage report handler BU input data
			try {
				this.customerId = getString("customer_id");
				this.startDate = getString("start_date");
				this.endDate = getString("end_date");
				this.serverId = getString("server_id");
			} catch (Exception exc) {
				// Suppress errors
			}

			// Parse Create/Get signed EchoSign Document BU input data
			try {
				this.orderGroupId = getString("order_group_id");
				this.mode = getString("mode");
			} catch (Exception exc) {
				// Suppress errors
			}

		} catch (Exception exc) {
			// exc.printStackTrace();
		}
	}

	/**
	 * @return the orderStatus
	 */
	public String getOrderStatus() {
		return orderStatus;
	}

	/**
	 * @param orderStatus
	 *            the orderStatus to set
	 */
	public void setOrderStatus(String orderStatus) {
		this.orderStatus = orderStatus;
		this.setJSONValue("order_status", this.orderStatus);
	}

	/**
	 * @return the orderComment
	 */
	public String getOrderComment() {
		return orderComment;
	}

	/**
	 * @param orderComment
	 *            the orderComment to set
	 */
	public void setOrderComment(String orderComment) {
		this.orderComment = orderComment;
		this.setJSONValue("order_comment", this.orderComment);
	}

	/**
	 * @return the creditCard
	 */
	public CreditCard getCreditCard() {
		return creditCard;
	}

	/**
	 * @param creditCard
	 *            the creditCard to set
	 */
	public void setCreditCard(CreditCard creditCard) {
		this.creditCard = creditCard;
	}

	/**
	 * @return the billingAddress
	 */
	public Address getBillingAddress() {
		return billingAddress;
	}

	/**
	 * @param billingAddress
	 *            the billingAddress to set
	 */
	public void setBillingAddress(Address billingAddress) {
		this.billingAddress = billingAddress;
	}

	/**
	 * @return the errorMessage
	 */
	public String getErrorMessage() {
		return errorMessage;
	}

	/**
	 * @param errorMessage
	 *            the errorMessage to set
	 */
	public void setErrorMessage(String errorMessage) {
		this.errorMessage = errorMessage;
		this.setJSONValue("error_message", this.errorMessage);
	}

	/**
	 * @return the errorModule
	 */
	public String getErrorModule() {
		return errorModule;
	}

	/**
	 * @param errorModule
	 *            the errorModule to set
	 */
	public void setErrorModule(String errorModule) {
		this.errorModule = errorModule;
		this.setJSONValue("error_module", this.errorModule);
	}

	/**
	 * @return the customerId
	 */
	public Integer getCustomerId() {
		return (StringUtils.isNotEmpty(customerId) ? Integer.parseInt(customerId) : null);
	}

	/**
	 * @param customerId
	 *            the customerId to set
	 */
	public void setCustomerId(String customerId) {
		this.customerId = customerId;
		this.setJSONValue("customer_id", this.customerId);
	}

	/**
	 * @return the startDate
	 */
	public String getStartDate() {
		return startDate;
	}

	/**
	 * @param startDate
	 *            the startDate to set
	 */
	public void setStartDate(String startDate) {
		this.startDate = startDate;
		this.setJSONValue("start_date", this.startDate);
	}

	/**
	 * @return the endDate
	 */
	public String getEndDate() {
		return endDate;
	}

	/**
	 * @param endDate
	 *            the endDate to set
	 */
	public void setEndDate(String endDate) {
		this.endDate = endDate;
		this.setJSONValue("end_date", this.endDate);
	}

	/**
	 * @return the serverId
	 */
	public String getServerId() {
		return serverId;
	}

	/**
	 * @param serverId
	 *            the serverId to set
	 */
	public void setServerId(String serverId) {
		this.serverId = serverId;
		this.setJSONValue("server_id", this.serverId);
	}

	/**
	 * @return the orderGroupId
	 */
	public String getOrderGroupId() {
		return orderGroupId;
	}

	/**
	 * @param orderGroupId
	 *            the orderGroupId to set
	 */
	public void setOrderGroupId(String orderGroupId) {
		this.orderGroupId = orderGroupId;
		this.setJSONValue("order_group_id", this.orderGroupId);
	}

	/**
	 * @return the mode
	 */
	public String getMode() {
		return mode;
	}

	/**
	 * @param mode
	 *            the mode to set
	 */
	public void setMode(String mode) {
		this.mode = mode;
		this.setJSONValue("mode", this.mode);
	}

	/**
	 * @return the status
	 */
	public String getStatus() {
		return status;
	}

	/**
	 * @param status
	 *            the status to set
	 */
	public void setStatus(String status) {
		this.status = status;
		this.setJSONValue("status", this.status);
	}

	/**
	 * @return the url
	 */
	public String getUrl() {
		return url;
	}

	/**
	 * @param url
	 *            the url to set
	 */
	public void setUrl(String url) {
		this.url = url;
		this.setJSONValue("url", this.url);
	}

}
