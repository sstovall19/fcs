package com.fonality.bu.entity;

// Generated Mar 21, 2013 12:26:07 PM by Hibernate Tools 3.4.0.CR1

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import static javax.persistence.GenerationType.IDENTITY;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * NetsuiteSalesperson generated by hbm2java
 */
@Entity
@Table(name = "netsuite_salesperson", catalog = "fcs")
public class NetsuiteSalesperson implements java.io.Serializable {

	private Integer salespersonId;
	private long netsuiteId;
	private String intranetUsername;
	private String firstName;
	private String lastName;
	private String phone;
	private String email;
	private String title;
	private boolean canDeduct;
	private boolean isActive;
	private Integer extension;
	private Date created;
	private Date updated;

	public NetsuiteSalesperson() {
	}

	public NetsuiteSalesperson(long netsuiteId, String intranetUsername,
			String firstName, String lastName, String phone, String email,
			String title, boolean canDeduct, boolean isActive, Date created,
			Date updated) {
		this.netsuiteId = netsuiteId;
		this.intranetUsername = intranetUsername;
		this.firstName = firstName;
		this.lastName = lastName;
		this.phone = phone;
		this.email = email;
		this.title = title;
		this.canDeduct = canDeduct;
		this.isActive = isActive;
		this.created = created;
		this.updated = updated;
	}

	public NetsuiteSalesperson(long netsuiteId, String intranetUsername,
			String firstName, String lastName, String phone, String email,
			String title, boolean canDeduct, boolean isActive,
			Integer extension, Date created, Date updated) {
		this.netsuiteId = netsuiteId;
		this.intranetUsername = intranetUsername;
		this.firstName = firstName;
		this.lastName = lastName;
		this.phone = phone;
		this.email = email;
		this.title = title;
		this.canDeduct = canDeduct;
		this.isActive = isActive;
		this.extension = extension;
		this.created = created;
		this.updated = updated;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "salesperson_id", unique = true, nullable = false)
	public Integer getSalespersonId() {
		return this.salespersonId;
	}

	public void setSalespersonId(Integer salespersonId) {
		this.salespersonId = salespersonId;
	}

	@Column(name = "netsuite_id", nullable = false)
	public long getNetsuiteId() {
		return this.netsuiteId;
	}

	public void setNetsuiteId(long netsuiteId) {
		this.netsuiteId = netsuiteId;
	}

	@Column(name = "intranet_username", nullable = false)
	public String getIntranetUsername() {
		return this.intranetUsername;
	}

	public void setIntranetUsername(String intranetUsername) {
		this.intranetUsername = intranetUsername;
	}

	@Column(name = "first_name", nullable = false, length = 80)
	public String getFirstName() {
		return this.firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	@Column(name = "last_name", nullable = false, length = 80)
	public String getLastName() {
		return this.lastName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	@Column(name = "phone", nullable = false, length = 20)
	public String getPhone() {
		return this.phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	@Column(name = "email", nullable = false, length = 128)
	public String getEmail() {
		return this.email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	@Column(name = "title", nullable = false, length = 128)
	public String getTitle() {
		return this.title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	@Column(name = "can_deduct", nullable = false)
	public boolean isCanDeduct() {
		return this.canDeduct;
	}

	public void setCanDeduct(boolean canDeduct) {
		this.canDeduct = canDeduct;
	}

	@Column(name = "is_active", nullable = false)
	public boolean isIsActive() {
		return this.isActive;
	}

	public void setIsActive(boolean isActive) {
		this.isActive = isActive;
	}

	@Column(name = "extension")
	public Integer getExtension() {
		return this.extension;
	}

	public void setExtension(Integer extension) {
		this.extension = extension;
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
