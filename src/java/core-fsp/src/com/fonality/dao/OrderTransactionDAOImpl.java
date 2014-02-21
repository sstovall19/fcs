package com.fonality.dao;

import java.util.List;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.OrderTransaction;
import com.fonality.bu.entity.OrderTransactionItem;

@Repository
public class OrderTransactionDAOImpl extends AbstractDAO<OrderTransaction>
		implements OrderTransactionDAO {

	private static Logger logger = Logger.getLogger(OrderTransactionDAO.class
			.getName());

	@Override
	public List<OrderTransaction> getOrderTransactionListByOrderGroupId(
			long orderGroupId) {
		return this.sessionFactory
				.getCurrentSession()
				.createQuery(
						"from OrderTransaction where orderId=" + orderGroupId)
				.list();
	}

	@Override
	public List<OrderTransactionItem> getItemsByOrderTransactionId(
			long orderTransactionId) {
		return this.sessionFactory
				.getCurrentSession()
				.createQuery(
						"from OrderTransactionItem where orderTransaction.orderTransactionId ="
								+ orderTransactionId).list();
	}

	@Override
	public OrderTransaction loadOrderTransaction(int orderTransactionId) {
		OrderTransaction retVal = null;
		try {
			retVal = this.load(orderTransactionId);
		} catch (HibernateException e) {
			logger.error("Error occurred on loading order transaction ", e);
		}
		return retVal;

	}

	@Override
	public OrderTransaction saveOrderTransaction(
			OrderTransaction orderTransaction) {
		try {
			orderTransaction = this.save(orderTransaction);
		} catch (HibernateException e) {
			logger.error("Error occurred on saving order transaction ", e);
		}

		return orderTransaction;
	}

	@Override
	public void deleteOrderTransaction(OrderTransaction orderTransaction) {
		try {
			this.delete(orderTransaction);
		} catch (HibernateException e) {
			logger.error("Error occurred on deleting order transaction ", e);
		}
	}

	@Override
	protected Class getType() {
		return OrderTransaction.class;
	}

}
