package com.fonality.bu.entity;

// Generated Mar 21, 2013 12:26:07 PM by Hibernate Tools 3.4.0.CR1

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * UnboundCdrTest generated by hbm2java
 */
@Entity
@Table(name = "unbound_cdr_test", catalog = "fcs")
public class UnboundCdrTest implements java.io.Serializable {

	private String uniqueId;
	private int serverId;
	private Integer invoiceId;
	private Date calldate;
	private String did;
	private String ani;
	private String dialedNumber;
	private String isMobile;
	private Integer callDuration;
	private Integer billableDuration;
	private Float billedAmount;
	private Float customerBilledAmount;
	private String disposition;
	private String virtualPhone;
	private String inphonexId;
	private String country;
	private String info;
	private String providerId;
	private String providerType;
	private String providerCustomerId;
	private Boolean international;
	private String direction;
	private String callType;

	public UnboundCdrTest() {
	}

	public UnboundCdrTest(String uniqueId, int serverId, Date calldate) {
		this.uniqueId = uniqueId;
		this.serverId = serverId;
		this.calldate = calldate;
	}

	public UnboundCdrTest(String uniqueId, int serverId, Integer invoiceId,
			Date calldate, String did, String ani, String dialedNumber,
			String isMobile, Integer callDuration, Integer billableDuration,
			Float billedAmount, Float customerBilledAmount, String disposition,
			String virtualPhone, String inphonexId, String country,
			String info, String providerId, String providerType,
			String providerCustomerId, Boolean international, String direction,
			String callType) {
		this.uniqueId = uniqueId;
		this.serverId = serverId;
		this.invoiceId = invoiceId;
		this.calldate = calldate;
		this.did = did;
		this.ani = ani;
		this.dialedNumber = dialedNumber;
		this.isMobile = isMobile;
		this.callDuration = callDuration;
		this.billableDuration = billableDuration;
		this.billedAmount = billedAmount;
		this.customerBilledAmount = customerBilledAmount;
		this.disposition = disposition;
		this.virtualPhone = virtualPhone;
		this.inphonexId = inphonexId;
		this.country = country;
		this.info = info;
		this.providerId = providerId;
		this.providerType = providerType;
		this.providerCustomerId = providerCustomerId;
		this.international = international;
		this.direction = direction;
		this.callType = callType;
	}

	@Id
	@Column(name = "unique_id", unique = true, nullable = false, length = 32)
	public String getUniqueId() {
		return this.uniqueId;
	}

	public void setUniqueId(String uniqueId) {
		this.uniqueId = uniqueId;
	}

	@Column(name = "server_id", nullable = false)
	public int getServerId() {
		return this.serverId;
	}

	public void setServerId(int serverId) {
		this.serverId = serverId;
	}

	@Column(name = "invoice_id")
	public Integer getInvoiceId() {
		return this.invoiceId;
	}

	public void setInvoiceId(Integer invoiceId) {
		this.invoiceId = invoiceId;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "calldate", nullable = false, length = 0)
	public Date getCalldate() {
		return this.calldate;
	}

	public void setCalldate(Date calldate) {
		this.calldate = calldate;
	}

	@Column(name = "did", length = 20)
	public String getDid() {
		return this.did;
	}

	public void setDid(String did) {
		this.did = did;
	}

	@Column(name = "ani", length = 20)
	public String getAni() {
		return this.ani;
	}

	public void setAni(String ani) {
		this.ani = ani;
	}

	@Column(name = "dialed_number", length = 20)
	public String getDialedNumber() {
		return this.dialedNumber;
	}

	public void setDialedNumber(String dialedNumber) {
		this.dialedNumber = dialedNumber;
	}

	@Column(name = "is_mobile", length = 1)
	public String getIsMobile() {
		return this.isMobile;
	}

	public void setIsMobile(String isMobile) {
		this.isMobile = isMobile;
	}

	@Column(name = "call_duration")
	public Integer getCallDuration() {
		return this.callDuration;
	}

	public void setCallDuration(Integer callDuration) {
		this.callDuration = callDuration;
	}

	@Column(name = "billable_duration")
	public Integer getBillableDuration() {
		return this.billableDuration;
	}

	public void setBillableDuration(Integer billableDuration) {
		this.billableDuration = billableDuration;
	}

	@Column(name = "billed_amount", precision = 12, scale = 0)
	public Float getBilledAmount() {
		return this.billedAmount;
	}

	public void setBilledAmount(Float billedAmount) {
		this.billedAmount = billedAmount;
	}

	@Column(name = "customer_billed_amount", precision = 12, scale = 0)
	public Float getCustomerBilledAmount() {
		return this.customerBilledAmount;
	}

	public void setCustomerBilledAmount(Float customerBilledAmount) {
		this.customerBilledAmount = customerBilledAmount;
	}

	@Column(name = "disposition", length = 10)
	public String getDisposition() {
		return this.disposition;
	}

	public void setDisposition(String disposition) {
		this.disposition = disposition;
	}

	@Column(name = "virtual_phone", length = 7)
	public String getVirtualPhone() {
		return this.virtualPhone;
	}

	public void setVirtualPhone(String virtualPhone) {
		this.virtualPhone = virtualPhone;
	}

	@Column(name = "inphonex_id", length = 7)
	public String getInphonexId() {
		return this.inphonexId;
	}

	public void setInphonexId(String inphonexId) {
		this.inphonexId = inphonexId;
	}

	@Column(name = "country", length = 2)
	public String getCountry() {
		return this.country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	@Column(name = "info", length = 100)
	public String getInfo() {
		return this.info;
	}

	public void setInfo(String info) {
		this.info = info;
	}

	@Column(name = "provider_id", length = 20)
	public String getProviderId() {
		return this.providerId;
	}

	public void setProviderId(String providerId) {
		this.providerId = providerId;
	}

	@Column(name = "provider_type", length = 40)
	public String getProviderType() {
		return this.providerType;
	}

	public void setProviderType(String providerType) {
		this.providerType = providerType;
	}

	@Column(name = "provider_customer_id", length = 20)
	public String getProviderCustomerId() {
		return this.providerCustomerId;
	}

	public void setProviderCustomerId(String providerCustomerId) {
		this.providerCustomerId = providerCustomerId;
	}

	@Column(name = "international")
	public Boolean getInternational() {
		return this.international;
	}

	public void setInternational(Boolean international) {
		this.international = international;
	}

	@Column(name = "direction", length = 8)
	public String getDirection() {
		return this.direction;
	}

	public void setDirection(String direction) {
		this.direction = direction;
	}

	@Column(name = "call_type", length = 9)
	public String getCallType() {
		return this.callType;
	}

	public void setCallType(String callType) {
		this.callType = callType;
	}

}
