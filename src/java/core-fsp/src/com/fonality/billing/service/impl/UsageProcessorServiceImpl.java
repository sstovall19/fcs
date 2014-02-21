package com.fonality.billing.service.impl;

import java.util.ArrayList;
import java.util.List;

import org.springframework.context.ApplicationContext;

import com.fonality.billing.service.UsageProcessorService;
import com.fonality.bu.entity.BillingSchedule;
import com.fonality.service.BillingScheduleService;

public class UsageProcessorServiceImpl implements UsageProcessorService {

	private BillingScheduleService billingScheduleService;

	@Override
	public List<BillingSchedule> GetCustomersToProcess(ApplicationContext context, String selectDate) {
		// TODO 
		List<BillingSchedule> billingCustomers = new ArrayList<BillingSchedule>();
		BillingSchedule bschedule = new BillingSchedule();

		billingScheduleService = (BillingScheduleService) context.getBean("billingScheduleService");
		billingCustomers = billingScheduleService.getCustomerListIdByDate(selectDate);
		if (billingCustomers != null && billingCustomers.size() != 0) {
			// System.out.println("UsageProcessorServiceImpl: serverId -  "+billingCustomers.get(0).getServerId());
		}

		return billingCustomers;
	}

	/**
	 * @return the billingScheduleService
	 */
	public BillingScheduleService getBillingScheduleService() {
		return billingScheduleService;
	}

	/**
	 * @param billingScheduleService
	 *            the billingScheduleService to set
	 */
	public void setBillingScheduleService(BillingScheduleService billingScheduleService) {
		this.billingScheduleService = billingScheduleService;
	}

}
