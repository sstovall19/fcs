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
 * IntranetUserPermissionXref generated by hbm2java
 */
@Entity
@Table(name = "intranet_user_permission_xref", catalog = "fcs", uniqueConstraints = @UniqueConstraint(columnNames = {
		"intranet_user_id", "permission_id" }))
public class IntranetUserPermissionXref implements java.io.Serializable {

	private Integer intranetUserPermissionXrefId;
	private IntranetUser intranetUser;
	private IntranetPermission intranetPermission;
	private String access;
	private Date updated;

	public IntranetUserPermissionXref() {
	}

	public IntranetUserPermissionXref(IntranetUser intranetUser,
			IntranetPermission intranetPermission, String access, Date updated) {
		this.intranetUser = intranetUser;
		this.intranetPermission = intranetPermission;
		this.access = access;
		this.updated = updated;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "intranet_user_permission_xref_id", unique = true, nullable = false)
	public Integer getIntranetUserPermissionXrefId() {
		return this.intranetUserPermissionXrefId;
	}

	public void setIntranetUserPermissionXrefId(
			Integer intranetUserPermissionXrefId) {
		this.intranetUserPermissionXrefId = intranetUserPermissionXrefId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "intranet_user_id", nullable = false)
	public IntranetUser getIntranetUser() {
		return this.intranetUser;
	}

	public void setIntranetUser(IntranetUser intranetUser) {
		this.intranetUser = intranetUser;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "permission_id", nullable = false)
	public IntranetPermission getIntranetPermission() {
		return this.intranetPermission;
	}

	public void setIntranetPermission(IntranetPermission intranetPermission) {
		this.intranetPermission = intranetPermission;
	}

	@Column(name = "access", nullable = false, length = 3)
	public String getAccess() {
		return this.access;
	}

	public void setAccess(String access) {
		this.access = access;
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