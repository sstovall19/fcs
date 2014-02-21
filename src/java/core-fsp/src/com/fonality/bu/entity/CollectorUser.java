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
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.UniqueConstraint;

/**
 * CollectorUser generated by hbm2java
 */
@Entity
@Table(name = "collector_user", catalog = "fcs", uniqueConstraints = {
		@UniqueConstraint(columnNames = "email"),
		@UniqueConstraint(columnNames = "username") })
public class CollectorUser implements java.io.Serializable {

	private Integer id;
	private String username;
	private String firstName;
	private String lastName;
	private String email;
	private String apiKey;
	private String salt;
	private int apiKeyUpdated;
	private Integer lockout;
	private String lastLoginIp;
	private Date created;
	private Date updated;
	private Set<CollectorUserIp> collectorUserIps = new HashSet<CollectorUserIp>(
			0);
	private Set<CollectorPermission> collectorPermissions = new HashSet<CollectorPermission>(
			0);

	public CollectorUser() {
	}

	public CollectorUser(String username, String firstName, String lastName,
			String email, String apiKey, String salt, int apiKeyUpdated,
			String lastLoginIp, Date created, Date updated) {
		this.username = username;
		this.firstName = firstName;
		this.lastName = lastName;
		this.email = email;
		this.apiKey = apiKey;
		this.salt = salt;
		this.apiKeyUpdated = apiKeyUpdated;
		this.lastLoginIp = lastLoginIp;
		this.created = created;
		this.updated = updated;
	}

	public CollectorUser(String username, String firstName, String lastName,
			String email, String apiKey, String salt, int apiKeyUpdated,
			Integer lockout, String lastLoginIp, Date created, Date updated,
			Set<CollectorUserIp> collectorUserIps,
			Set<CollectorPermission> collectorPermissions) {
		this.username = username;
		this.firstName = firstName;
		this.lastName = lastName;
		this.email = email;
		this.apiKey = apiKey;
		this.salt = salt;
		this.apiKeyUpdated = apiKeyUpdated;
		this.lockout = lockout;
		this.lastLoginIp = lastLoginIp;
		this.created = created;
		this.updated = updated;
		this.collectorUserIps = collectorUserIps;
		this.collectorPermissions = collectorPermissions;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "id", unique = true, nullable = false)
	public Integer getId() {
		return this.id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	@Column(name = "username", unique = true, nullable = false, length = 50)
	public String getUsername() {
		return this.username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	@Column(name = "first_name", nullable = false, length = 36)
	public String getFirstName() {
		return this.firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	@Column(name = "last_name", nullable = false, length = 36)
	public String getLastName() {
		return this.lastName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	@Column(name = "email", unique = true, nullable = false, length = 64)
	public String getEmail() {
		return this.email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	@Column(name = "api_key", nullable = false, length = 46)
	public String getApiKey() {
		return this.apiKey;
	}

	public void setApiKey(String apiKey) {
		this.apiKey = apiKey;
	}

	@Column(name = "salt", nullable = false, length = 16)
	public String getSalt() {
		return this.salt;
	}

	public void setSalt(String salt) {
		this.salt = salt;
	}

	@Column(name = "api_key_updated", nullable = false)
	public int getApiKeyUpdated() {
		return this.apiKeyUpdated;
	}

	public void setApiKeyUpdated(int apiKeyUpdated) {
		this.apiKeyUpdated = apiKeyUpdated;
	}

	@Column(name = "lockout")
	public Integer getLockout() {
		return this.lockout;
	}

	public void setLockout(Integer lockout) {
		this.lockout = lockout;
	}

	@Column(name = "last_login_ip", nullable = false, length = 39)
	public String getLastLoginIp() {
		return this.lastLoginIp;
	}

	public void setLastLoginIp(String lastLoginIp) {
		this.lastLoginIp = lastLoginIp;
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

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "collectorUser")
	public Set<CollectorUserIp> getCollectorUserIps() {
		return this.collectorUserIps;
	}

	public void setCollectorUserIps(Set<CollectorUserIp> collectorUserIps) {
		this.collectorUserIps = collectorUserIps;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "collectorUser")
	public Set<CollectorPermission> getCollectorPermissions() {
		return this.collectorPermissions;
	}

	public void setCollectorPermissions(
			Set<CollectorPermission> collectorPermissions) {
		this.collectorPermissions = collectorPermissions;
	}

}
