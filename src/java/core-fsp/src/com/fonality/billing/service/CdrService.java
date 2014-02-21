package com.fonality.billing.service;

import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import com.fonality.billing.DTO.BillableCdrDTO;
import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.UnboundCdrTest;

public interface CdrService {
	
	public List<BillableCdrDTO> getBillableCDR (Integer serverId, BillingSchedule bs, 
			HashMap <String, Integer> hmUsage, HashMap <String, BigDecimal>  hmAmount) throws Exception;
	
	public BillableCdrDTO processingCdr (UnboundCdrTest unboundCdr) throws Exception;
	
	public boolean getFaxUsage(int serverId, BillingSchedule billingSchdele, HashMap<String, 
						Integer> hmUsage, HashMap<String, BigDecimal> hmAmount) throws Exception;

}
