package com.fonality.suretax.entity;

/**
 * Tax is a deserialization class for SureTax API responses. A successful response will include one or more taxes for each
 * Group record in the response. These tax records are broken down into codes, descriptions, and amounts
 * @author Fonality
 *
 */
public class Tax {
	private String TaxTypeCode;
	private String TaxTypeDesc;
	private String TaxAmount;
	
	/**
	 * Retrieves the tax type code for this tax
	 * @return The type code
	 */
	public String getTaxTypeCode() {
		return TaxTypeCode;
	}
	public void setTaxTypeCode(String taxTypeCode) {
		TaxTypeCode = taxTypeCode;
	}
	/**
	 * Returns the description of this tax
	 * @return The description
	 */
	public String getTaxTypeDesc() {
		return TaxTypeDesc;
	}
	public void setTaxTypeDesc(String taxTypeDesc) {
		TaxTypeDesc = taxTypeDesc;
	}
	/**
	 * Returns the total amount of this tax
	 * @return The amount
	 */
	public String getTaxAmount() {
		return TaxAmount;
	}
	public void setTaxAmount(String taxAmount) {
		TaxAmount = taxAmount;
	}
}
