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
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

/**
 * PriceModel generated by hbm2java
 */
@Entity
@Table(name = "price_model", catalog = "fcs", uniqueConstraints = @UniqueConstraint(columnNames = "name"))
public class PriceModel implements java.io.Serializable {

	private Integer priceModelId;
	private String name;
	private Set<BundlePriceModel> bundlePriceModels = new HashSet<BundlePriceModel>(
			0);

	public PriceModel() {
	}

	public PriceModel(String name) {
		this.name = name;
	}

	public PriceModel(String name, Set<BundlePriceModel> bundlePriceModels) {
		this.name = name;
		this.bundlePriceModels = bundlePriceModels;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "price_model_id", unique = true, nullable = false)
	public Integer getPriceModelId() {
		return this.priceModelId;
	}

	public void setPriceModelId(Integer priceModelId) {
		this.priceModelId = priceModelId;
	}

	@Column(name = "name", unique = true, nullable = false, length = 50)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "priceModel")
	public Set<BundlePriceModel> getBundlePriceModels() {
		return this.bundlePriceModels;
	}

	public void setBundlePriceModels(Set<BundlePriceModel> bundlePriceModels) {
		this.bundlePriceModels = bundlePriceModels;
	}

}
