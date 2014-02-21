package com.fonality.dao;

import java.util.Date;
import java.util.List;

import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.ConcordCdrTest;
import com.fonality.bu.entity.UnboundCdrTest;

@Repository
public class ConcordCdrDAOImpl extends AbstractDAO<ConcordCdrTest> 
											implements ConcordCdrDAO {
	
	@Override
	public List<ConcordCdrTest> getCdrList(int serverId, Date startDate, Date endDate) {

		return this.sessionFactory
				.getCurrentSession()
				.createQuery( "from ConcordCdrTest where customcode2 = :serverId" +
						" and epochGMT >= unix_timestamp( :startDate) and epochGMT < unix_timestamp( :endDate)" +
						" and EventTypeDescription != 'FaxFwd'")
				.setParameter("serverId", serverId)
				.setParameter("startDate", startDate)
				.setParameter("endDate", endDate).list();
	
	}

	@Override
	public ConcordCdrTest loadCdr(String uniqueId) {
		return this.load(uniqueId);
		
		
	}
	
	@Override
	protected Class getType() {
		return UnboundCdrTest.class;
	}
	
	
}
