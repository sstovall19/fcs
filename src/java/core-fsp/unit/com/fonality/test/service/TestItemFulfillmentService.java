package com.fonality.test.service;

import static org.junit.Assert.assertNotNull;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.service.ItemFulfillmentService;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestItemFulfillmentService extends AbstractTransactionalJUnit4SpringContextTests {

	@Autowired
	public ItemFulfillmentService itemFulfillmentService;

	@Rollback(true)
	@Test
	public void testPrintLabel() {
		byte[] retVal = null;
		try {
			retVal = itemFulfillmentService.getPrintLabelContents(1177561, 1179268);

		} catch (Exception exc) {
			exc.printStackTrace();
		}

		assertNotNull(retVal);

	}

}
