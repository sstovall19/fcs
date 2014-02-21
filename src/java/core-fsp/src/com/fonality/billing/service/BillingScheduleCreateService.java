package com.fonality.billing.service;

import java.util.Date;
import java.util.List;

import com.fonality.billing.DTO.ServerBillingCycleDTO;
import com.fonality.bu.entity.UnboundCdrTest;

public interface BillingScheduleCreateService {
	
	public boolean createScheduleForAllServers(List<ServerBillingCycleDTO>  usedServerList);
	
}
