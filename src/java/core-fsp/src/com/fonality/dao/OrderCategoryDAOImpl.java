package com.fonality.dao;

import java.util.List;

import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.OrderCategory;

@Repository
public class OrderCategoryDAOImpl extends AbstractDAO<OrderCategory> implements
	OrderCategoryDAO {

    @Override
    public List<OrderCategory> getOrderCategoryListByProductId(long productId) {
	return this.sessionFactory.getCurrentSession()
		.createQuery("from OrderCategory where product_id=" + productId)
		.list();
    }

    @Override
    public OrderCategory loadOrderCategory(int orderCategoryId) {
	OrderCategory retVal = null;
	try {
	    retVal = this.load(orderCategoryId);
	} catch (HibernateException e) {
	    e.printStackTrace();
	}
	return retVal;

    }

    @Override
    public OrderCategory saveOrderCategory(OrderCategory orderCategory) {
	try {
	    orderCategory = this.save(orderCategory);
	} catch (HibernateException e) {
	    e.printStackTrace();
	}

	return orderCategory;

    }

    @Override
    public void deleteOrderCategory(OrderCategory orderCategory) {
	try {
	    this.delete(orderCategory);
	} catch (HibernateException e) {
	    e.printStackTrace();
	}
    }

    @Override
    protected Class getType() {
	return OrderCategory.class;
    }

}
