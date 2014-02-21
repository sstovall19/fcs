package com.fonality.billing.service.impl;

import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.billing.DTO.ServerBillingCycleDTO;
import com.fonality.billing.service.BillingScheduleCreateService;
import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.Orders;
import com.fonality.bu.entity.PaymentMethod;
import com.fonality.dao.BillingScheduleCreateDAO;
import com.fonality.dao.BillingScheduleDAO;
import com.fonality.dao.OrderBundleDAO;
import com.fonality.dao.OrderDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.dao.PaymentMethodDAO;

@Service
@Transactional
public class BillingScheduleCreateServiceImpl implements BillingScheduleCreateService {

	@Autowired
	public BillingScheduleCreateDAO billingScheduleCreateDAO;
	@Autowired
	public BillingScheduleDAO billingScheduleDAO;
	@Autowired
	public OrderDAO orderDAO;
	@Autowired
	public OrderGroupDAO orderGroupDAO;
	@Autowired
	public OrderBundleDAO orderBundleDAO;
	@Autowired
	public PaymentMethodDAO paymentMethodDAO;

	private static final Logger LOGGER = Logger.getLogger(BillingScheduleCreateServiceImpl.class
			.getName());

	private List<Integer> serversList = null;
	private List<Integer> faxServersList = null;
	private List<Integer> mergedServersList = null;
	private OrderGroup orderGroup = null;
	private Orders order = null;
	private PaymentMethod paymentMethod = null;

	/*
	 * unbound_cdr_test->server_id -> 1. unbound_cdr_test.server_id -> order_group.order_id ->
	 * (orders.customerId) 2. unbound_cdr_test.server_id -> (order_group.order_group_id) 3.
	 * unbound_cdr_test.server_id -> (orders.payment_method_id, orders.credit_card_id) 4.
	 * (order_group.order_group_id == order_bundle.order-group_id) -> order_bundle.is_rented if
	 * (is_rented) than billing_schedule.type = 'ALL' else billing_schedule.type = 'SERVICE'
	 */

	private BillingSchedule bs = null;

	/**
	 * Creates Billing Schedule records in DB It process all CDR for given Billing cycle and uses
	 * Servers Id from selected CDRs to build a record.
	 * 
	 * @param BillingSchedule
	 *            bs
	 * @param startDate
	 * @param endDate
	 * @return boolean
	 */
	//public boolean createScheduleForAllServers(Date startDate, Date endDate) {
	public boolean createScheduleForAllServers(List<ServerBillingCycleDTO> serverBCList) {

		boolean rt = false;
		//Integer currentServer = null;
		ServerBillingCycleDTO currentServer = null;
		List<ServerBillingCycleDTO> usedServerList123 = null;

		try {
			/***
			 * // Getting Server list from unbound_cdr table (Voice servers) serversList =
			 * billingScheduleCreateDAO.getServersList (startDate, endDate); if (serversList !=
			 * null) { System.out.println ("*** 1 ServerId: "+serversList.toString()); }else {
			 * System.out.println ("*** 1  ServerId list is NULL"); } // Getting Concord "Server"
			 * list (FAX) faxServersList = billingScheduleCreateDAO.getFaxServersList(startDate,
			 * endDate); if (faxServersList != null) { System.out.println
			 * ("*** 2 Fax ServerId: "+faxServersList.toString()); }else { System.out.println
			 * ("*** 2 Fax ServerId list is NULL"); } if (serversList != null && faxServersList !=
			 * null) { mergedServersList = (List<Integer>) CollectionUtils.union(serversList,
			 * faxServersList); Collections.sort(mergedServersList); if (mergedServersList != null)
			 * { System.out.println ("*** 3 Merged ServerId: "+mergedServersList.toString()); }
			 ***/
			//		
			// Forming BillingSchedule Object and inserting it.
			//for (Integer server: mergedServersList) {
			for (ServerBillingCycleDTO server : serverBCList) {
				currentServer = server;
				LOGGER.info("Start Processing Server: " + server.getServerId());
				bs = new BillingSchedule();
				try {
					orderGroup = orderGroupDAO.loadOrderGroupByserver(server.getServerId());
					if (orderGroup == null) {
						rt = false;
						System.out.println("*** ServerId: " + server.getServerId()
								+ " NO ORDER GROUP EXIST.");
						continue;
					}
					order = orderDAO.loadOrder(orderGroup.getOrders().getOrderId());
					Long rentedBundles = billingScheduleCreateDAO.isOrderGroupHasRented(orderGroup
							.getOrderGroupId());

					if (rentedBundles != null && rentedBundles > 0) {
						bs.setType("ALL");
					} else {
						bs.setType("SERVICE");
					}

					if (order.getPaymentMethod() == null) {
						paymentMethod = paymentMethodDAO.loadPaymentMethod(4); // Check
					} else {
						paymentMethod = order.getPaymentMethod();
					}

					bs.setStartDate(server.getStartDate());
					bs.setEndDate(server.getEndDate());
					bs.setStatus("PROCESSED_ALL"); //set to NOT_PROCESSED as needed.

					// Code needs to be updated to get first orderGroup associated with order
					//bs.setOrderGroup(orderGroup);
					bs.setCustomerId(order.getCustomerId());
					bs.setPaymentMethod(paymentMethod);
					bs.setEntityCreditCard(order.getEntityCreditCard());

					billingScheduleDAO.saveBillingSchedule(bs);

					LOGGER.info("End Processing Server: " + server.getServerId());
				} catch (Exception e) {
					LOGGER.error(
							"Server - :  " + currentServer.getServerId() + " - " + e.getMessage(),
							e);
					continue;
				}
			}
			//
			//}
		} catch (Exception e) {
			LOGGER.error("Server - :" + currentServer.getServerId() + e.getMessage(), e);
		}

		return true;
	}

}
