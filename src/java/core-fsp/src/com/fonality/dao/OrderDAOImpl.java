package com.fonality.dao;

import java.util.List;

import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.Orders;

@Repository
public class OrderDAOImpl extends AbstractDAO<Orders> implements OrderDAO {

	@Override
	public List<Orders> getOrderListByCustomerId(Integer custId) {
		return this.sessionFactory.getCurrentSession()
				.createQuery("from Order where customerId=" + custId).list();
	}

	@Override
	public Orders loadOrder(int orderId) {
		Orders retVal = null;
		try {
			retVal = this.load(orderId);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
		return retVal;

	}

	@Override
	public Orders saveOrder(Orders order) {
		try {
			order = this.save(order);
		} catch (HibernateException e) {
			e.printStackTrace();
		}

		return order;
	}

	@Override
	public void deleteOrder(Orders order) {
		try {
			this.delete(order);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
	}

	@Override
	protected Class getType() {
		return Orders.class;
	}

}
