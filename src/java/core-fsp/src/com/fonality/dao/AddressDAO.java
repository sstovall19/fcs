package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.EntityAddress;

public interface AddressDAO {

	/**
	 * Method to load address by address Id
	 * 
	 * @return the address
	 */
	public EntityAddress loadAddress(int addressId);

	/**
	 * Method to save address
	 * 
	 * @return the address
	 */
	public EntityAddress saveEntityAddress(EntityAddress entityAddress);

	/**
	 * Method to get address list
	 * 
	 * @return the addressList
	 */
	public List<EntityAddress> getAddressList();

	/**
	 * Method to get address list by type
	 * 
	 * @return the addressList
	 */
	public List<EntityAddress> getAddressList(String type);

}
