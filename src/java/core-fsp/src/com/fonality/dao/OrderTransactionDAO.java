package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.OrderTransaction;
import com.fonality.bu.entity.OrderTransactionItem;

public interface OrderTransactionDAO {

	/**
	 * Method to get order transaction list by order id
	 * 
	 * @return the orderTransactionList
	 */
	public List<OrderTransaction> getOrderTransactionListByOrderGroupId(
			long orderGroupId);

	/**
	 * Method to get order transaction by order transaction id
	 * 
	 * @return the orderTransaction
	 */
	public OrderTransaction loadOrderTransaction(int orderTransactionId);

	/**
	 * Method to save order transaction
	 * 
	 * @param orderTransaction
	 *            The order transaction to save
	 */
	public OrderTransaction saveOrderTransaction(
			OrderTransaction orderTransaction);

	/**
	 * Method to delete order transaction
	 * 
	 * @param orderTransaction
	 *            The order transaction to delete
	 */
	public void deleteOrderTransaction(OrderTransaction orderTransaction);

	/**
	 * Method to get order transaction items list by order transaction id
	 * 
	 * @return the orderTransactionItemList
	 */
	public List<OrderTransactionItem> getItemsByOrderTransactionId(
			long orderTransactionId);

}
