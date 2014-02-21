package com.fonality.suretax.entity;

import java.math.BigDecimal;
import java.util.List;

/**
 * GenericRequest is a serialization class for SureTax API requests. This class represents the JSON request as a whole.
 * @author Fonality
 *
 */
public class GenericRequest {
	private String ClientNumber;
	private String BusinessUnit;
	private String ValidationKey;
	private String DataYear;
	private String DataMonth;
	private BigDecimal TotalRevenue;
	private String ReturnFileCode;
	private String ClientTracking;
	private String ResponseGroup;
	private String ResponseType;
	private List<Item> ItemList;
	public String getClientNumber() {
		return ClientNumber;
	}
	public void setClientNumber(String clientNumber) {
		this.ClientNumber = clientNumber;
	}
	public String getBusinessUnit() {
		return BusinessUnit;
	}
	public void setBusinessUnit(String businessUnit) {
		this.BusinessUnit = businessUnit;
	}
	public String getValidationkey() {
		return ValidationKey;
	}
	public void setValidationkey(String validationkey) {
		this.ValidationKey = validationkey;
	}
	public String getDataYear() {
		return DataYear;
	}
	public void setDataYear(String dataYear) {
		this.DataYear = dataYear;
	}
	public String getDataMonth() {
		return DataMonth;
	}
	public void setDataMonth(String dataMonth) {
		this.DataMonth = dataMonth;
	}
	public BigDecimal getTotalRevenue() {
		return TotalRevenue;
	}
	public void setTotalRevenue(BigDecimal totalRevenue) {
		this.TotalRevenue = totalRevenue;
	}
	public String getReturnFileCode() {
		return ReturnFileCode;
	}
	public void setReturnFileCode(String returnFileCode) {
		this.ReturnFileCode = returnFileCode;
	}
	public String getClientTracking() {
		return ClientTracking;
	}
	public void setClientTracking(String clientTracking) {
		this.ClientTracking = clientTracking;
	}
	public String getResponseGroup() {
		return ResponseGroup;
	}
	public void setResponseGroup(String responseGroup) {
		this.ResponseGroup = responseGroup;
	}
	public String getResponseType() {
		return ResponseType;
	}
	public void setResponseType(String responseType) {
		this.ResponseType = responseType;
	}
	public List<Item> getItemList() {
		return ItemList;
	}
	public void setItemList(List<Item> itemList) {
		this.ItemList = itemList;
	}
	
	
}
