package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.EntityCreditCard;

public interface EntityCreditCardDAO {

	/**
	 * Method to save entityCreditCard
	 * 
	 * @param entityCreditCard
	 *            The entityCreditCard to save
	 */
	public EntityCreditCard saveEntityCreditCard(
			EntityCreditCard entityCreditCard);

	/**
	 * Method to delete entityCreditCard
	 * 
	 * @param entityCreditCard
	 *            The entityCreditCard to delete
	 */
	public void deleteEntityCreditCard(EntityCreditCard entityCreditCard);

	/**
	 * Method to get entityCreditCard by entityCreditCard id
	 * 
	 * @return the entityCreditCard
	 */
	public EntityCreditCard loadEntityCreditCard(int entityCreditCardId);

	/**
	 * Method to check record with customer and creditCard id
	 * 
	 * @return the boolean
	 */
	public boolean checkCreditCardExists(int netsuiteCardId, int customerId);

	/**
	 * Method to get entityCreditCard by NS credit card id and customer
	 * 
	 * @return the entityCreditCardList
	 */
	public List<EntityCreditCard> getCreditCardByNSIdAndCustomer(
			int netsuiteCardId, int customerId);

}
