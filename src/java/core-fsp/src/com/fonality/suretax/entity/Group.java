package com.fonality.suretax.entity;

import java.util.List;

/**
 * Group is a deserialization class for SureTax API responses. The overall JSON response, if successful, will conatin one or
 * more Group records in a list, each Group being a grouping of Tax records
 * @author Fonality
 *
 */
public class Group {
	private String StateCode;
	private String InvoiceNumber;
	private String CustomerNumber;
	private List<Tax> TaxList;
	
	public String getStateCode() {
		return StateCode;
	}
	public void setStateCode(String stateCode) {
		StateCode = stateCode;
	}
	public String getInvoiceNumber() {
		return InvoiceNumber;
	}
	public void setInvoiceNumber(String invoiceNumber) {
		InvoiceNumber = invoiceNumber;
	}
	public String getCustomerNumber() {
		return CustomerNumber;
	}
	public void setCustomerNumber(String customerNumber) {
		CustomerNumber = customerNumber;
	}
	public List<Tax> getTaxList() {
		return TaxList;
	}
	public void setTaxList(List<Tax> taxList) {
		TaxList = taxList;
	}
	
}
