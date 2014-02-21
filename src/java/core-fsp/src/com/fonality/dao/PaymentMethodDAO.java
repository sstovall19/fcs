package com.fonality.dao;

import com.fonality.bu.entity.PaymentMethod;

public interface PaymentMethodDAO {

	/**
	 * Method to load paymentMethod by paymentMethod id
	 * 
	 * @return the paymentMethod
	 */
	public PaymentMethod loadPaymentMethod(int paymentMethodId);

}
