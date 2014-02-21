package com.fonality.billing;

import org.apache.log4j.Logger;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import com.fonality.billing.service.BillingTransactionService;
import com.fonality.util.HibernateProperties;

public class BillingMain {

	private static final Logger LOGGER = Logger.getLogger(BillingMain.class.getName());
	protected static ApplicationContext context;

	public BillingMain() {
		setContext();
	}

	public static void main(String[] args) {

		try {

			BillingMain bm = new BillingMain();
			HibernateProperties.initProperties();
			context = new ClassPathXmlApplicationContext("classpath:application-context.xml");

			BillingTransactionService billingTransactionService = (BillingTransactionService) context
					.getBean("billingTransactionService");

			billingTransactionService.processAllScheduled();
		} catch (Exception e) {
			LOGGER.error("Main - Exception: ", e);
		}

	}

	public void setContext() {
		context = new ClassPathXmlApplicationContext("classpath:application-context.xml");
	}

}
