package com.fonality.bu.entity;

// Generated Mar 21, 2013 12:26:07 PM by Hibernate Tools 3.4.0.CR1

import java.math.BigDecimal;
import java.util.Date;
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
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * Discount generated by hbm2java
 */
@Entity
@Table(name = "discount", catalog = "fcs")
public class Discount implements java.io.Serializable {

	private Integer discountId;
	private DiscountCategory discountCategory;
	private String name;
	private int minValue;
	private int maxValue;
	private BigDecimal percent;
	private Date created;
	private Date updated;
	private Set<BundleDiscount> bundleDiscounts = new HashSet<BundleDiscount>(0);

	public Discount() {
	}

	public Discount(DiscountCategory discountCategory, String name,
			int minValue, int maxValue, BigDecimal percent, Date created,
			Date updated) {
		this.discountCategory = discountCategory;
		this.name = name;
		this.minValue = minValue;
		this.maxValue = maxValue;
		this.percent = percent;
		this.created = created;
		this.updated = updated;
	}

	public Discount(DiscountCategory discountCategory, String name,
			int minValue, int maxValue, BigDecimal percent, Date created,
			Date updated, Set<BundleDiscount> bundleDiscounts) {
		this.discountCategory = discountCategory;
		this.name = name;
		this.minValue = minValue;
		this.maxValue = maxValue;
		this.percent = percent;
		this.created = created;
		this.updated = updated;
		this.bundleDiscounts = bundleDiscounts;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "discount_id", unique = true, nullable = false)
	public Integer getDiscountId() {
		return this.discountId;
	}

	public void setDiscountId(Integer discountId) {
		this.discountId = discountId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "category_id", nullable = false)
	public DiscountCategory getDiscountCategory() {
		return this.discountCategory;
	}

	public void setDiscountCategory(DiscountCategory discountCategory) {
		this.discountCategory = discountCategory;
	}

	@Column(name = "name", nullable = false, length = 55)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "min_value", nullable = false)
	public int getMinValue() {
		return this.minValue;
	}

	public void setMinValue(int minValue) {
		this.minValue = minValue;
	}

	@Column(name = "max_value", nullable = false)
	public int getMaxValue() {
		return this.maxValue;
	}

	public void setMaxValue(int maxValue) {
		this.maxValue = maxValue;
	}

	@Column(name = "percent", nullable = false, precision = 5)
	public BigDecimal getPercent() {
		return this.percent;
	}

	public void setPercent(BigDecimal percent) {
		this.percent = percent;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "created", nullable = false, length = 0)
	public Date getCreated() {
		return this.created;
	}

	public void setCreated(Date created) {
		this.created = created;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "updated", nullable = false, length = 0)
	public Date getUpdated() {
		return this.updated;
	}

	public void setUpdated(Date updated) {
		this.updated = updated;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "discount")
	public Set<BundleDiscount> getBundleDiscounts() {
		return this.bundleDiscounts;
	}

	public void setBundleDiscounts(Set<BundleDiscount> bundleDiscounts) {
		this.bundleDiscounts = bundleDiscounts;
	}

}