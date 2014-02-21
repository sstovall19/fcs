package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.Product;

public interface ProductDAO {

	/**
	 * Method to get product list by deployment id
	 * 
	 * @return the productList
	 */
	public List<Product> getProductListByDeploymentId(long deploymentId);

	/**
	 * Method to load product by product id
	 * 
	 * @return the product
	 */
	public Product loadProduct(int productId);

}
