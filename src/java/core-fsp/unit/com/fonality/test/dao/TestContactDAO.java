package com.fonality.test.dao;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.dao.ContactDAO;

/**
 * @author Fonality
 * 
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestContactDAO extends
	AbstractTransactionalJUnit4SpringContextTests {

    @Autowired
    public ContactDAO contactDAO;

    @Test
    public void testContact() {
	assertTrue(contactDAO.getContactList().size() > 0);

	assertNull(contactDAO.loadContact(-1));
	assertNotNull(contactDAO.loadContact(1));
    }

}
