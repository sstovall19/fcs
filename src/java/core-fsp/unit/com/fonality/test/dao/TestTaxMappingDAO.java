package com.fonality.test.dao;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.dao.PaymentMethodDAO;
import com.fonality.dao.TaxMappingDAO;

/**
 * @author Fonality
 * 
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestTaxMappingDAO extends
	AbstractTransactionalJUnit4SpringContextTests {

    @Autowired
    public TaxMappingDAO taxMappingDAO;

    @Test
    public void testTaxMapping() {
    	assertNotNull(taxMappingDAO.loadTaxMapping(1));
    	assertTrue(taxMappingDAO.getBSServiceTypeForId(1) > 0);
    	assertTrue(taxMappingDAO.getBSTransTypeForId(1) > 0);
    }

}
