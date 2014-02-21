package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.Orders;

public interface OrderDAO {

	/**
	 * Method to get order list by customer id
	 * 
	 * @return the orderList
	 */
	public List<Orders> getOrderListByCustomerId(Integer custId);

	/**
	 * Method to get order by order id
	 * 
	 * @return the order
	 */
	public Orders loadOrder(int orderId);

	/**
	 * Method to save order
	 * 
	 * @param the
	 *            order
	 */
	public Orders saveOrder(Orders order);

	/**
	 * Method to delete order
	 * 
	 * @param the
	 *            order
	 */
	public void deleteOrder(Orders order);

}
