package com.fonality.billing.DTO;

import java.util.Date;

public class BillableCdrDTO {
	
	private String uniqueId;
	private int serverId;
	private Date calldate;
	private String did;
	private String ani;
	private String dialedNumber;
	private Integer billableDuration;
	private Float customerBilledAmount;
	private String country;
	private Boolean international;
	private String direction;
	private String callType;   //(\'standard\',\'mobile\',\'tollfree\',\'emergency\',\'premium\')
	private String callUsageDisplayName; 
	
	
	
	public String getUniqueId() {
		return uniqueId;
	}
	public void setUniqueId(String uniqueId) {
		this.uniqueId = uniqueId;
	}
	public int getServerId() {
		return serverId;
	}
	public void setServerId(int serverId) {
		this.serverId = serverId;
	}
	public Date getCalldate() {
		return calldate;
	}
	public void setCalldate(Date calldate) {
		this.calldate = calldate;
	}
	public String getDid() {
		return did;
	}
	public void setDid(String did) {
		this.did = did;
	}
	public String getAni() {
		return ani;
	}
	public void setAni(String ani) {
		this.ani = ani;
	}
	public String getDialedNumber() {
		return dialedNumber;
	}
	public void setDialedNumber(String dialedNumber) {
		this.dialedNumber = dialedNumber;
	}
	public Integer getBillableDuration() {
		return billableDuration;
	}
	
	public void setBillableDuration(Integer billableDuration) {
		this.billableDuration = billableDuration;
	}
	public Float getCustomerBilledAmount() {
		return customerBilledAmount;
	}
	public void setCustomerBilledAmount(Float customerBilledAmount) {
		this.customerBilledAmount = customerBilledAmount;
	}
	public String getCountry() {
		return country;
	}
	public void setCountry(String country) {
		this.country = country;
	}
	public Boolean getInternational() {
		return international;
	}
	public void setInternational(Boolean international) {
		this.international = international;
	}
	public String getDirection() {
		return direction;
	}
	public void setDirection(String direction) {
		this.direction = direction;
	}
	public String getCallType() {
		return callType;
	}
	public void setCallType(String callType) {
		this.callType = callType;
	}
	public String getCallUsageDisplayName() {
		return callUsageDisplayName;
	}
	public void setCallUsageDisplayName(String callUsageDisplayName) {
		this.callUsageDisplayName = callUsageDisplayName;
	}

	@Override
	public String toString() {
		return "BillableCdrDTO [uniqueId=" + uniqueId + ", serverId="
				+ serverId + ", calldate=" + calldate + ", did=" + did
				+ ", ani=" + ani + ", dialedNumber=" + dialedNumber
				+ ", billableDuration=" + billableDuration
				+ ", customerBilledAmount=" + customerBilledAmount
				+ ", country=" + country + ", international=" + international
				+ ", direction=" + direction + ", callType=" + callType
				+ ", callUsageDisplayName=" + callUsageDisplayName + "]";
	}
	
}
