package com.fonality.suretax.entity;

import java.util.List;

/**
 * ItemMessage is a deserialization class for SureTax API responses. If an API request contains erroneous line items, then the
 * response will include ItemMessage records indicating the per-line errors
 * @author Fonality
 *
 */
public class ItemMessage {
	//ExtensionData
	private String LineNumber;
	private String ResponseCode;
	private String Message;
	
	public String getLineNumber() {
		return LineNumber;
	}
	public void setLineNumber(String lineNumber) {
		LineNumber = lineNumber;
	}
	public String getResponseCode() {
		return ResponseCode;
	}
	public void setResponseCode(String responseCode) {
		ResponseCode = responseCode;
	}
	public String getMessage() {
		return Message;
	}
	public void setMessage(String message) {
		Message = message;
	}
	
}
