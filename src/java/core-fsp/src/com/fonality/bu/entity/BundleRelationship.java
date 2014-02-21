package com.fonality.bu.entity;

// Generated Mar 21, 2013 12:26:07 PM by Hibernate Tools 3.4.0.CR1

import java.math.BigDecimal;
import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import static javax.persistence.GenerationType.IDENTITY;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * BundleRelationship generated by hbm2java
 */
@Entity
@Table(name = "bundle_relationship", catalog = "fcs")
public class BundleRelationship implements java.io.Serializable {

	private Integer bundleRelationshipId;
	private Bundle bundleBySetsMinBundleId;
	private Bundle bundleByRequiresBundleId;
	private Product product;
	private Bundle bundleBySetsMaxBundleId;
	private Bundle bundleByProvidesBundleId;
	private Bundle bundleByEnablesBundleId;
	private Bundle bundleByDisablesBundleId;
	private Bundle bundleByBundleId;
	private BigDecimal providesBundleIdMultiplier;
	private String disablesBundleIdMessage;
	private BigDecimal setsMaxBundleIdMultiplier;
	private BigDecimal setsMinBundleIdMultiplier;
	private BigDecimal requiresBundleIdMultiplier;
	private Date created;
	private Date updated;

	public BundleRelationship() {
	}

	public BundleRelationship(Bundle bundleByBundleId,
			BigDecimal providesBundleIdMultiplier,
			String disablesBundleIdMessage,
			BigDecimal setsMaxBundleIdMultiplier,
			BigDecimal setsMinBundleIdMultiplier,
			BigDecimal requiresBundleIdMultiplier, Date created, Date updated) {
		this.bundleByBundleId = bundleByBundleId;
		this.providesBundleIdMultiplier = providesBundleIdMultiplier;
		this.disablesBundleIdMessage = disablesBundleIdMessage;
		this.setsMaxBundleIdMultiplier = setsMaxBundleIdMultiplier;
		this.setsMinBundleIdMultiplier = setsMinBundleIdMultiplier;
		this.requiresBundleIdMultiplier = requiresBundleIdMultiplier;
		this.created = created;
		this.updated = updated;
	}

	public BundleRelationship(Bundle bundleBySetsMinBundleId,
			Bundle bundleByRequiresBundleId, Product product,
			Bundle bundleBySetsMaxBundleId, Bundle bundleByProvidesBundleId,
			Bundle bundleByEnablesBundleId, Bundle bundleByDisablesBundleId,
			Bundle bundleByBundleId, BigDecimal providesBundleIdMultiplier,
			String disablesBundleIdMessage,
			BigDecimal setsMaxBundleIdMultiplier,
			BigDecimal setsMinBundleIdMultiplier,
			BigDecimal requiresBundleIdMultiplier, Date created, Date updated) {
		this.bundleBySetsMinBundleId = bundleBySetsMinBundleId;
		this.bundleByRequiresBundleId = bundleByRequiresBundleId;
		this.product = product;
		this.bundleBySetsMaxBundleId = bundleBySetsMaxBundleId;
		this.bundleByProvidesBundleId = bundleByProvidesBundleId;
		this.bundleByEnablesBundleId = bundleByEnablesBundleId;
		this.bundleByDisablesBundleId = bundleByDisablesBundleId;
		this.bundleByBundleId = bundleByBundleId;
		this.providesBundleIdMultiplier = providesBundleIdMultiplier;
		this.disablesBundleIdMessage = disablesBundleIdMessage;
		this.setsMaxBundleIdMultiplier = setsMaxBundleIdMultiplier;
		this.setsMinBundleIdMultiplier = setsMinBundleIdMultiplier;
		this.requiresBundleIdMultiplier = requiresBundleIdMultiplier;
		this.created = created;
		this.updated = updated;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "bundle_relationship_id", unique = true, nullable = false)
	public Integer getBundleRelationshipId() {
		return this.bundleRelationshipId;
	}

	public void setBundleRelationshipId(Integer bundleRelationshipId) {
		this.bundleRelationshipId = bundleRelationshipId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "sets_min_bundle_id")
	public Bundle getBundleBySetsMinBundleId() {
		return this.bundleBySetsMinBundleId;
	}

