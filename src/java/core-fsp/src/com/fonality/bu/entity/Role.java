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
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.UniqueConstraint;

/**
 * Role generated by hbm2java
 */
@Entity
@Table(name = "role", catalog = "fcs", uniqueConstraints = @UniqueConstraint(columnNames = {
		"name", "server_id" }))
public class Role implements java.io.Serializable {

	private Integer roleId;
	private LicenseType licenseType;
	private String name;
	private boolean autoAddUser;
	private int serverId;
	private Date created;
	private Date updated;
	private Set<UserRole> userRoles = new HashSet<UserRole>(0);
	private Set<RoleTollrestriction> roleTollrestrictions = new HashSet<RoleTollrestriction>(
			0);
	private Set<RolePerm> rolePerms = new HashSet<RolePerm>(0);

	public Role() {
	}

	public Role(LicenseType licenseType, String name, boolean autoAddUser,
			int serverId, Date created, Date updated) {
		this.licenseType = licenseType;
		this.name = name;
		this.autoAddUser = autoAddUser;
		this.serverId = serverId;
		this.created = created;
		this.updated = updated;
	}

	public Role(LicenseType licenseType, String name, boolean autoAddUser,
			int serverId, Date created, Date updated, Set<UserRole> userRoles,
			Set<RoleTollrestriction> roleTollrestrictions,
			Set<RolePerm> rolePerms) {
		this.licenseType = licenseType;
		this.name = name;
		this.autoAddUser = autoAddUser;
		this.serverId = serverId;
		this.created = created;
		this.updated = updated;
		this.userRoles = userRoles;
		this.roleTollrestrictions = roleTollrestrictions;
		this.rolePerms = rolePerms;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "role_id", unique = true, nullable = false)
	public Integer getRoleId() {
		return this.roleId;
	}

	public void setRoleId(Integer roleId) {
		this.roleId = roleId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "license_type_id", nullable = false)
	public LicenseType getLicenseType() {
		return this.licenseType;
	}

	public void setLicenseType(LicenseType licenseType) {
		this.licenseType = licenseType;
	}

	@Column(name = "name", nullable = false, length = 50)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "auto_add_user", nullable = false)
	public boolean isAutoAddUser() {
		return this.autoAddUser;
	}

	public void setAutoAddUser(boolean autoAddUser) {
		this.autoAddUser = autoAddUser;
	}

	@Column(name = "server_id", nullable = false)
	public int getServerId() {
		return this.serverId;
	}

	public void setServerId(int serverId) {
		this.serverId = serverId;
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

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "role")
	public Set<UserRole> getUserRoles() {
		return this.userRoles;
	}

	public void setUserRoles(Set<UserRole> userRoles) {
		this.userRoles = userRoles;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "role")
	public Set<RoleTollrestriction> getRoleTollrestrictions() {
		return this.roleTollrestrictions;
	}

	public void setRoleTollrestrictions(
			Set<RoleTollrestriction> roleTollrestrictions) {
		this.roleTollrestrictions = roleTollrestrictions;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "role")
	public Set<RolePerm> getRolePerms() {
		return this.rolePerms;
	}

	public void setRolePerms(Set<RolePerm> rolePerms) {
		this.rolePerms = rolePerms;
	}

}
