package com.fonality.dao;

import java.util.Date;
import java.util.List;

import com.fonality.bu.entity.UnboundCdrTest;


public interface UnboundCdrTestDAO {
	
	/**
	 * Getting  UnboundCDR  list by Server, for a specified date range
	 * 
	 * @return the UnboundCdr List
	 */
	public List<UnboundCdrTest> getCdrList(int serverId, Date startDate, Date endDate);

	/**
	 * Loading Unbound CDR (We actually in reality will never need it).
	 * 
	 * @return nboundCdrTest
	 */
	public UnboundCdrTest loadCdr (String uniqueId);
	
	
}
