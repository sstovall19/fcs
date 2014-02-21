package com.fonality.billing.util;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;

import com.fonality.bu.entity.BillingSchedule;
import com.fonality.service.EmailService;
import com.fonality.util.FSPConstants;

public class BillingFailureHandler {
	private static final Logger LOGGER = Logger
			.getLogger(BillingFailureHandler.class.getName());

	@Autowired
	EmailService emailService;

	public void notifyBillingFailure(BillingSchedule billingSchedule,
			Integer orderTransactionId, String code, String errorMessage) {
		try {
			emailService.sendBillingFailureEmail(billingSchedule,
					orderTransactionId, code, errorMessage,
					FSPConstants.BILLING_ERROR_LEVEL);
		} catch (Exception exc) {
			LOGGER.error("Error occurred in notifying billing failure ", exc);

		}
	}

	public void notifyBillingFailure(BillingSchedule billingSchedule,
			Integer orderTransactionId, String code, String errorMessage,
			String level) {
		try {
			emailService.sendBillingFailureEmail(billingSchedule,
					orderTransactionId, code, errorMessage, level);
		} catch (Exception exc) {
			LOGGER.error("Error occurred in notifying billing failure ", exc);

		}
	}

}
