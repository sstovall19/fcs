package com.fonality.util;

import com.fonality.bu.entity.BillingSchedule;

public class BillingException extends RuntimeException {

	/**
	 * Auto-generated
	 */
	private static final long serialVersionUID = 7951371741190863852L;
	
	private String errorCode;
	private Integer transactionId;
	private BillingSchedule billingSchedule;
	
	/**
	 * Constructs a new BillingException with the specified detail message, errorCode, transactionId, and billingSchedule
	 * @param message the detail message. The detail message is saved for later retrieval by the Throwable.getMessage() method.
	 * @param errorCode The FCS error code
	 * @param transactionId The FCS transaction Id
	 * @param billingSchedule The FCS Billing Schedule record
	 */
	public BillingException(String message, String errorCode, Integer transactionId, BillingSchedule billingSchedule) {
		super(message);
		this.errorCode = errorCode;
		this.transactionId = transactionId;
		this.billingSchedule = billingSchedule;
	}
	
	/**
	 * Constructs a new BillingException with the specified detail message, errorCode, and billingSchedule
	 * @param message the detail message. The detail message is saved for later retrieval by the Throwable.getMessage() method.
	 * @param errorCode The FCS error code
	 * @param billingSchedule The FCS Billing Schedule record
	 */
	public BillingException(String message, String errorCode, BillingSchedule billingSchedule) {
		super(message);
		this.errorCode = errorCode;
		this.transactionId = null;
		this.billingSchedule = billingSchedule;
	}

	public String getErrorCode() {
		return errorCode;
	}

	public Integer getTransactionId() {
		return transactionId;
	}

	public BillingSchedule getBillingSchedule() {
		return billingSchedule;
	}
	
}
