package com.fonality.bu.entity;

// Generated Mar 21, 2013 12:26:07 PM by Hibernate Tools 3.4.0.CR1

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
 * ServerLicense generated by hbm2java
 */
@Entity
@Table(name = "server_license", catalog = "fcs")
public class ServerLicense implements java.io.Serializable {

	private Integer serverLicenseId;
	private LicenseType licenseType;
	private int serverId;
	private int qty;
	private Date created;

	public ServerLicense() {
	}

	public ServerLicense(LicenseType licenseType, int serverId, int qty,
			Date created) {
		this.licenseType = licenseType;
		this.serverId = serverId;
		this.qty = qty;
		this.created = created;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "server_license_id", unique = true, nullable = false)
	public Integer getServerLicenseId() {
		return this.serverLicenseId;
	}

	public void setServerLicenseId(Integer serverLicenseId) {
		this.serverLicenseId = serverLicenseId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "license_type_id", nullable = false)
	public LicenseType getLicenseType() {
		return this.licenseType;
	}

	public void setLicenseType(LicenseType licenseType) {
		this.licenseType = licenseType;
	}

	@Column(name = "server_id", nullable = false)
	public int getServerId() {
		return this.serverId;
	}

	public void setServerId(int serverId) {
		this.serverId = serverId;
	}

	@Column(name = "qty", nullable = false)
	public int getQty() {
		return this.qty;
	}

	public void setQty(int qty) {
		this.qty = qty;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "created", nullable = false, length = 0)
	public Date getCreated() {
		return this.created;
	}

	public void setCreated(Date created) {
		this.created = created;
	}

}