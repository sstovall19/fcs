package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.EntityContact;

public interface ContactDAO {

	/**
	 * Method to get contact list
	 * 
	 * @return the contactList
	 */
	public List<EntityContact> getContactList();

	/**
	 * Method to load contact by contact id
	 * 
	 * @return the contact
	 */
	public EntityContact loadContact(int contactId);

	/**
	 * Method to save contact
	 * 
	 * @param the
	 *            contact
	 */
	public EntityContact saveContact(EntityContact contact);

	/**
	 * Method to load contact by customer id and role
	 * 
	 * @return the contact
	 */
	public EntityContact getContactByCustomerIdAndRole(int customerId,
			String role);

	/**
	 * Method to load contact by email address
	 * 
	 * @return the contact
	 */
	public EntityContact getContactByEmail(String email);

}
