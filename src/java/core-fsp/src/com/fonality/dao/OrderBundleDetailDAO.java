package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.OrderBundleDetail;

public interface OrderBundleDetailDAO {

    /**
     * Method to get order bundle detail list by order bundle id
     * 
     * @return the orderBundleList
     */
    public List<OrderBundleDetail> getOrderBundleDetailListByOrderBundleId(
	    Integer orderBundleId);

    /**
     * Method to get order bundle detail by order bundle id
     * 
     * @return the order
     */
    public OrderBundleDetail loadOrderBundleDetail(long orderBundleDetailId);

    /**
     * Method to save order bundle detail
     * 
     * @param orderBundle
     *            The order bundle to create
     * @return the order bundle
     */
    public OrderBundleDetail saveOrderBundleDetail(OrderBundleDetail orderBundle);

    /**
     * Method to delete order bundle detail
     * 
     * @param orderBundle
     *            The order bundle to delete
     */
    public void deleteOrderBundleDetail(OrderBundleDetail orderBundle);

}
