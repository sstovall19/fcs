package com.fonality.dao;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.fonality.bu.entity.Product;

@Repository
public class ProductDAOImpl extends AbstractDAO<Product> implements ProductDAO {

	@Override
	public List<Product> getProductListByDeploymentId(long deploymentId) {
		return this.sessionFactory
				.getCurrentSession()
				.createQuery(
						"from Product where deployment.deploymentId = "
								+ deploymentId).list();
	}

	@Override
	public Product loadProduct(int productId) {
		return this.load(productId);
	}

	@Override
	protected Class getType() {
		return Product.class;
	}

}
