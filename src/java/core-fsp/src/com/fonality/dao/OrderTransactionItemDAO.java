package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.OrderTransactionItem;

public interface OrderTransactionItemDAO {

	/**
	 * Method to get order transaction item list by order transaction id
	 * 
	 * @return the orderTransactionItemList
	 */
	public List<OrderTransactionItem> getItemListByTrasanctionId(
			int orderTransactionId);

	/**
	 * Method to get order transaction by order transaction item id
	 * 
	 * @return the orderTransactionItem
	 */
	public OrderTransactionItem loadOrderTransactionItem(
			int orderTransactionItemId);

	/**
	 * Method to save order transaction item
	 * 
	 * @param orderTransactionItem
	 *            The order transaction item to save
	 */
	public OrderTransactionItem saveOrderTransactionItem(
			OrderTransactionItem orderTransactionItem);

	/**
	 * Method to delete order transaction item
	 * 
	 * @param orderTransactionItem
	 *            The order transaction item to delete
	 */
	public void deleteOrderTransactionItem(
			OrderTransactionItem orderTransactionItem);

}
