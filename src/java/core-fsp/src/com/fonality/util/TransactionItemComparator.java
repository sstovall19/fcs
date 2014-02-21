package com.fonality.util;

/*********************************************************************************
 * Copyright (C) 2012 Fonality. All Rights Reserved.
 *
 * Filename:      TransactionItemComparator.java
 * Revision:      1.0
 * Author:        Satya Boddu
 * Created On:    Mar 06, 2012
 * Modified by:   
 * Modified On:   
 *
 * Description:   Comparator class to sort orderTransactionItem objects
 ********************************************************************************/

import java.util.Comparator;

import com.fonality.bu.entity.OrderTransactionItem;

public class TransactionItemComparator implements Comparator<OrderTransactionItem> {

	@Override
	public int compare(OrderTransactionItem first, OrderTransactionItem second) {
		int retVal = 0;

		if (first == null && second == null) {
			return 0;
		}
		if (first == null && second != null) {
			return -1;
		}
		if (first != null && second == null) {
			return 1;
		}
		if (first.getOrderGroup() == null && second.getOrderGroup() != null) {
			return -1;
		}
		if (first.getOrderGroup() != null && second.getOrderGroup() == null) {
			return 1;
		}

		retVal = first.getOrderGroup().getOrderGroupId()
				.compareTo(second.getOrderGroup().getOrderGroupId());
		return ((retVal == 0) ? first.getOrderTransactionItemId().compareTo(
				second.getOrderTransactionItemId()) : retVal);

	}
}