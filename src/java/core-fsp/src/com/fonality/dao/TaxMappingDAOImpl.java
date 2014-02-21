package com.fonality.dao;

import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.TaxMapping;

@Repository
public class TaxMappingDAOImpl extends AbstractDAO<TaxMapping> implements TaxMappingDAO {

    @Override
    protected Class getType() {
    	return TaxMapping.class;
    }

	@Override
	public Integer getBSTransTypeForId(int taxMappingId) {
		
		Query transTypeQuery = this.sessionFactory.getCurrentSession()
				.createQuery("SELECT TM.bsTransType FROM TaxMapping TM WHERE TM.taxMappingId = :taxMappingId");
		transTypeQuery.setParameter("taxMappingId", taxMappingId);
		List<Integer> transTypeList = transTypeQuery.list();
		
		if (transTypeList.isEmpty()) {
			return null;
		} else {
			return transTypeList.get(0);
		}
	}

	@Override
	public Integer getBSServiceTypeForId(int taxMappingId) {
		Query serviceTypeQuery = this.sessionFactory.getCurrentSession()
				.createQuery("SELECT TM.bsServiceType FROM TaxMapping TM WHERE TM.taxMappingId = :taxMappingId");
		serviceTypeQuery.setParameter("taxMappingId", taxMappingId);
		List<Integer> serviceTypeList = serviceTypeQuery.list();
		
		if (serviceTypeList.isEmpty()) {
			return null;
		} else {
			return serviceTypeList.get(0);
		}
	}

	@Override
	public TaxMapping loadTaxMapping(int taxMappingId) {
		TaxMapping retVal = null;
		try {
			retVal = this.load(taxMappingId);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
		return retVal;
	}

}
