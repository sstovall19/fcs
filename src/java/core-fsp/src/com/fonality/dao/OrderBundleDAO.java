package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.OrderBundle;

public interface OrderBundleDAO {

	/**
	 * Method to get order bundle list by order group id
	 * 
	 * @return the orderBundleList
	 */
	public List<OrderBundle> getOrderBundleListByOrderGroupId(
			Integer orderGroupId);

	/**
	 * Method to get order bundle list by bundle id
	 * 
	 * @return the orderBundleList
	 */
	public List<OrderBundle> getOrderBundleListByBundleId(Integer bundleId);

	/**
	 * Method to get order bundle by order bundle id
	 * 
	 * @return the orderBundle
	 */
	public OrderBundle loadOrderBundle(int orderBundleDetailId);

	/**
	 * Method to save order bundle detail
	 * 
	 * @param orderBundle
	 *            The order bundle to create
	 * @return the order bundle
	 */
	public OrderBundle saveOrderBundle(OrderBundle orderBundle);

	/**
	 * Method to delete order bundle detail
	 * 
	 * @param orderBundle
	 *            The order bundle to delete
	 */
	public void deleteOrderBundle(OrderBundle orderBundle);

}
