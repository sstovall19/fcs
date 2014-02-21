package com.fonality.dao;

import java.util.List;

import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.Bundle;

@Repository
public class BundleDAOImpl extends AbstractDAO<Bundle> implements BundleDAO {

	@Override
	public Bundle loadBundle(int bundleId) {
		Bundle retVal = null;
		try {
			retVal = this.load(bundleId);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
		return retVal;

	}

	@Override
	public Bundle saveBundle(Bundle bundle) {
		try {
			bundle = this.save(bundle);
		} catch (HibernateException e) {
			e.printStackTrace();
		}

		return bundle;
	}

	@Override
	public void deleteBundle(Bundle bundle) {
		try {
			this.delete(bundle);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
	}

	@Override
	protected Class getType() {
		return Bundle.class;
	}

	@Override
	public Bundle getBundleByName(String bundleName) {
		List<Bundle> bundleList = this.sessionFactory.getCurrentSession()
				.createQuery("from Bundle " + "where name='" + bundleName + "'").list();
		if (bundleList != null && bundleList.size() > 0)
			return bundleList.get(0);
		else
			return null;
	}

	@Override
	public List<Bundle> getBundleByPartialName(String bundleName) {
		List<Bundle> bundleList = this.sessionFactory.getCurrentSession()
				.createQuery("from Bundle " + "where name like '" + bundleName + "'").list();

		return bundleList;
	}

	@Override
	public Integer getBundleCategoryIdByName(String bundleCategoryName) {
		Integer bundleCategoryId = (Integer) this.sessionFactory
				.getCurrentSession()
				.createQuery(
						"SELECT bundleCategoryId FROM BundleCategory "
								+ "where name = :bundleCategoryName")
				.setParameter("bundleCategoryName", bundleCategoryName).uniqueResult();

		return bundleCategoryId;
	}
}
