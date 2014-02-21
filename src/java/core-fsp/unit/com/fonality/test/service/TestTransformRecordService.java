package com.fonality.test.service;

import static org.junit.Assert.assertNotNull;

import java.util.Date;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.service.TransformRecordService;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestTransformRecordService extends AbstractTransactionalJUnit4SpringContextTests {

	@Autowired
	public TransformRecordService transformRecordService;

	@Rollback(true)
	@Test
	public void testCreateSalesOrder() {
		Long salesOrderId = null;
		try {
			salesOrderId = transformRecordService
					.createOrderFromEstimate(1121190l, 20l, new Date());
		} catch (Exception exc) {
			exc.printStackTrace();
		}

		assertNotNull(salesOrderId);
	}

	@Rollback(true)
	@Test
	public void testCreateEstimate() {
		Long estimateId = null;
		try {
			estimateId = transformRecordService.createEstimateFromOpportunity(1166112, 4033, 6, 10);
		} catch (Exception exc) {
			exc.printStackTrace();
		}

		assertNotNull(estimateId);
	}
}
