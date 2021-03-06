package com.fonality.bu.entity;

// Generated Mar 21, 2013 12:26:07 PM by Hibernate Tools 3.4.0.CR1

import java.util.Date;
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
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.UniqueConstraint;

/**
 * Deployment generated by hbm2java
 */
@Entity
@Table(name = "deployment", catalog = "fcs", uniqueConstraints = @UniqueConstraint(columnNames = "name"))
public class Deployment implements java.io.Serializable {

	private Integer deploymentId;
	private String name;
	private String description;
	private boolean isHosted;
	private Date created;
	private Date updated;
	private Set<Product> products = new HashSet<Product>(0);
	private Set<PromoDeployment> promoDeployments = new HashSet<PromoDeployment>(
			0);

	public Deployment() {
	}

	public Deployment(String name, String description, boolean isHosted,
			Date created, Date updated) {
		this.name = name;
		this.description = description;
		this.isHosted = isHosted;
		this.created = created;
		this.updated = updated;
	}

	public Deployment(String name, String description, boolean isHosted,
			Date created, Date updated, Set<Product> products,
			Set<PromoDeployment> promoDeployments) {
		this.name = name;
		this.description = description;
		this.isHosted = isHosted;
		this.created = created;
		this.updated = updated;
		this.products = products;
		this.promoDeployments = promoDeployments;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "deployment_id", unique = true, nullable = false)
	public Integer getDeploymentId() {
		return this.deploymentId;
	}

	public void setDeploymentId(Integer deploymentId) {
		this.deploymentId = deploymentId;
	}

	@Column(name = "name", unique = true, nullable = false, length = 80)
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

	@Column(name = "is_hosted", nullable = false)
	public boolean isIsHosted() {
		return this.isHosted;
	}

	public void setIsHosted(boolean isHosted) {
		this.isHosted = isHosted;
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

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "deployment")
	public Set<Product> getProducts() {
		return this.products;
	}

	public void setProducts(Set<Product> products) {
		this.products = products;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "deployment")
	public Set<PromoDeployment> getPromoDeployments() {
		return this.promoDeployments;
	}

	public void setPromoDeployments(Set<PromoDeployment> promoDeployments) {
		this.promoDeployments = promoDeployments;
	}

}
