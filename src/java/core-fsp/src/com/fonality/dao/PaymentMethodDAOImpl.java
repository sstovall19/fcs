package com.fonality.dao;

import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.PaymentMethod;

@Repository
public class PaymentMethodDAOImpl extends AbstractDAO<PaymentMethod> implements
		PaymentMethodDAO {

	@Override
	public PaymentMethod loadPaymentMethod(int paymentMethodId) {
		return this.load(paymentMethodId);
	}

	@Override
	protected Class getType() {
		return PaymentMethod.class;
	}

}
