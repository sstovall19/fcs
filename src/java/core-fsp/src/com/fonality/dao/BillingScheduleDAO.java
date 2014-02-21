package com.fonality.dao;

import java.util.Date;
import java.sql.Timestamp;
import java.util.List;

import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.OrderBundle;
import com.fonality.bu.entity.Product;

public interface BillingScheduleDAO {
	
	/**
	 * Getting  BuillingSchduled Customers list by Date
	 * 
	 * @return the BuillingSchduled Customers List
	 */
	public List<BillingSchedule> getCustomerListId();

	/**
	 * Loading BillingSchedule by BillingScheduleId
	 * In case if we will need re-run one Customer server usage
	 * 
	 * @return BuillingSchedule
	 */
	public BillingSchedule loadBuillingSchedule(Integer billingScheduleId);
	
	/**
	 * Method to save order BillingSchedule detail
	 * 
	 * @param BillingSchedule
	 *            The Billing Schedule to create
	 * @return the BillingSchedule
	 */
	public BillingSchedule saveBillingSchedule (BillingSchedule billingSchedule);

}
