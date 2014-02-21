package com.fonality.bu.entity;

// Generated Mar 21, 2013 12:26:07 PM by Hibernate Tools 3.4.0.CR1

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import static javax.persistence.GenerationType.IDENTITY;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

/**
 * ServerProvider generated by hbm2java
 */
@Entity
@Table(name = "server_provider", catalog = "fcs", uniqueConstraints = @UniqueConstraint(columnNames = {
		"server_id", "provider_id" }))
public class ServerProvider implements java.io.Serializable {

	private Integer serverProviderId;
	private Provider provider;
	private int serverId;
	private Integer providerCustomerId;
	private String providerUsername;
	private String providerPassword;
	private String providerPin;

	public ServerProvider() {
	}

	public ServerProvider(Provider provider, int serverId) {
		this.provider = provider;
		this.serverId = serverId;
	}

	public ServerProvider(Provider provider, int serverId,
			Integer providerCustomerId, String providerUsername,
			String providerPassword, String providerPin) {
		this.provider = provider;
		this.serverId = serverId;
		this.providerCustomerId = providerCustomerId;
		this.providerUsername = providerUsername;
		this.providerPassword = providerPassword;
		this.providerPin = providerPin;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "server_provider_id", unique = true, nullable = false)
	public Integer getServerProviderId() {
		return this.serverProviderId;
	}

	public void setServerProviderId(Integer serverProviderId) {
		this.serverProviderId = serverProviderId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "provider_id", nullable = false)
	public Provider getProvider() {
		return this.provider;
	}

	public void setProvider(Provider provider) {
		this.provider = provider;
	}

	@Column(name = "server_id", nullable = false)
	public int getServerId() {
		return this.serverId;
	}

	public void setServerId(int serverId) {
		this.serverId = serverId;
	}

	@Column(name = "provider_customer_id")
	public Integer getProviderCustomerId() {
		return this.providerCustomerId;
	}

	public void setProviderCustomerId(Integer providerCustomerId) {
		this.providerCustomerId = providerCustomerId;
	}

	@Column(name = "provider_username", length = 40)
	public String getProviderUsername() {
		return this.providerUsername;
	}

	public void setProviderUsername(String providerUsername) {
		this.providerUsername = providerUsername;
	}

	@Column(name = "provider_password", length = 32)
	public String getProviderPassword() {
		return this.providerPassword;
	}

	public void setProviderPassword(String providerPassword) {
		this.providerPassword = providerPassword;
	}

	@Column(name = "provider_pin", length = 5)
	public String getProviderPin() {
		return this.providerPin;
	}

	public void setProviderPin(String providerPin) {
		this.providerPin = providerPin;
	}

}