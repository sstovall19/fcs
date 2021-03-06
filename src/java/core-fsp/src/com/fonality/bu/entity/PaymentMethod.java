package com.fonality.bu.entity;

// Generated Mar 21, 2013 12:26:07 PM by Hibernate Tools 3.4.0.CR1

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
import javax.persistence.UniqueConstraint;

/**
 * PaymentMethod generated by hbm2java
 */
@Entity
@Table(name = "payment_method", catalog = "fcs", uniqueConstraints = @UniqueConstraint(columnNames = "name"))
public class PaymentMethod implements java.io.Serializable {

	private Integer paymentMethodId;
	private String name;
	private Set<BillingSchedule> billingSchedules = new HashSet<BillingSchedule>(
			0);
	private Set<OrderTransaction> orderTransactions = new HashSet<OrderTransaction>(
			0);
	private Set<Orders> orderses = new HashSet<Orders>(0);

	public PaymentMethod() {
	}

	public PaymentMethod(String name) {
		this.name = name;
	}

	public PaymentMethod(String name, Set<BillingSchedule> billingSchedules,
			Set<OrderTransaction> orderTransactions, Set<Orders> orderses) {
		this.name = name;
		this.billingSchedules = billingSchedules;
		this.orderTransactions = orderTransactions;
		this.orderses = orderses;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "payment_method_id", unique = true, nullable = false)
	public Integer getPaymentMethodId() {
		return this.paymentMethodId;
	}

	public void setPaymentMethodId(Integer paymentMethodId) {
		this.paymentMethodId = paymentMethodId;
	}

	@Column(name = "name", unique = true, nullable = false, length = 80)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "paymentMethod")
	public Set<BillingSchedule> getBillingSchedules() {
		return this.billingSchedules;
	}

	public void setBillingSchedules(Set<BillingSchedule> billingSchedules) {
		this.billingSchedules = billingSchedules;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "paymentMethod")
	public Set<OrderTransaction> getOrderTransactions() {
		return this.orderTransactions;
	}

	public void setOrderTransactions(Set<OrderTransaction> orderTransactions) {
		this.orderTransactions = orderTransactions;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "paymentMethod")
	public Set<Orders> getOrderses() {
		return this.orderses;
	}

	public void setOrderses(Set<Orders> orderses) {
		this.orderses = orderses;
	}

}
