package com.fonality.bu.entity.json;

import org.json.JSONException;
import org.json.JSONObject;

import com.fonality.util.FSPConstants;

public class TransformEstimate extends Input {

	private static final long serialVersionUID = -3501052527564737120L;

	private long fromId;
	private String fromType;
	private String toType;

	private TransformRecordDefault recordDefault;

	public TransformEstimate() throws Exception {
		super(new JSONObject());
	}

	/**
	 * @throws JSONException
	 */
	public TransformEstimate(long estimateId, long locationId, String expectedShipDate)
			throws Exception {
		this();
		try {

			this.setFromId(estimateId);
			this.setFromType(FSPConstants.NETSUITE_ESTIMATE_RECORD);
			this.setToType(FSPConstants.NETSUITE_SALES_ORDER_RECORD);
			this.setRecordDefault(new TransformRecordDefault());
			this.getRecordDefault().setSalesOrderDefaults(locationId, expectedShipDate);

		} catch (Exception exc) {
			exc.printStackTrace();
		}
	}

	/**
	 * @return the fromId
	 */
	public long getFromId() {
		return fromId;
	}

	/**
	 * @param fromId
	 *            the fromId to set
	 */
	public void setFromId(long fromId) {
		this.fromId = fromId;
		this.setJSONValue("fromId", this.fromId);
	}

	/**
	 * @return the fromType
	 */
	public String getFromType() {
		return fromType;
	}

	/**
	 * @param fromType
	 *            the fromType to set
	 */
	public void setFromType(String fromType) {
		this.fromType = fromType;
		this.setJSONValue("fromType", this.fromType);
	}

	/**
	 * @return the toType
	 */
	public String getToType() {
		return toType;
	}

	/**
	 * @param toType
	 *            the toType to set
	 */
	public void setToType(String toType) {
		this.toType = toType;
		this.setJSONValue("toType", this.toType);
	}

	/**
	 * @return the recordDefault
	 */
	public TransformRecordDefault getRecordDefault() {
		return recordDefault;
	}

	/**
	 * @param recordDefault
	 *            the recordDefault to set
	 */
	public void setRecordDefault(TransformRecordDefault recordDefault) {
		this.recordDefault = recordDefault;
		this.setJSONValue("recordDefault", this.recordDefault.getJSONObject());
	}

}
