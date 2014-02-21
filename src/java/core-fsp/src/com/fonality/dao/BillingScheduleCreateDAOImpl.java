package com.fonality.dao;

import java.util.Date;
import java.util.List;

import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.UnboundCdrTest;

public class BillingScheduleCreateDAOImpl extends AbstractDAO<BillingSchedule>
											implements BillingScheduleCreateDAO {

	
	public List<Integer> getServersList (Date startDate, Date endDate) {
		return this.sessionFactory.getCurrentSession().createQuery(
				"select DISTINCT serverId from UnboundCdrTest where disposition = 'ANSWERED'"
					+ " and calldate >= :startDate and calldate < :endDate")
						.setParameter("startDate", startDate)
						.setParameter("endDate", endDate).list();
				
	}
	
	public List<Integer> getFaxServersList(Date startDate, Date endDate) {
		return this.sessionFactory.getCurrentSession().createQuery (
				"select DISTINCT customCode2 from ConcordCdrTest where " +
				" epochGMT >= unix_timestamp( :startDate) and epochGMT < unix_timestamp( :endDate)")
				.setParameter("startDate", startDate)
				.setParameter("endDate", endDate).list();
		
	}
	
	
	public Integer getOrderGroupIdByServer (Integer serverId) {
		return (Integer) this.sessionFactory.getCurrentSession().createQuery(
				"select orderGroupId from OrderGroup  where serverId = :serverId")
						.setParameter("serverId", serverId).uniqueResult();
				
	}
	

	public Long isOrderGroupHasRented (Integer orderGroupId) {
		return (Long) this.sessionFactory.getCurrentSession().createQuery(
				"select count(*) from OrderBundle where order_group_id = :orderGroupId and is_rented = 1")
						.setParameter("orderGroupId", orderGroupId).uniqueResult();
				
	}
	
	@Override
	protected Class<BillingSchedule> getType() {
		// TODO Auto-generated method stub
		return null;
	}

	
}
