package com.fonality.dao;

import java.util.List;

import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.bu.entity.OrderGroup;

@Repository
@Transactional
public class OrderGroupDAOImpl extends AbstractDAO<OrderGroup> implements
		OrderGroupDAO {

	@Override
	public List<OrderGroup> getOrderGroupListByOrderId(long orderId) {
		return this.sessionFactory.getCurrentSession()
				.createQuery("from OrderGroup where orders.orderId=" + orderId)
				.list();
	}

	public OrderGroup loadOrderGroupByserver(Integer serverId) {
		return (OrderGroup) this.sessionFactory.getCurrentSession().createQuery(
				"from OrderGroup  where serverId = :serverId")
						.setParameter("serverId", serverId).uniqueResult();
		
	}
	
	@Override
	public OrderGroup loadOrderGroup(int orderGroupId) {
		OrderGroup retVal = null;
		try {
			retVal = this.load(orderGroupId);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
		return retVal;

	}

	@Override
	public OrderGroup saveOrderGroup(OrderGroup orderGroup) {
		try {
			orderGroup = this.save(orderGroup);
		} catch (HibernateException e) {
			e.printStackTrace();
		}

		return orderGroup;
	}

	@Override
	public void deleteOrderGroup(OrderGroup orderGroup) {
		try {
			this.delete(orderGroup);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
	}

	@Override
	protected Class getType() {
		return OrderGroup.class;
	}

}
