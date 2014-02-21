package com.fonality.dao;

import java.util.List;

import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.bu.entity.OrderBundle;

@Repository
public class OrderBundleDAOImpl extends AbstractDAO<OrderBundle> implements
		OrderBundleDAO {

	@Override
	public List<OrderBundle> getOrderBundleListByOrderGroupId(
			Integer orderGroupId) {
		return this.sessionFactory
				.getCurrentSession()
				.createQuery(
						"from OrderBundle where order_group_id=" + orderGroupId)
				.list();
	}

	@Override
	public List<OrderBundle> getOrderBundleListByBundleId(Integer bundleId) {
		return this.sessionFactory.getCurrentSession()
				.createQuery("from OrderBundle where bundle_id=" + bundleId)
				.list();
	}

	@Override
	public OrderBundle loadOrderBundle(int orderBundleId) {
		OrderBundle retVal = null;
		try {
			retVal = this.load(orderBundleId);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
		return retVal;

	}

	@Override
	public OrderBundle saveOrderBundle(OrderBundle orderBundle) {
		try {
			orderBundle = this.save(orderBundle);
		} catch (HibernateException e) {
			e.printStackTrace();
		}

		return orderBundle;

	}

	@Override
	public void deleteOrderBundle(OrderBundle orderBundle) {
		try {
			this.delete(orderBundle);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
	}

	@Override
	protected Class getType() {
		return OrderBundle.class;
	}

}
