package com.fonality.suretax.entity;

import java.util.List;

/**
 * GenericResponse is a deserialization class for SureTax API responses. This class represents the JSON response as a whole
 * @author Fonality
 *
 */
public class GenericResponse {

	private String Successful;
	private String ResponseCode;
	private String HeaderMessage;
	private List<ItemMessage> ItemMessages;
	private String ClientTracking;
	private String TotalTax;
	private long TransId;
	private List<Group> GroupList;
	
	public String getSuccessful() {
		return Successful;
	}
	public void setSuccessful(String successful) {
		Successful = successful;
	}
	public String getResponseCode() {
		return ResponseCode;
	}
	public void setResponseCode(String responseCode) {
		ResponseCode = responseCode;
	}
	public String getHeaderMessage() {
		return HeaderMessage;
	}
	public void setHeaderMessage(String headerMessage) {
		HeaderMessage = headerMessage;
	}
	public List<ItemMessage> getItemMessages() {
		return ItemMessages;
	}
	public void setItemMessages(List<ItemMessage> itemMessages) {
		ItemMessages = itemMessages;
	}
	public String getClientTracking() {
		return ClientTracking;
	}
	public void setClientTracking(String clientTracking) {
		ClientTracking = clientTracking;
	}
	public String getTotalTax() {
		return TotalTax;
	}
	public void setTotalTax(String totalTax) {
		TotalTax = totalTax;
	}
	public long getTransId() {
		return TransId;
	}
	public void setTransId(long transId) {
		TransId = transId;
	}
	public List<Group> getGroupList() {
		return GroupList;
	}
	public void setGroupList(List<Group> groupList) {
		GroupList = groupList;
	}

	
}
