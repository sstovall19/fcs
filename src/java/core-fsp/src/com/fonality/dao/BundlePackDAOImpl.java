package com.fonality.dao;

import java.util.List;

import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.BundlePacking;
import com.fonality.util.ObjectUtils;

@Repository
public class BundlePackDAOImpl extends AbstractDAO<BundlePacking> implements
	BundlePackDAO {

    @Override
    public BundlePacking getBundlePackByBundleId(long bundleId) {
	BundlePacking retVal = null;
	List<BundlePacking> bundlePackList = this.sessionFactory
		.getCurrentSession()
		.createQuery(
			"from BundlePack where bundle.bundleId=" + bundleId)
		.list();

	if (ObjectUtils.isValid(bundlePackList)) {
	    retVal = bundlePackList.get(0);
	}

	return retVal;
    }

    @Override
    public BundlePacking loadBundlePack(long bundlePackId) {
	BundlePacking retVal = null;
	try {
	    retVal = this.load(bundlePackId);
	} catch (HibernateException e) {
	    e.printStackTrace();
	}
	return retVal;

    }

    @Override
    public BundlePacking saveBundlePack(BundlePacking bundlePack) {
	try {
	    bundlePack = this.save(bundlePack);
	} catch (HibernateException e) {
	    e.printStackTrace();
	}

	return bundlePack;

    }

    @Override
    public void deleteBundlePack(BundlePacking bundlePack) {
	try {
	    this.delete(bundlePack);
	} catch (HibernateException e) {
	    e.printStackTrace();
	}
    }

    @Override
    protected Class getType() {
	return BundlePacking.class;
    }

}
