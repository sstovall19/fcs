package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.Bundle;

public interface BundleDAO {

	/**
	 * Method to save bundle
	 * 
	 * @param bundle
	 *            The bundle to save
	 */
	public Bundle saveBundle(Bundle bundle);

	/**
	 * Method to delete bundle
	 * 
	 * @param bundle
	 *            The bundle to delete
	 */
	public void deleteBundle(Bundle bundle);

	/**
	 * Method to get bundle by bundle id
	 * 
	 * @return the bundle
	 */
	public Bundle loadBundle(int bundleId);

	public Bundle getBundleByName(String bundleName);

	public List<Bundle> getBundleByPartialName(String bundleName);

	/**
	 * Method to get bundle category id by category name
	 * 
	 * @return the bundleCategoryId
	 */
	public Integer getBundleCategoryIdByName(String bundleCategoryName);
}
