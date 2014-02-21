package com.fonality.test.service;

import static org.junit.Assert.assertNull;

import org.apache.log4j.Logger;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.search.CdrUsageVO;
import com.fonality.service.CdrUsageService;
import com.fonality.service.EmailService;
import com.fonality.util.DateUtils;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestCdrUsageService extends AbstractTransactionalJUnit4SpringContextTests {

	@Autowired
	public CdrUsageService cdrUsageService;

	@Autowired
	EmailService emailService;

	private static final Logger LOGGER = Logger.getLogger(TestCdrUsageService.class.getName());

	@Rollback(true)
	@Test
	public void testCreateInvoice() {
		String retVal = null;
		try {

			CdrUsageVO cdrUsageVO = new CdrUsageVO();
			cdrUsageVO.setEmailAddress("satya_veni@yahoo.com");
			cdrUsageVO.setFirstName("Satya");
			cdrUsageVO.setLastName("Boddu");
			cdrUsageVO.setStartDate(DateUtils.formatDate("11/01/12", DateUtils.USA_DATETIME));
			cdrUsageVO.setEndDate(DateUtils.formatDate("12/31/12", DateUtils.USA_DATETIME));
			cdrUsageVO.setCustomerId(29179);

			retVal = cdrUsageService.emailCdrUsageReport(cdrUsageVO);

		} catch (Exception exc) {
			LOGGER.error("Error occurred in generating and emailing usage report ", exc);
		}

		assertNull(retVal);
	}
}
