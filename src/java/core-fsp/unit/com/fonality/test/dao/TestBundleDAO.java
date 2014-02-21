package com.fonality.test.dao;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.dao.BundleDAO;
import com.fonality.dao.BundlePackDAO;
import com.fonality.dao.OrderBundleDAO;
import com.fonality.dao.OrderBundleDetailDAO;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestBundleDAO extends AbstractTransactionalJUnit4SpringContextTests {

	@Autowired
	public BundleDAO bundleDAO;

	@Autowired
	public BundlePackDAO bundlePackDAO;

	@Autowired
	public OrderBundleDAO orderBundleDAO;

	@Autowired
	public OrderBundleDetailDAO orderBundleDetailDAO;

	@Test
	public void testBundle() {
		assertNull(bundleDAO.loadBundle(-1));
	}

	@Test
	public void testBundleCategory() {
		assertNull(bundleDAO.getBundleCategoryIdByName("test"));
		assertNotNull(bundleDAO.getBundleCategoryIdByName("usage_charge"));
	}

}
