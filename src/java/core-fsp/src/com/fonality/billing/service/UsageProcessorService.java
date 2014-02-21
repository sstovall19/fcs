package com.fonality.billing.service;

import java.util.Date;
import java.sql.Timestamp;
import java.util.List;

import org.springframework.context.ApplicationContext;
import com.fonality.bu.entity.BillingSchedule;

public interface UsageProcessorService {
	
	public List<BillingSchedule> GetCustomersToProcess (ApplicationContext context, String selectDate);
	

}
