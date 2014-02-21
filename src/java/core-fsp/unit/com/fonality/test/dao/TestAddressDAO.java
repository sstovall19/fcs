package com.fonality.test.dao;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.dao.AddressDAO;
import com.fonality.dao.ContactDAO;

/**
 * @author Fonality
 * 
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestAddressDAO extends
	AbstractTransactionalJUnit4SpringContextTests {

    @Autowired
    public AddressDAO addressDAO;

    @Test
    public void testAddress() {
	assertTrue(addressDAO.getAddressList().size() > 0);

	assertNull(addressDAO.loadAddress(-1));
	assertNotNull(addressDAO.loadAddress(1));
    }

}
