package com.fonality.dao;

import java.util.Date;
import java.util.List;

import com.fonality.bu.entity.UnboundCdrTest;

public interface BillingScheduleCreateDAO {
	
	public List<Integer> getServersList(Date startDate, Date endDate);
	
	public List<Integer> getFaxServersList(Date startDate, Date endDate);
	
	public Integer getOrderGroupIdByServer (Integer serverId);
	
	public Long isOrderGroupHasRented (Integer orderGroupId);

}
