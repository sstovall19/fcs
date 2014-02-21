package com.fonality.suretax.entity;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

/**
 * Item is a serialization class for SureTax API requests. Each request will contain or or more Item records, representing the taxable line items
 * of an invoice
 * @author Fonality
 *
 */
public class Item {
	private String LineNumber;
	private String InvoiceNumber;
	private String CustomerNumber;
	private String OrigNumber;
	private String TermNumber;
	private String BillToNumber;
	private String Zipcode;
	private String Plus4;
	private String P2PZipcode;
	private String P2PPlus4;
	private String TransDate;
	private BigDecimal Revenue;
	private int Units;
	private String UnitType;
	private int Seconds;
	private String TaxIncludedCode;
	private String TaxSitusRule;
	private String TransTypeCode;
	private String SalesTypeCode;
	private String RegulatoryCode;
	private List<String> TaxExemptionCodeList;
	
	public String getLineNumber() {
		return LineNumber;
	}
	public void setLineNumber(String lineNumber) {
		this.LineNumber = lineNumber;
	}
	public String getInvoiceNumber() {
		return InvoiceNumber;
	}
	public void setInvoiceNumber(String invoiceNumber) {
		this.InvoiceNumber = invoiceNumber;
	}
	public String getCustomerNumber() {
		return CustomerNumber;
	}
	public void setCustomerNumber(String customerNumber) {
		this.CustomerNumber = customerNumber;
	}
	public String getOrigNumber() {
		return OrigNumber;
	}
	public void setOrigNumber(String origNumber) {
		this.OrigNumber = origNumber;
	}
	public String getTermNumber() {
		return TermNumber;
	}
	public void setTermNumber(String termnumber) {
		this.TermNumber = termnumber;
	}
	public String getBillToNumber() {
		return BillToNumber;
	}
	public void setBillToNumber(String billToNumber) {
		this.BillToNumber = billToNumber;
	}
	public String getZipcode() {
		return Zipcode;
	}
	public void setZipcode(String zipcode) {
		this.Zipcode = zipcode;
	}
	public String getPlus4() {
		return Plus4;
	}
	public void setPlus4(String plus4) {
		this.Plus4 = plus4;
	}
	public String getP2PZipcode() {
		return P2PZipcode;
	}
	public void setP2PZipcode(String p2pZipcode) {
		P2PZipcode = p2pZipcode;
	}
	public String getP2PPlus4() {
		return P2PPlus4;
	}
	public void setP2PPlus4(String p2pPlus4) {
		P2PPlus4 = p2pPlus4;
	}
	public String getTransDate() {
		return TransDate;
	}
	public void setTransDate(String transDate) {
		this.TransDate = transDate;
	}
	public BigDecimal getRevenue() {
		return Revenue;
	}
	public void setRevenue(BigDecimal revenue) {
		this.Revenue = revenue;
	}
	public int getUnits() {
		return Units;
	}
	public void setUnits(int units) {
		this.Units = units;
	}
	public String getUnitType() {
		return UnitType;
	}
	public void setUnitType(String unitType) {
		this.UnitType = unitType;
	}
	public int getSeconds() {
		return Seconds;
	}
	public void setSeconds(int seconds) {
		this.Seconds = seconds;
	}
	public String getTaxIncludedCode() {
		return TaxIncludedCode;
	}
	public void setTaxIncludedCode(String taxIncludedCode) {
		this.TaxIncludedCode = taxIncludedCode;
	}
	public String getTaxSitusRule() {
		return TaxSitusRule;
	}
	public void setTaxSitusRule(String taxSitusRule) {
		this.TaxSitusRule = taxSitusRule;
	}
	public String getTransTypeCode() {
		return TransTypeCode;
	}
	public void setTransTypeCode(String transTypeCode) {
		this.TransTypeCode = transTypeCode;
	}
	public String getSalesTypeCode() {
		return SalesTypeCode;
	}
	public void setSalesTypeCode(String salesTypeCode) {
		this.SalesTypeCode = salesTypeCode;
	}
	public List<String> getTaxExemptionCodeList() {
		return TaxExemptionCodeList;
	}
	public void setTaxExemptionCodeList(List<String> taxExemptionCodeList) {
		this.TaxExemptionCodeList = taxExemptionCodeList;
	}
	public String getRegulatoryCode() {
		return RegulatoryCode;
	}
	public void setRegulatoryCode(String regulatoryCode) {
		this.RegulatoryCode = regulatoryCode;
	}
	@Override
	public String toString() {
		return "Item [LineNumber=" + LineNumber + ", InvoiceNumber="
				+ InvoiceNumber + ", CustomerNumber=" + CustomerNumber
				+ ", OrigNumber=" + OrigNumber + ", TermNumber=" + TermNumber
				+ ", BillToNumber=" + BillToNumber + ", Zipcode=" + Zipcode
				+ ", Plus4=" + Plus4 + ", P2PZipcode=" + P2PZipcode
				+ ", P2PPlus4=" + P2PPlus4 + ", TransDate=" + TransDate
				+ ", Revenue=" + Revenue + ", Units=" + Units + ", UnitType="
				+ UnitType + ", Seconds=" + Seconds + ", TaxIncludedCode="
				+ TaxIncludedCode + ", TaxSitusRule=" + TaxSitusRule
				+ ", TransTypeCode=" + TransTypeCode + ", SalesTypeCode="
				+ SalesTypeCode + ", RegulatoryCode=" + RegulatoryCode + "]";
	}
	
	
}
