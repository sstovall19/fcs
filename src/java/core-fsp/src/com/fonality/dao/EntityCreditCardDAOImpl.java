package com.fonality.dao;

import java.util.List;

import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.EntityCreditCard;

@Repository
public class EntityCreditCardDAOImpl extends AbstractDAO<EntityCreditCard>
		implements EntityCreditCardDAO {

	@Override
	public EntityCreditCard loadEntityCreditCard(int entityCreditCardId) {
		EntityCreditCard retVal = null;
		try {
			retVal = this.load(entityCreditCardId);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
		return retVal;

	}

	@Override
	public EntityCreditCard saveEntityCreditCard(
			EntityCreditCard entityCreditCard) {
		try {
			entityCreditCard = this.save(entityCreditCard);
		} catch (HibernateException e) {
			e.printStackTrace();
		}

		return entityCreditCard;
	}

	@Override
	public void deleteEntityCreditCard(EntityCreditCard entityCreditCard) {
		try {
			this.delete(entityCreditCard);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
	}

	@Override
	public boolean checkCreditCardExists(int netsuiteCardId, int customerId) {
		boolean exists = false;
		try {

			Long count = (Long) this.sessionFactory
					.getCurrentSession()
					.createQuery(
							"SELECT count(*) FROM  EntityCreditCard where netsuiteCardId  = :netsuiteCardId and customerId = :customerId ")
					.setParameter("netsuiteCardId", netsuiteCardId)
					.setParameter("customerId", customerId).uniqueResult();
			exists = count > 0;
		} catch (HibernateException e) {
			e.printStackTrace();
		}

		return exists;
	}

	@Override
	public List<EntityCreditCard> getCreditCardByNSIdAndCustomer(
			int netsuiteCardId, int customerId) {
		return this.sessionFactory
				.getCurrentSession()
				.createQuery(
						"from EntityCreditCard where netsuiteCardId  = :netsuiteCardId and customerId = :customerId ")
				.setParameter("netsuiteCardId", netsuiteCardId)
				.setParameter("customerId", customerId).list();
	}

	@Override
	protected Class getType() {
		return EntityCreditCard.class;
	}

}
