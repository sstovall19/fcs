package com.fonality.test.dao;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.dao.ProductDAO;

/**
 * @author Fonality
 * 
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestProductDAO extends
	AbstractTransactionalJUnit4SpringContextTests {

    @Autowired
    public ProductDAO productDAO;

    @Test
    public void testProduct() {
	assertEquals(0, productDAO.getProductListByDeploymentId(-1).size());
	assertTrue(productDAO.getProductListByDeploymentId(1).size() > 0);

	assertNull(productDAO.loadProduct(-1));
	assertNotNull(productDAO.loadProduct(6));
    }

}
