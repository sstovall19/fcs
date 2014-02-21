package com.fonality.dao;

import java.util.List;

import org.hibernate.Query;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.bu.entity.BundlePriceModel;
import com.fonality.bu.entity.TaxMapping;

public class BundlePriceModelDAOImpl extends AbstractDAO<BundlePriceModel>implements BundlePriceModelDAO {

	@Override
	public TaxMapping getTaxMappingByPriceModelId(Integer bundleId, Integer priceModelId) {
		Query transTypeQuery = this.sessionFactory.getCurrentSession()
				.createQuery("FROM TaxMapping TM WHERE TM.taxMappingId = (SELECT taxMapping.taxMappingId FROM BundlePriceModel BPM WHERE BPM.priceModel.priceModelId = :priceModelId AND BPM.bundle.bundleId = :bundleId)");
		transTypeQuery.setParameter("priceModelId", priceModelId);
		transTypeQuery.setParameter("bundleId", bundleId);
		List<TaxMapping> transTypeList = transTypeQuery.list();
		
		if (transTypeList.isEmpty()) {
			return null;
		} else {
			return transTypeList.get(0);
		}	}

	@Override
	protected Class<BundlePriceModel> getType() {
		return BundlePriceModel.class;
	}

}
