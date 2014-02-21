package com.fonality.test.dao;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.dao.OrderCategoryDAO;

/**
 * @author Fonality
 * 
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestOrderCategoryDAO extends
	AbstractTransactionalJUnit4SpringContextTests {

    @Autowired
    public OrderCategoryDAO orderCategoryDAO;

    @Test
    public void testOrderCategory() {
    	assertNotNull(orderCategoryDAO.loadOrderCategory(1));
    	assertTrue(orderCategoryDAO.getOrderCategoryListByProductId(8).size() > 0);
    }

}
