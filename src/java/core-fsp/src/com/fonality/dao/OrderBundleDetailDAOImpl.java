package com.fonality.dao;

import java.util.List;

import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.OrderBundleDetail;

@Repository
public class OrderBundleDetailDAOImpl extends AbstractDAO<OrderBundleDetail>
	implements OrderBundleDetailDAO {

    @Override
    public List<OrderBundleDetail> getOrderBundleDetailListByOrderBundleId(
	    Integer orderBundleId) {
	return this.sessionFactory
		.getCurrentSession()
		.createQuery(
			"from OrderBundleDetail where orderBundleId="
				+ orderBundleId).list();
    }

    @Override
    public OrderBundleDetail loadOrderBundleDetail(long orderBundleId) {
	OrderBundleDetail retVal = null;
	try {
	    retVal = this.load(orderBundleId);
	} catch (HibernateException e) {
	    e.printStackTrace();
	}
	return retVal;

    }

    @Override
    public OrderBundleDetail saveOrderBundleDetail(OrderBundleDetail orderBundle) {
	try {
	    orderBundle = this.save(orderBundle);
	} catch (HibernateException e) {
	    e.printStackTrace();
	}

	return orderBundle;

    }

    @Override
    public void deleteOrderBundleDetail(OrderBundleDetail orderBundle) {
	try {
	    this.delete(orderBundle);
	} catch (HibernateException e) {
	    e.printStackTrace();
	}
    }

    @Override
    protected Class getType() {
	return OrderBundleDetail.class;
    }

}
