package com.fonality.dao;

import java.util.List;

import org.hibernate.HibernateException;
import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.EntityContact;
import com.fonality.util.ObjectUtils;

@Repository
public class ContactDAOImpl extends AbstractDAO<EntityContact> implements ContactDAO {

	@Override
	public List<EntityContact> getContactList() {
		return this.sessionFactory.getCurrentSession().createQuery("from EntityContact").list();
	}

	@Override
	public EntityContact loadContact(int contactId) {
		return this.load(contactId);
	}

	@Override
	public EntityContact getContactByCustomerIdAndRole(int customerId, String role) {
		EntityContact contact = null;
		List<EntityContact> contactList = this.sessionFactory
				.getCurrentSession()
				.createQuery(
						"from EntityContact " + "where customerId= :customerId and role = :role ")
				.setInteger("customerId", customerId).setString("role", role).list();

		if (ObjectUtils.isValid(contactList)) {
			contact = contactList.get(0);

		}
		return contact;
	}

	@Override
	public EntityContact getContactByEmail(String email) {
		EntityContact contact = null;
		List<EntityContact> contactList = this.sessionFactory.getCurrentSession()
				.createQuery("from EntityContact where email= :email ").setString("email", email)
				.list();

		if (ObjectUtils.isValid(contactList)) {
			contact = contactList.get(0);

		}
		return contact;
	}

	@Override
	public EntityContact saveContact(EntityContact contact) {
		try {
			contact = this.save(contact);
		} catch (HibernateException e) {
			e.printStackTrace();
		}

		return contact;
	}

	@Override
	protected Class getType() {
		return EntityContact.class;
	}

}