	public void setBundleBySetsMinBundleId(Bundle bundleBySetsMinBundleId) {
		this.bundleBySetsMinBundleId = bundleBySetsMinBundleId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "requires_bundle_id")
	public Bundle getBundleByRequiresBundleId() {
		return this.bundleByRequiresBundleId;
	}

	public void setBundleByRequiresBundleId(Bundle bundleByRequiresBundleId) {
		this.bundleByRequiresBundleId = bundleByRequiresBundleId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "product_id")
	public Product getProduct() {
		return this.product;
	}

	public void setProduct(Product product) {
		this.product = product;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "sets_max_bundle_id")
	public Bundle getBundleBySetsMaxBundleId() {
		return this.bundleBySetsMaxBundleId;
	}

	public void setBundleBySetsMaxBundleId(Bundle bundleBySetsMaxBundleId) {
		this.bundleBySetsMaxBundleId = bundleBySetsMaxBundleId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "provides_bundle_id")
	public Bundle getBundleByProvidesBundleId() {
		return this.bundleByProvidesBundleId;
	}

	public void setBundleByProvidesBundleId(Bundle bundleByProvidesBundleId) {
		this.bundleByProvidesBundleId = bundleByProvidesBundleId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "enables_bundle_id")
	public Bundle getBundleByEnablesBundleId() {
		return this.bundleByEnablesBundleId;
	}

	public void setBundleByEnablesBundleId(Bundle bundleByEnablesBundleId) {
		this.bundleByEnablesBundleId = bundleByEnablesBundleId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "disables_bundle_id")
	public Bundle getBundleByDisablesBundleId() {
		return this.bundleByDisablesBundleId;
	}

	public void setBundleByDisablesBundleId(Bundle bundleByDisablesBundleId) {
		this.bundleByDisablesBundleId = bundleByDisablesBundleId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "bundle_id", nullable = false)
	public Bundle getBundleByBundleId() {
		return this.bundleByBundleId;
	}

	public void setBundleByBundleId(Bundle bundleByBundleId) {
		this.bundleByBundleId = bundleByBundleId;
	}

	@Column(name = "provides_bundle_id_multiplier", nullable = false, precision = 3)
	public BigDecimal getProvidesBundleIdMultiplier() {
		return this.providesBundleIdMultiplier;
	}

	public void setProvidesBundleIdMultiplier(
			BigDecimal providesBundleIdMultiplier) {
		this.providesBundleIdMultiplier = providesBundleIdMultiplier;
	}

	@Column(name = "disables_bundle_id_message", nullable = false)
	public String getDisablesBundleIdMessage() {
		return this.disablesBundleIdMessage;
	}

	public void setDisablesBundleIdMessage(String disablesBundleIdMessage) {
		this.disablesBundleIdMessage = disablesBundleIdMessage;
	}

	@Column(name = "sets_max_bundle_id_multiplier", nullable = false, precision = 3)
	public BigDecimal getSetsMaxBundleIdMultiplier() {
		return this.setsMaxBundleIdMultiplier;
	}

	public void setSetsMaxBundleIdMultiplier(
			BigDecimal setsMaxBundleIdMultiplier) {
		this.setsMaxBundleIdMultiplier = setsMaxBundleIdMultiplier;
	}

	@Column(name = "sets_min_bundle_id_multiplier", nullable = false, precision = 3)
	public BigDecimal getSetsMinBundleIdMultiplier() {
		return this.setsMinBundleIdMultiplier;
	}

	public void setSetsMinBundleIdMultiplier(
			BigDecimal setsMinBundleIdMultiplier) {
		this.setsMinBundleIdMultiplier = setsMinBundleIdMultiplier;
	}

	@Column(name = "requires_bundle_id_multiplier", nullable = false, precision = 3)
	public BigDecimal getRequiresBundleIdMultiplier() {
		return this.requiresBundleIdMultiplier;
	}

	public void setRequiresBundleIdMultiplier(
			BigDecimal requiresBundleIdMultiplier) {
		this.requiresBundleIdMultiplier = requiresBundleIdMultiplier;
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

}