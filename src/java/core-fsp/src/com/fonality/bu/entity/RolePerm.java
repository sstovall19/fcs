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
 * RolePerm generated by hbm2java
 */
@Entity
@Table(name = "role_perm", catalog = "fcs")
public class RolePerm implements java.io.Serializable {

	private Integer rolePermId;
	private Role role;
	private Perm perm;
	private Groups groups;
	private String type;
	private Integer conferenceNo;
	private Integer conferenceServerId;
	private Date updated;

	public RolePerm() {
	}

	public RolePerm(Role role, Perm perm, String type, Date updated) {
		this.role = role;
		this.perm = perm;
		this.type = type;
		this.updated = updated;
	}

	public RolePerm(Role role, Perm perm, Groups groups, String type,
			Integer conferenceNo, Integer conferenceServerId, Date updated) {
		this.role = role;
		this.perm = perm;
		this.groups = groups;
		this.type = type;
		this.conferenceNo = conferenceNo;
		this.conferenceServerId = conferenceServerId;
		this.updated = updated;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "role_perm_id", unique = true, nullable = false)
	public Integer getRolePermId() {
		return this.rolePermId;
	}

	public void setRolePermId(Integer rolePermId) {
		this.rolePermId = rolePermId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "role_id", nullable = false)
	public Role getRole() {
		return this.role;
	}

	public void setRole(Role role) {
		this.role = role;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "perm_id", nullable = false)
	public Perm getPerm() {
		return this.perm;
	}

	public void setPerm(Perm perm) {
		this.perm = perm;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "group_id")
	public Groups getGroups() {
		return this.groups;
	}

	public void setGroups(Groups groups) {
		this.groups = groups;
	}

	@Column(name = "type", nullable = false, length = 8)
	public String getType() {
		return this.type;
	}

	public void setType(String type) {
		this.type = type;
	}

	@Column(name = "conference_no")
	public Integer getConferenceNo() {
		return this.conferenceNo;
	}

	public void setConferenceNo(Integer conferenceNo) {
		this.conferenceNo = conferenceNo;
	}

	@Column(name = "conference_server_id")
	public Integer getConferenceServerId() {
		return this.conferenceServerId;
	}

	public void setConferenceServerId(Integer conferenceServerId) {
		this.conferenceServerId = conferenceServerId;
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
