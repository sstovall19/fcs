package com.fonality.billing.service;

import java.util.List;

import org.springframework.context.ApplicationContext;

import com.fonality.bu.entity.BillingSchedule;

public interface BillingProcessorService {
	
	public long bsProcessor (BillingSchedule bs);
	
}
