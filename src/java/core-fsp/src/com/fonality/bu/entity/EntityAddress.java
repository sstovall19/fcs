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
 * EntityAddress generated by hbm2java
 */
@Entity
@Table(name = "entity_address", catalog = "fcs", uniqueConstraints = @UniqueConstraint(columnNames = {
		"type", "addr1", "city", "state_prov", "postal" }))
public class EntityAddress implements java.io.Serializable {

	private Integer entityAddressId;
	private String label;
	private String type;
	private String addr1;
	private String addr2;
	private String city;
	private String stateProv;
	private String postal;
	private String country;
	private Date created;
	private Date updated;
	private Set<CustomerAddress> customerAddresses = new HashSet<CustomerAddress>(
			0);
	private Set<EntityCreditCard> entityCreditCards = new HashSet<EntityCreditCard>(
			0);
	private Set<OrderGroup> orderGroupsForShippingAddressId = new HashSet<OrderGroup>(
			0);
	private Set<OrderGroup> orderGroupsForBillingAddressId = new HashSet<OrderGroup>(
			0);

	public EntityAddress() {
	}

	public EntityAddress(String label, String type, String addr1, String addr2,
			String city, String stateProv, String postal, String country,
			Date created, Date updated) {
		this.label = label;
		this.type = type;
		this.addr1 = addr1;
		this.addr2 = addr2;
		this.city = city;
		this.stateProv = stateProv;
		this.postal = postal;
		this.country = country;
		this.created = created;
		this.updated = updated;
	}

	public EntityAddress(String label, String type, String addr1, String addr2,
			String city, String stateProv, String postal, String country,
			Date created, Date updated, Set<CustomerAddress> customerAddresses,
			Set<EntityCreditCard> entityCreditCards,
			Set<OrderGroup> orderGroupsForShippingAddressId,
			Set<OrderGroup> orderGroupsForBillingAddressId) {
		this.label = label;
		this.type = type;
		this.addr1 = addr1;
		this.addr2 = addr2;
		this.city = city;
		this.stateProv = stateProv;
		this.postal = postal;
		this.country = country;
		this.created = created;
		this.updated = updated;
		this.customerAddresses = customerAddresses;
		this.entityCreditCards = entityCreditCards;
		this.orderGroupsForShippingAddressId = orderGroupsForShippingAddressId;
		this.orderGroupsForBillingAddressId = orderGroupsForBillingAddressId;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "entity_address_id", unique = true, nullable = false)
	public Integer getEntityAddressId() {
		return this.entityAddressId;
	}

	public void setEntityAddressId(Integer entityAddressId) {
		this.entityAddressId = entityAddressId;
	}

	@Column(name = "label", nullable = false, length = 128)
	public String getLabel() {
		return this.label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	@Column(name = "type", nullable = false, length = 8)
	public String getType() {
		return this.type;
	}

	public void setType(String type) {
		this.type = type;
	}

	@Column(name = "addr1", nullable = false, length = 128)
	public String getAddr1() {
		return this.addr1;
	}

	public void setAddr1(String addr1) {
		this.addr1 = addr1;
	}

	@Column(name = "addr2", nullable = false, length = 128)
	public String getAddr2() {
		return this.addr2;
	}

	public void setAddr2(String addr2) {
		this.addr2 = addr2;
	}

	@Column(name = "city", nullable = false, length = 128)
	public String getCity() {
		return this.city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	@Column(name = "state_prov", nullable = false, length = 10)
	public String getStateProv() {
		return this.stateProv;
	}

	public void setStateProv(String stateProv) {
		this.stateProv = stateProv;
	}

	@Column(name = "postal", nullable = false, length = 20)
	public String getPostal() {
		return this.postal;
	}

	public void setPostal(String postal) {
		this.postal = postal;
	}

	@Column(name = "country", nullable = false, length = 3)
	public String getCountry() {
		return this.country;
	}

	public void setCountry(String country) {
		this.country = country;
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

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "entityAddress")
	public Set<CustomerAddress> getCustomerAddresses() {
		return this.customerAddresses;
	}

	public void setCustomerAddresses(Set<CustomerAddress> customerAddresses) {
		this.customerAddresses = customerAddresses;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "entityAddress")
	public Set<EntityCreditCard> getEntityCreditCards() {
		return this.entityCreditCards;
	}

	public void setEntityCreditCards(Set<EntityCreditCard> entityCreditCards) {
		this.entityCreditCards = entityCreditCards;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "entityAddressByShippingAddressId")
	public Set<OrderGroup> getOrderGroupsForShippingAddressId() {
		return this.orderGroupsForShippingAddressId;
	}

	public void setOrderGroupsForShippingAddressId(
			Set<OrderGroup> orderGroupsForShippingAddressId) {
		this.orderGroupsForShippingAddressId = orderGroupsForShippingAddressId;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "entityAddressByBillingAddressId")
	public Set<OrderGroup> getOrderGroupsForBillingAddressId() {
		return this.orderGroupsForBillingAddressId;
	}

	public void setOrderGroupsForBillingAddressId(
			Set<OrderGroup> orderGroupsForBillingAddressId) {
		this.orderGroupsForBillingAddressId = orderGroupsForBillingAddressId;
	}

}
