package com.fonality.dao;

import com.fonality.bu.entity.BundlePacking;

public interface BundlePackDAO {

    /**
     * Method to get bundle pack by bundle id
     * 
     * @return the bundlePack
     */
	 public BundlePacking getBundlePackByBundleId(long bundleId);

    /**
     * Method to get bundle pack by bundle pack id
     * 
     * @return the bundlePack
     */
    public BundlePacking loadBundlePack(long bundlePackId);
    /**
     * Method to save bundle pack
     * 
     * @param bundlePack
     *            The bundle pack to create
     * @return bundlePack The bundle pack to delete
     */
    public BundlePacking saveBundlePack(BundlePacking bundlePack);
    /**
     * Method to delete bundle pack
     * 
     * @param bundlePack
     *            The bundle pack to delete
     */
    public void deleteBundlePack(BundlePacking bundlePack);

}
