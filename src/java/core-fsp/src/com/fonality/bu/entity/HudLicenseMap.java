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
import javax.persistence.UniqueConstraint;

/**
 * HudLicenseMap generated by hbm2java
 */
@Entity
@Table(name = "hud_license_map", catalog = "fcs", uniqueConstraints = @UniqueConstraint(columnNames = "license_type_id"))
public class HudLicenseMap implements java.io.Serializable {

	private Integer hudLicenseMapId;
	private LicenseType licenseType;
	private String hudFc;
	private Date created;

	public HudLicenseMap() {
	}

	public HudLicenseMap(LicenseType licenseType, String hudFc, Date created) {
		this.licenseType = licenseType;
		this.hudFc = hudFc;
		this.created = created;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "hud_license_map_id", unique = true, nullable = false)
	public Integer getHudLicenseMapId() {
		return this.hudLicenseMapId;
	}

	public void setHudLicenseMapId(Integer hudLicenseMapId) {
		this.hudLicenseMapId = hudLicenseMapId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "license_type_id", unique = true, nullable = false)
	public LicenseType getLicenseType() {
		return this.licenseType;
	}

	public void setLicenseType(LicenseType licenseType) {
		this.licenseType = licenseType;
	}

	@Column(name = "hud_fc", nullable = false)
	public String getHudFc() {
		return this.hudFc;
	}

	public void setHudFc(String hudFc) {
		this.hudFc = hudFc;
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
