package com.fonality.dao;

import java.util.Date;
import java.util.List;

import com.fonality.bu.entity.ConcordCdrTest;
import com.fonality.bu.entity.UnboundCdrTest;

public interface ConcordCdrDAO {
	
	public List<ConcordCdrTest> getCdrList (int serverId, Date startDate, Date endDate);
	
	public  ConcordCdrTest loadCdr(String uniqueId);

}
