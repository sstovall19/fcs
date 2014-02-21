package com.fonality.test.dao;

import static org.junit.Assert.assertNotNull;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.dao.BundlePriceModelDAO;

/**
 * @author Fonality
 * 
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestBundlePriceModelDAO extends
	AbstractTransactionalJUnit4SpringContextTests {

    @Autowired
    public BundlePriceModelDAO bundlePriceModelDAO;

    @Test
    public void testBundlePriceModel() {
    	assertNotNull(bundlePriceModelDAO.getTaxMappingByPriceModelId(1, 5));
    }

}
