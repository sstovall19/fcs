package com.fonality.test.dao;

import static org.junit.Assert.assertNotNull;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.dao.PaymentMethodDAO;

/**
 * @author Fonality
 * 
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestPaymentMethodDAO extends
	AbstractTransactionalJUnit4SpringContextTests {

    @Autowired
    public PaymentMethodDAO paymentMethodDAO;

    @Test
    public void testPaymentMethod() {
    	assertNotNull(paymentMethodDAO.loadPaymentMethod(1));
    }

}
