package com.fonality.dao;

import java.util.Date;
import java.util.List;

import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.UnboundCdrTest;

@Repository
public class UnboundCdrTestDAOImpl extends AbstractDAO<UnboundCdrTest>
		implements UnboundCdrTestDAO {

	@Override
	public List<UnboundCdrTest> getCdrList(int serverId, Date startDate,
			Date endDate) {

		return this.sessionFactory
				.getCurrentSession()
				.createQuery(
						"from UnboundCdrTest where serverId = :serverId  and disposition = 'ANSWERED'"
								+ " and calldate >= :startDate and calldate < :endDate")
				.setParameter("serverId", serverId)
				.setParameter("startDate", startDate)
				.setParameter("endDate", endDate).list();

	}

	@Override
	public UnboundCdrTest loadCdr(String uniqueId) {
		return this.load(uniqueId);

	}

	@Override
	protected Class getType() {
		return UnboundCdrTest.class;
	}

}
