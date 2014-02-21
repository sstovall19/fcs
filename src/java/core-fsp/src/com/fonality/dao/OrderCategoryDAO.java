package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.OrderCategory;

public interface OrderCategoryDAO {

    /**
     * Method to get order category list by product id
     * 
     * @return the orderCategoryList
     */
    public List<OrderCategory> getOrderCategoryListByProductId(long productId);

    /**
     * Method to get order category by order category id
     * 
     * @return the order
     */
    public OrderCategory loadOrderCategory(int orderCategoryId);

    /**
     * Method to save order category
     * 
     * @param orderCategory
     *            The order category to create
     * @return the order category
     */
    public OrderCategory saveOrderCategory(OrderCategory orderCategory);

    /**
     * Method to delete order category
     * 
     * @param orderCategory
     *            The order category to delete
     */
    public void deleteOrderCategory(OrderCategory orderCategory);

}
