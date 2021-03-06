package com.fonality.bu.entity;

// Generated Mar 21, 2013 12:26:07 PM by Hibernate Tools 3.4.0.CR1

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import static javax.persistence.GenerationType.IDENTITY;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

/**
 * OrderBundleDetail generated by hbm2java
 */
@Entity
@Table(name = "order_bundle_detail", catalog = "fcs", uniqueConstraints = {
		@UniqueConstraint(columnNames = { "order_bundle_id", "extension_number" }),
		@UniqueConstraint(columnNames = { "order_bundle_id", "mac_address" }) })
public class OrderBundleDetail implements java.io.Serializable {

	private Integer orderBundleDetailId;
	private OrderBundle orderBundle;
	private Integer extensionNumber;
	private String macAddress;
	private String didNumber;
	private String desiredDidNumber;
	private boolean isLnp;

	public OrderBundleDetail() {
	}

	public OrderBundleDetail(OrderBundle orderBundle, String didNumber,
			boolean isLnp) {
		this.orderBundle = orderBundle;
		this.didNumber = didNumber;
		this.isLnp = isLnp;
	}

	public OrderBundleDetail(OrderBundle orderBundle, Integer extensionNumber,
			String macAddress, String didNumber, String desiredDidNumber,
			boolean isLnp) {
		this.orderBundle = orderBundle;
		this.extensionNumber = extensionNumber;
		this.macAddress = macAddress;
		this.didNumber = didNumber;
		this.desiredDidNumber = desiredDidNumber;
		this.isLnp = isLnp;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "order_bundle_detail_id", unique = true, nullable = false)
	public Integer getOrderBundleDetailId() {
		return this.orderBundleDetailId;
	}

	public void setOrderBundleDetailId(Integer orderBundleDetailId) {
		this.orderBundleDetailId = orderBundleDetailId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "order_bundle_id", nullable = false)
	public OrderBundle getOrderBundle() {
		return this.orderBundle;
	}

	public void setOrderBundle(OrderBundle orderBundle) {
		this.orderBundle = orderBundle;
	}

	@Column(name = "extension_number")
	public Integer getExtensionNumber() {
		return this.extensionNumber;
	}

	public void setExtensionNumber(Integer extensionNumber) {
		this.extensionNumber = extensionNumber;
	}

	@Column(name = "mac_address", length = 12)
	public String getMacAddress() {
		return this.macAddress;
	}

	public void setMacAddress(String macAddress) {
		this.macAddress = macAddress;
	}

	@Column(name = "did_number", nullable = false, length = 20)
	public String getDidNumber() {
		return this.didNumber;
	}

	public void setDidNumber(String didNumber) {
		this.didNumber = didNumber;
	}

	@Column(name = "desired_did_number", length = 20)
	public String getDesiredDidNumber() {
		return this.desiredDidNumber;
	}

	public void setDesiredDidNumber(String desiredDidNumber) {
		this.desiredDidNumber = desiredDidNumber;
	}

	@Column(name = "is_lnp", nullable = false)
	public boolean isIsLnp() {
		return this.isLnp;
	}

	public void setIsLnp(boolean isLnp) {
		this.isLnp = isLnp;
	}

}
