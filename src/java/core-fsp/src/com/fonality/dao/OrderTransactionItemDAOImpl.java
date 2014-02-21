package com.fonality.dao;

import java.util.List;

import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.OrderTransactionItem;

@Repository
public class OrderTransactionItemDAOImpl extends
		AbstractDAO<OrderTransactionItem> implements OrderTransactionItemDAO {

	@Override
	public List<OrderTransactionItem> getItemListByTrasanctionId(
			int orderTransactionId) {
		return this.sessionFactory
				.getCurrentSession()
				.createQuery(
						"from OrderTransactionItem where orderTransaction.orderTransactionId ="
								+ orderTransactionId).list();
	}

	@Override
	public OrderTransactionItem loadOrderTransactionItem(
			int orderTransactionItemId) {
		OrderTransactionItem retVal = null;
		try {
			retVal = this.load(orderTransactionItemId);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
		return retVal;

	}

	@Override
	public OrderTransactionItem saveOrderTransactionItem(
			OrderTransactionItem orderTransactionItem) {
		try {
			orderTransactionItem = this.save(orderTransactionItem);
		} catch (HibernateException e) {
			e.printStackTrace();
		}

		return orderTransactionItem;
	}

	@Override
	public void deleteOrderTransactionItem(
			OrderTransactionItem orderTransactionItem) {
		try {
			this.delete(orderTransactionItem);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
	}

	@Override
	protected Class getType() {
		return OrderTransactionItem.class;
	}

}
