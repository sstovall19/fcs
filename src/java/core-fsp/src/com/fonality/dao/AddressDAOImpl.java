package com.fonality.dao;

import java.util.List;

import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.EntityAddress;

@Repository
public class AddressDAOImpl extends AbstractDAO<EntityAddress> implements
		AddressDAO {

	@Override
	public EntityAddress loadAddress(int addressId) {
		EntityAddress retVal = null;
		try {
			retVal = this.load(addressId);
		} catch (HibernateException e) {
			e.printStackTrace();
		}
		return retVal;

	}

	@Override
	public EntityAddress saveEntityAddress(EntityAddress entityAddress) {
		try {
			entityAddress = this.save(entityAddress);
		} catch (HibernateException e) {
			e.printStackTrace();
		}

		return entityAddress;
	}

	@Override
	public List<EntityAddress> getAddressList() {
		return this.sessionFactory.getCurrentSession()
				.createQuery("from EntityAddress").list();
	}

	@Override
	public List<EntityAddress> getAddressList(String type) {
		return this.sessionFactory.getCurrentSession()
				.createQuery("from EntityAddress where type = :type")
				.setParameter("type", type).list();
	}

	@Override
	protected Class getType() {
		return EntityAddress.class;
	}

}
