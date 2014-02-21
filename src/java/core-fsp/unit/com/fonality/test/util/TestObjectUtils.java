package com.fonality.test.util;

import static org.junit.Assert.assertTrue;

import org.junit.Test;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.util.ObjectUtils;
import com.fonality.util.TransactionItemComparator;
import com.netsuite.webservices.transactions.sales_2012_2.CashSaleItem;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestObjectUtils extends AbstractTransactionalJUnit4SpringContextTests {

	public TransactionItemComparator itemComparator;

	@Rollback(true)
	@Test
	public void testSetFieldValue() {
		CashSaleItem item = new CashSaleItem();
		try {
			ObjectUtils.setFieldValue(item, "Description", "testDescription");
			ObjectUtils.setFieldValue(item, "Quantity", 2.0);
		} catch (Exception exc) {
			exc.printStackTrace();
		}

		assertTrue(item.getDescription().equals("testDescription"));
		assertTrue(item.getQuantity().equals(2.0));

	}
}
