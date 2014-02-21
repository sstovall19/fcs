package com.fonality.bu.entity;

import java.math.BigDecimal;
import java.util.GregorianCalendar;

import com.billsoft.eztaxasp.ArrayOfTaxData;

public class TaxTuple {
	Short transactionType;
	Short serviceType;
	BigDecimal totalPrice;
	boolean isMonthly;
	double usageMinutes = 0.000;
	ArrayOfTaxData taxArray = null;
	String sourceNpaNxx;
	String destNpaNxx;
	GregorianCalendar date;
	

	public TaxTuple(Short transType, Short servType, BigDecimal price, boolean isMonthly) {
		this.transactionType = transType;
		this.serviceType = servType;
		this.totalPrice = price;
		this.isMonthly = isMonthly;
	}
	
	public TaxTuple(Short transType, Short servType, BigDecimal price) {
		this.transactionType = transType;
		this.serviceType = servType;
		this.totalPrice = price;
	}

	public Short getTransactionType() {
		return transactionType;
	}

	public void setTransactionType(Short transactionType) {
		this.transactionType = transactionType;
	}

	public Short getServiceType() {
		return serviceType;
	}

	public void setServiceType(Short serviceType) {
		this.serviceType = serviceType;
	}

	public BigDecimal getTotalPrice() {
		return totalPrice;
	}

	public void setTotalPrice(BigDecimal totalPrice) {
		this.totalPrice = totalPrice;
	}

	public boolean isMonthly() {
		return isMonthly;
	}

	public void setMonthly(boolean isMonthly) {
		this.isMonthly = isMonthly;
	}

	public double getUsageMinutes() {
		return usageMinutes;
	}

	public void setUsageMinutes(double usageMinutes) {
		this.usageMinutes = usageMinutes;
	}

	public ArrayOfTaxData getTaxArray() {
		return taxArray;
	}

	public void setTaxArray(ArrayOfTaxData taxArray) {
		this.taxArray = taxArray;
	}

	public String getSourceNpaNxx() {
		return sourceNpaNxx;
	}

	public void setSourceNpaNxx(String sourceNpaNxx) {
		this.sourceNpaNxx = sourceNpaNxx;
	}

	public String getDestNpaNxx() {
		return destNpaNxx;
	}

	public void setDestNpaNxx(String destNpaNxx) {
		this.destNpaNxx = destNpaNxx;
	}

	public GregorianCalendar getDate() {
		return date;
	}

	public void setDate(GregorianCalendar date) {
		this.date = date;
	}

	@Override
	public String toString() {
		return "TaxTuple [transactionType=" + transactionType
				+ ", serviceType=" + serviceType + ", totalPrice=" + totalPrice
				+ ", isMonthly=" + isMonthly + ", usageMinutes=" + usageMinutes
				+ ", taxArray=" + taxArray + ", sourceNpaNxx=" + sourceNpaNxx
				+ ", destNpaNxx=" + destNpaNxx + ", date=" + date + "]";
	}

}
