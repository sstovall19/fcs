package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.OrderGroup;

public interface OrderGroupDAO {

	/**
	 * Method to get order group list by order id
	 * 
	 * @return the orderGroupList
	 */
	public List<OrderGroup> getOrderGroupListByOrderId(long orderId);

	/**
	 * Method to get order group detail by order group id
	 * 
	 * @return the orderGroup
	 */
	public OrderGroup loadOrderGroup(int orderGroupId);

	/**
	 * Method to save order group
	 * 
	 * @param orderGroup
	 *            The order group to save
	 */
	public OrderGroup saveOrderGroup(OrderGroup orderGroup);

	/**
	 * Method to delete order group
	 * 
	 * @param orderGroup
	 *            The order group to delete
	 */
	public void deleteOrderGroup(OrderGroup orderGroup);
	
	/**
	 * Method to get order group list by Server id
	 * 
	 * @return the orderGroupList
	 */
	public OrderGroup loadOrderGroupByserver(Integer serverId);

}
