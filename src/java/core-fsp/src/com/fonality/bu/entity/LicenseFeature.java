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
 * LicenseFeature generated by hbm2java
 */
@Entity
@Table(name = "license_feature", catalog = "fcs", uniqueConstraints = @UniqueConstraint(columnNames = {
		"license_type_id", "feature_id" }))
public class LicenseFeature implements java.io.Serializable {

	private Integer licenseFeatureId;
	private LicenseType licenseType;
	private Feature feature;
	private Date created;

	public LicenseFeature() {
	}

	public LicenseFeature(LicenseType licenseType, Feature feature, Date created) {
		this.licenseType = licenseType;
		this.feature = feature;
		this.created = created;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "license_feature_id", unique = true, nullable = false)
	public Integer getLicenseFeatureId() {
		return this.licenseFeatureId;
	}

	public void setLicenseFeatureId(Integer licenseFeatureId) {
		this.licenseFeatureId = licenseFeatureId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "license_type_id", nullable = false)
	public LicenseType getLicenseType() {
		return this.licenseType;
	}

	public void setLicenseType(LicenseType licenseType) {
		this.licenseType = licenseType;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "feature_id", nullable = false)
	public Feature getFeature() {
		return this.feature;
	}

	public void setFeature(Feature feature) {
		this.feature = feature;
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
