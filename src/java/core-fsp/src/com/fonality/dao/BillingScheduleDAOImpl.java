package com.fonality.dao;

import java.util.Date;
import java.util.List;

import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.bu.entity.BillingSchedule;
import com.fonality.bu.entity.OrderBundle;

@Repository
@Transactional
public class BillingScheduleDAOImpl 
		extends AbstractDAO<BillingSchedule> implements BillingScheduleDAO {
	
	@Override
	public List<BillingSchedule> getCustomerListId () {
		
		return this.sessionFactory.getCurrentSession().createQuery(
				"from BillingSchedule where (status = 'not_processed' " +
					"or  status = 'processed_mrc_and_tax') and sysdate() >= end_date").list();
				 
	}
	//enum('not_processed','processed_mrc_and_tax','processed_all')
	
	@Override
	public BillingSchedule loadBuillingSchedule(Integer billingScheduleId) {
		return this.load(billingScheduleId);
		
	}

	@Override
	public BillingSchedule saveBillingSchedule(BillingSchedule billingSchedule) {
		try {
			billingSchedule = this.save(billingSchedule);
		} catch (HibernateException e) {
			e.printStackTrace();
		}

		return billingSchedule;

	}
	
	@Override
	protected Class getType() {
		return BillingSchedule.class;
	}

	
}
