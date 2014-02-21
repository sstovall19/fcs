package com.fonality.bu.entity;

// Generated Feb 8, 2013 10:59:00 AM by Hibernate Tools 3.4.0.CR1

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import static javax.persistence.GenerationType.IDENTITY;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.UniqueConstraint;

/**
 * DeviceType generated by hbm2java
 */
@Entity
@Table(name = "device_type", catalog = "fcs", uniqueConstraints = @UniqueConstraint(columnNames = {
		"name", "description" }))
public class DeviceType implements java.io.Serializable {

	private Integer deviceTypeId;
	private String name;
	private String description;
	private Date created;

	public DeviceType() {
	}

	public DeviceType(String name, String description, Date created) {
		this.name = name;
		this.description = description;
		this.created = created;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "device_type_id", unique = true, nullable = false)
	public Integer getDeviceTypeId() {
		return this.deviceTypeId;
	}

	public void setDeviceTypeId(Integer deviceTypeId) {
		this.deviceTypeId = deviceTypeId;
	}

	@Column(name = "name", nullable = false, length = 40)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "description", nullable = false)
	public String getDescription() {
		return this.description;
	}

	public void setDescription(String description) {
		this.description = description;
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