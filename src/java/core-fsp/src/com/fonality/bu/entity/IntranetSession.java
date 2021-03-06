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
import javax.persistence.UniqueConstraint;

/**
 * IntranetSession generated by hbm2java
 */
@Entity
@Table(name = "intranet_session", catalog = "fcs", uniqueConstraints = @UniqueConstraint(columnNames = "guid"))
public class IntranetSession implements java.io.Serializable {

	private Integer intranetSessionId;
	private String guid;
	private String session;
	private String ipAddress;
	private Date created;
	private Date updated;

	public IntranetSession() {
	}

	public IntranetSession(String guid, String session, String ipAddress,
			Date created, Date updated) {
		this.guid = guid;
		this.session = session;
		this.ipAddress = ipAddress;
		this.created = created;
		this.updated = updated;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "intranet_session_id", unique = true, nullable = false)
	public Integer getIntranetSessionId() {
		return this.intranetSessionId;
	}

	public void setIntranetSessionId(Integer intranetSessionId) {
		this.intranetSessionId = intranetSessionId;
	}

	@Column(name = "guid", unique = true, nullable = false, length = 32)
	public String getGuid() {
		return this.guid;
	}

	public void setGuid(String guid) {
		this.guid = guid;
	}

	@Column(name = "session", nullable = false, length = 65535)
	public String getSession() {
		return this.session;
	}

	public void setSession(String session) {
		this.session = session;
	}

	@Column(name = "ip_address", nullable = false, length = 45)
	public String getIpAddress() {
		return this.ipAddress;
	}

	public void setIpAddress(String ipAddress) {
		this.ipAddress = ipAddress;
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
