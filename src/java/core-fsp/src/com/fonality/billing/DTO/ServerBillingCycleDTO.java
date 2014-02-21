package com.fonality.billing.DTO;

import java.util.Date;

import com.fonality.util.DateUtils;

public class ServerBillingCycleDTO {
	
	private Integer serverId;
	private String startDate;
	private String endDate;
	
	
	public ServerBillingCycleDTO (Integer serverId, String startDate, String endDate) {
		this.serverId=serverId;
		this.startDate=startDate;
		this.endDate=endDate;
	}
	
	public Integer getServerId() {
		return serverId;
	}
	
	public void setServerId(Integer serverId) {
		this.serverId = serverId;
	}
	
	public Date getStartDate() {
		return  DateUtils.formatDate(startDate, DateUtils.USA_DATETIME);
	}
	
	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}
	
	public Date getEndDate() {
		return  DateUtils.formatDate(endDate, DateUtils.USA_DATETIME);
	}
	
	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}
	
	public String toString () {
		
		return "serverId: "+serverId+ " startDate: "+startDate+ " endDate: "+endDate;
	}
	
}
