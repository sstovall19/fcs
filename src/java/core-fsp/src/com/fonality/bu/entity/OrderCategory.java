package com.fonality.bu.entity;

// Generated Mar 21, 2013 12:26:07 PM by Hibernate Tools 3.4.0.CR1

import java.util.HashSet;
import java.util.Set;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import static javax.persistence.GenerationType.IDENTITY;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;

/**
 * OrderCategory generated by hbm2java
 */
@Entity
@Table(name = "order_category", catalog = "fcs")
public class OrderCategory implements java.io.Serializable {

	private Integer categoryId;
	private Product product;
	private String name;
	private String description;
	private byte priority;
	private String displayType;
	private Set<OrderCategoryLabelXref> orderCategoryLabelXrefs = new HashSet<OrderCategoryLabelXref>(
			0);

	public OrderCategory() {
	}

	public OrderCategory(Product product, String name, String description,
			byte priority, String displayType) {
		this.product = product;
		this.name = name;
		this.description = description;
		this.priority = priority;
		this.displayType = displayType;
	}

	public OrderCategory(Product product, String name, String description,
			byte priority, String displayType,
			Set<OrderCategoryLabelXref> orderCategoryLabelXrefs) {
		this.product = product;
		this.name = name;
		this.description = description;
		this.priority = priority;
		this.displayType = displayType;
		this.orderCategoryLabelXrefs = orderCategoryLabelXrefs;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "category_id", unique = true, nullable = false)
	public Integer getCategoryId() {
		return this.categoryId;
	}

	public void setCategoryId(Integer categoryId) {
		this.categoryId = categoryId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "product_id", nullable = false)
	public Product getProduct() {
		return this.product;
	}

	public void setProduct(Product product) {
		this.product = product;
	}

	@Column(name = "name", nullable = false)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "description", nullable = false, length = 16777215)
	public String getDescription() {
		return this.description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	@Column(name = "priority", nullable = false)
	public byte getPriority() {
		return this.priority;
	}

	public void setPriority(byte priority) {
		this.priority = priority;
	}

	@Column(name = "display_type", nullable = false, length = 128)
	public String getDisplayType() {
		return this.displayType;
	}

	public void setDisplayType(String displayType) {
		this.displayType = displayType;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "orderCategory")
	public Set<OrderCategoryLabelXref> getOrderCategoryLabelXrefs() {
		return this.orderCategoryLabelXrefs;
	}

	public void setOrderCategoryLabelXrefs(
			Set<OrderCategoryLabelXref> orderCategoryLabelXrefs) {
		this.orderCategoryLabelXrefs = orderCategoryLabelXrefs;
	}

}