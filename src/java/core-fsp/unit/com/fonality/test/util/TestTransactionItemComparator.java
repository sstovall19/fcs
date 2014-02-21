package com.fonality.test.util;

import static org.junit.Assert.assertTrue;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.junit.Test;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;

import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.OrderTransactionItem;
import com.fonality.util.TransactionItemComparator;

/**
 * @author Fonality
 */
@ContextConfiguration(locations = "classpath:application-context.xml")
public class TestTransactionItemComparator extends AbstractTransactionalJUnit4SpringContextTests {

	public TransactionItemComparator itemComparator;

	@Rollback(true)
	@Test
	public void testSortItems() {

		List<OrderTransactionItem> items = new ArrayList<OrderTransactionItem>();

		OrderGroup orderGroup1 = new OrderGroup();
		orderGroup1.setOrderGroupId(1111);

		OrderGroup orderGroup2 = new OrderGroup();
		orderGroup2.setOrderGroupId(2222);

		OrderTransactionItem orderTransactionItem1 = new OrderTransactionItem();
		orderTransactionItem1.setOrderGroup(orderGroup2);
		orderTransactionItem1.setOrderTransactionItemId(114);

		OrderTransactionItem orderTransactionItem2 = new OrderTransactionItem();
		orderTransactionItem2.setOrderGroup(orderGroup1);
		orderTransactionItem2.setOrderTransactionItemId(113);

		OrderTransactionItem orderTransactionItem3 = new OrderTransactionItem();
		orderTransactionItem3.setOrderGroup(orderGroup2);
		orderTransactionItem3.setOrderTransactionItemId(122);

		OrderTransactionItem orderTransactionItem4 = new OrderTransactionItem();
		orderTransactionItem4.setOrderGroup(orderGroup1);
		orderTransactionItem4.setOrderTransactionItemId(100);

		OrderTransactionItem orderTransactionItem5 = new OrderTransactionItem();
		orderTransactionItem5.setOrderGroup(orderGroup2);
		orderTransactionItem5.setOrderTransactionItemId(112);

		OrderTransactionItem orderTransactionItem6 = new OrderTransactionItem();
		orderTransactionItem6.setOrderGroup(orderGroup1);
		orderTransactionItem6.setOrderTransactionItemId(118);

		items.add(orderTransactionItem1);
		items.add(orderTransactionItem2);
		items.add(orderTransactionItem3);
		items.add(orderTransactionItem4);
		items.add(orderTransactionItem5);
		items.add(orderTransactionItem6);

		assertTrue(items.get(0).getOrderTransactionItemId() == 114);
		assertTrue(items.get(0).getOrderGroup().getOrderGroupId() == 2222);

		Collections.sort(items, new TransactionItemComparator());

		assertTrue(items.get(0).getOrderTransactionItemId() == 100);
		assertTrue(items.get(0).getOrderGroup().getOrderGroupId() == 1111);
	}
}
