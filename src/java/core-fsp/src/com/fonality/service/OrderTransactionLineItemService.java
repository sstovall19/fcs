package com.fonality.service;

import java.io.IOException;
import java.util.List;

import com.fonality.billing.DTO.BillableCdrDTO;
import com.fonality.bu.entity.OrderGroup;

public interface OrderTransactionLineItemService {
	
	/**
	 * Prepares an order transaction for invoice generation. Generates invoice line item records for billable items,
	 * and calculates taxation on billable items and telephony usage. Updates the order transaction with the created line 
	 * items and the sum dollar amount of all items.
	 * 
	 * @param orderTransactionId  Id of the order transaction record
	 * @param orderGroup The specific orderGroup for which to create line items
	 * @param unboundCdrFiltered  A list of call data records
	 * @param transactionType  Indicates which kinds of transactions to include in calculations. Currently supports values 
	 * "system," "service", and "all"
	 * @return True if all calculations were successful, false if any errors occurred
	 * @throws InterruptedException
	 * @throws IOException
	 */
	public boolean calculateTransactionTotal(int orderTransactionId, OrderGroup orderGroup, List <BillableCdrDTO> unboundCdrFiltered, 
			String transactionType) throws InterruptedException, IOException;
	
	/**
	 * Prepares an order transaction for invoice generation. Generates invoice line item records for billable items,
	 * and calculates taxation on billable items and telephony usage. Updates the order transaction with the created line 
	 * items and the sum dollar amount of all items.
	 * 
	 * @param orderTransactionId  Id of the order transaction record
	 * @param orderGroup The specific orderGroup for which to create line items
	 * @param unboundCdrFiltered  A list of call data records
	 * @param transactionType  Indicates which kinds of transactions to include in calculations. Currently supports values 
	 * "system," "service", and "all"
	 * @param isTestMode  Flag indicating whether to make third-part taxation requests in test mode
	 * @return True if all calculations were successful, false if any errors occurred
	 * @throws InterruptedException
	 * @throws IOException
	 */
	public boolean calculateTransactionTotal(int orderTransactionId, OrderGroup orderGroup, List <BillableCdrDTO> unboundCdrFiltered, 
			String transactionType, boolean isTestMode) throws InterruptedException, IOException;

	/**
	 * Prepares an order transaction for invoice generation. Generates invoice line item records for billable items,
	 * and calculates taxation on those same items. Updates the order transaction with the created line 
	 * items and the sum dollar amount of all items.
	 * 
	 * @param orderTransactionId Id of the order transaction record
	 * @param orderGroup The specific orderGroup for which to create line items
	 * @return True if all calculations were successful, false if any errors occurred
	 * @throws InterruptedException
	 * @throws IOException
	 */
	public boolean generateTransactionLineItemsForFirstCashSale(int orderTransactionId, OrderGroup orderGroup)
			throws InterruptedException, IOException;

}
