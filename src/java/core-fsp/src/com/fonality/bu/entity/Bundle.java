package com.fonality.bu.entity;

// Generated Mar 21, 2013 12:26:07 PM by Hibernate Tools 3.4.0.CR1

import java.math.BigDecimal;
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
 * Bundle generated by hbm2java
 */
@Entity
@Table(name = "bundle", catalog = "fcs", uniqueConstraints = @UniqueConstraint(columnNames = "name"))
public class Bundle implements java.io.Serializable {

	private Integer bundleId;
	private BundleCategory bundleCategory;
	private OrderLabel orderLabel;
	private String name;
	private String displayName;
	private String description;
	private String manufacturer;
	private String model;
	private boolean isInventory;
	private BigDecimal costPrice;
	private BigDecimal basePrice;
	private BigDecimal mrcPrice;
	private Long netsuiteOrderId;
	private Long netsuiteOneTimeId;
	private Long netsuiteMrcId;
	private boolean isActive;
	private byte displayPriority;
	private Date created;
	private Date updated;
	private Set<BundleRelationship> bundleRelationshipsForEnablesBundleId = new HashSet<BundleRelationship>(
			0);
	private Set<BundleRelationship> bundleRelationshipsForSetsMaxBundleId = new HashSet<BundleRelationship>(
			0);
	private Set<BundleRelationship> bundleRelationshipsForProvidesBundleId = new HashSet<BundleRelationship>(
			0);
	private Set<BundleRelationship> bundleRelationshipsForDisablesBundleId = new HashSet<BundleRelationship>(
			0);
	private Set<BundleLicense> bundleLicenses = new HashSet<BundleLicense>(0);
	private Set<BundleRelationship> bundleRelationshipsForBundleId = new HashSet<BundleRelationship>(
			0);
	private Set<PromoCode> promoCodes = new HashSet<PromoCode>(0);
	private Set<OrderTransactionItem> orderTransactionItems = new HashSet<OrderTransactionItem>(
			0);
	private Set<OrderBundle> orderBundles = new HashSet<OrderBundle>(0);
	private Set<BundlePriceModel> bundlePriceModels = new HashSet<BundlePriceModel>(
			0);
	private Set<PromoKit> promoKits = new HashSet<PromoKit>(0);
	private Set<BundleRelationship> bundleRelationshipsForSetsMinBundleId = new HashSet<BundleRelationship>(
			0);
	private Set<BundleFeature> bundleFeatures = new HashSet<BundleFeature>(0);
	private Set<BundleRelationship> bundleRelationshipsForRequiresBundleId = new HashSet<BundleRelationship>(
			0);
	private Set<BundleDiscount> bundleDiscounts = new HashSet<BundleDiscount>(0);
	private Set<PromoAction> promoActionsForBundleId = new HashSet<PromoAction>(
			0);
	private Set<PromoAction> promoActionsForUpgradeBundleId = new HashSet<PromoAction>(
			0);
	private Set<ServerBundle> serverBundles = new HashSet<ServerBundle>(0);
	private Set<BundlePacking> bundlePackings = new HashSet<BundlePacking>(0);

	public Bundle() {
	}

	public Bundle(BundleCategory bundleCategory, String name,
			String displayName, String description, String manufacturer,
			String model, boolean isInventory, BigDecimal costPrice,
			BigDecimal basePrice, BigDecimal mrcPrice, boolean isActive,
			byte displayPriority, Date created, Date updated) {
		this.bundleCategory = bundleCategory;
		this.name = name;
		this.displayName = displayName;
		this.description = description;
		this.manufacturer = manufacturer;
		this.model = model;
		this.isInventory = isInventory;
		this.costPrice = costPrice;
		this.basePrice = basePrice;
		this.mrcPrice = mrcPrice;
		this.isActive = isActive;
		this.displayPriority = displayPriority;
		this.created = created;
		this.updated = updated;
	}

	public Bundle(BundleCategory bundleCategory, OrderLabel orderLabel,
			String name, String displayName, String description,
			String manufacturer, String model, boolean isInventory,
			BigDecimal costPrice, BigDecimal basePrice, BigDecimal mrcPrice,
			Long netsuiteOrderId, Long netsuiteOneTimeId, Long netsuiteMrcId,
			boolean isActive, byte displayPriority, Date created, Date updated,
			Set<BundleRelationship> bundleRelationshipsForEnablesBundleId,
			Set<BundleRelationship> bundleRelationshipsForSetsMaxBundleId,
			Set<BundleRelationship> bundleRelationshipsForProvidesBundleId,
			Set<BundleRelationship> bundleRelationshipsForDisablesBundleId,
			Set<BundleLicense> bundleLicenses,
			Set<BundleRelationship> bundleRelationshipsForBundleId,
			Set<PromoCode> promoCodes,
			Set<OrderTransactionItem> orderTransactionItems,
			Set<OrderBundle> orderBundles,
			Set<BundlePriceModel> bundlePriceModels, Set<PromoKit> promoKits,
			Set<BundleRelationship> bundleRelationshipsForSetsMinBundleId,
			Set<BundleFeature> bundleFeatures,
			Set<BundleRelationship> bundleRelationshipsForRequiresBundleId,
			Set<BundleDiscount> bundleDiscounts,
			Set<PromoAction> promoActionsForBundleId,
			Set<PromoAction> promoActionsForUpgradeBundleId,
			Set<ServerBundle> serverBundles, Set<BundlePacking> bundlePackings) {
		this.bundleCategory = bundleCategory;
		this.orderLabel = orderLabel;
		this.name = name;
		this.displayName = displayName;
		this.description = description;
		this.manufacturer = manufacturer;
		this.model = model;
		this.isInventory = isInventory;
		this.costPrice = costPrice;
		this.basePrice = basePrice;
		this.mrcPrice = mrcPrice;
		this.netsuiteOrderId = netsuiteOrderId;
		this.netsuiteOneTimeId = netsuiteOneTimeId;
		this.netsuiteMrcId = netsuiteMrcId;
		this.isActive = isActive;
		this.displayPriority = displayPriority;
		this.created = created;
		this.updated = updated;
		this.bundleRelationshipsForEnablesBundleId = bundleRelationshipsForEnablesBundleId;
		this.bundleRelationshipsForSetsMaxBundleId = bundleRelationshipsForSetsMaxBundleId;
		this.bundleRelationshipsForProvidesBundleId = bundleRelationshipsForProvidesBundleId;
		this.bundleRelationshipsForDisablesBundleId = bundleRelationshipsForDisablesBundleId;
		this.bundleLicenses = bundleLicenses;
		this.bundleRelationshipsForBundleId = bundleRelationshipsForBundleId;
		this.promoCodes = promoCodes;
		this.orderTransactionItems = orderTransactionItems;
		this.orderBundles = orderBundles;
		this.bundlePriceModels = bundlePriceModels;
		this.promoKits = promoKits;
		this.bundleRelationshipsForSetsMinBundleId = bundleRelationshipsForSetsMinBundleId;
		this.bundleFeatures = bundleFeatures;
		this.bundleRelationshipsForRequiresBundleId = bundleRelationshipsForRequiresBundleId;
		this.bundleDiscounts = bundleDiscounts;
		this.promoActionsForBundleId = promoActionsForBundleId;
		this.promoActionsForUpgradeBundleId = promoActionsForUpgradeBundleId;
		this.serverBundles = serverBundles;
		this.bundlePackings = bundlePackings;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "bundle_id", unique = true, nullable = false)
	public Integer getBundleId() {
		return this.bundleId;
	}

	public void setBundleId(Integer bundleId) {
		this.bundleId = bundleId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "category_id", nullable = false)
	public BundleCategory getBundleCategory() {
		return this.bundleCategory;
	}

	public void setBundleCategory(BundleCategory bundleCategory) {
		this.bundleCategory = bundleCategory;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "order_label_id")
	public OrderLabel getOrderLabel() {
		return this.orderLabel;
	}

	public void setOrderLabel(OrderLabel orderLabel) {
		this.orderLabel = orderLabel;
	}

	@Column(name = "name", unique = true, nullable = false)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "display_name", nullable = false)
	public String getDisplayName() {
		return this.displayName;
	}

	public void setDisplayName(String displayName) {
		this.displayName = displayName;
	}

	@Column(name = "description", nullable = false, length = 16777215)
	public String getDescription() {
		return this.description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	@Column(name = "manufacturer", nullable = false)
	public String getManufacturer() {
		return this.manufacturer;
	}

	public void setManufacturer(String manufacturer) {
		this.manufacturer = manufacturer;
	}

	@Column(name = "model", nullable = false)
	public String getModel() {
		return this.model;
	}

	public void setModel(String model) {
		this.model = model;
	}

	@Column(name = "is_inventory", nullable = false)
	public boolean isIsInventory() {
		return this.isInventory;
	}

	public void setIsInventory(boolean isInventory) {
		this.isInventory = isInventory;
	}

	@Column(name = "cost_price", nullable = false, precision = 10)
	public BigDecimal getCostPrice() {
		return this.costPrice;
	}

	public void setCostPrice(BigDecimal costPrice) {
		this.costPrice = costPrice;
	}

	@Column(name = "base_price", nullable = false, precision = 10)
	public BigDecimal getBasePrice() {
		return this.basePrice;
	}

	public void setBasePrice(BigDecimal basePrice) {
		this.basePrice = basePrice;
	}

	@Column(name = "mrc_price", nullable = false, precision = 10)
	public BigDecimal getMrcPrice() {
		return this.mrcPrice;
	}

	public void setMrcPrice(BigDecimal mrcPrice) {
		this.mrcPrice = mrcPrice;
	}

	@Column(name = "netsuite_order_id")
	public Long getNetsuiteOrderId() {
		return this.netsuiteOrderId;
	}

	public void setNetsuiteOrderId(Long netsuiteOrderId) {
		this.netsuiteOrderId = netsuiteOrderId;
	}

	@Column(name = "netsuite_one_time_id")
	public Long getNetsuiteOneTimeId() {
		return this.netsuiteOneTimeId;
	}

	public void setNetsuiteOneTimeId(Long netsuiteOneTimeId) {
		this.netsuiteOneTimeId = netsuiteOneTimeId;
	}

	@Column(name = "netsuite_mrc_id")
	public Long getNetsuiteMrcId() {
		return this.netsuiteMrcId;
	}

	public void setNetsuiteMrcId(Long netsuiteMrcId) {
		this.netsuiteMrcId = netsuiteMrcId;
	}

	@Column(name = "is_active", nullable = false)
	public boolean isIsActive() {
		return this.isActive;
	}

	public void setIsActive(boolean isActive) {
		this.isActive = isActive;
	}

	@Column(name = "display_priority", nullable = false)
	public byte getDisplayPriority() {
		return this.displayPriority;
	}

	public void setDisplayPriority(byte displayPriority) {
		this.displayPriority = displayPriority;
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

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundleByEnablesBundleId")
	public Set<BundleRelationship> getBundleRelationshipsForEnablesBundleId() {
		return this.bundleRelationshipsForEnablesBundleId;
	}

	public void setBundleRelationshipsForEnablesBundleId(
			Set<BundleRelationship> bundleRelationshipsForEnablesBundleId) {
		this.bundleRelationshipsForEnablesBundleId = bundleRelationshipsForEnablesBundleId;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundleBySetsMaxBundleId")
	public Set<BundleRelationship> getBundleRelationshipsForSetsMaxBundleId() {
		return this.bundleRelationshipsForSetsMaxBundleId;
	}

	public void setBundleRelationshipsForSetsMaxBundleId(
			Set<BundleRelationship> bundleRelationshipsForSetsMaxBundleId) {
		this.bundleRelationshipsForSetsMaxBundleId = bundleRelationshipsForSetsMaxBundleId;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundleByProvidesBundleId")
	public Set<BundleRelationship> getBundleRelationshipsForProvidesBundleId() {
		return this.bundleRelationshipsForProvidesBundleId;
	}

	public void setBundleRelationshipsForProvidesBundleId(
			Set<BundleRelationship> bundleRelationshipsForProvidesBundleId) {
		this.bundleRelationshipsForProvidesBundleId = bundleRelationshipsForProvidesBundleId;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundleByDisablesBundleId")
	public Set<BundleRelationship> getBundleRelationshipsForDisablesBundleId() {
		return this.bundleRelationshipsForDisablesBundleId;
	}

	public void setBundleRelationshipsForDisablesBundleId(
			Set<BundleRelationship> bundleRelationshipsForDisablesBundleId) {
		this.bundleRelationshipsForDisablesBundleId = bundleRelationshipsForDisablesBundleId;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundle")
	public Set<BundleLicense> getBundleLicenses() {
		return this.bundleLicenses;
	}

	public void setBundleLicenses(Set<BundleLicense> bundleLicenses) {
		this.bundleLicenses = bundleLicenses;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundleByBundleId")
	public Set<BundleRelationship> getBundleRelationshipsForBundleId() {
		return this.bundleRelationshipsForBundleId;
	}

	public void setBundleRelationshipsForBundleId(
			Set<BundleRelationship> bundleRelationshipsForBundleId) {
		this.bundleRelationshipsForBundleId = bundleRelationshipsForBundleId;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundle")
	public Set<PromoCode> getPromoCodes() {
		return this.promoCodes;
	}

	public void setPromoCodes(Set<PromoCode> promoCodes) {
		this.promoCodes = promoCodes;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundle")
	public Set<OrderTransactionItem> getOrderTransactionItems() {
		return this.orderTransactionItems;
	}

	public void setOrderTransactionItems(
			Set<OrderTransactionItem> orderTransactionItems) {
		this.orderTransactionItems = orderTransactionItems;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundle")
	public Set<OrderBundle> getOrderBundles() {
		return this.orderBundles;
	}

	public void setOrderBundles(Set<OrderBundle> orderBundles) {
		this.orderBundles = orderBundles;
	}

	@OneToMany(fetch = FetchType.EAGER, mappedBy = "bundle")
	public Set<BundlePriceModel> getBundlePriceModels() {
		return this.bundlePriceModels;
	}

	public void setBundlePriceModels(Set<BundlePriceModel> bundlePriceModels) {
		this.bundlePriceModels = bundlePriceModels;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundle")
	public Set<PromoKit> getPromoKits() {
		return this.promoKits;
	}

	public void setPromoKits(Set<PromoKit> promoKits) {
		this.promoKits = promoKits;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundleBySetsMinBundleId")
	public Set<BundleRelationship> getBundleRelationshipsForSetsMinBundleId() {
		return this.bundleRelationshipsForSetsMinBundleId;
	}

	public void setBundleRelationshipsForSetsMinBundleId(
			Set<BundleRelationship> bundleRelationshipsForSetsMinBundleId) {
		this.bundleRelationshipsForSetsMinBundleId = bundleRelationshipsForSetsMinBundleId;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundle")
	public Set<BundleFeature> getBundleFeatures() {
		return this.bundleFeatures;
	}

	public void setBundleFeatures(Set<BundleFeature> bundleFeatures) {
		this.bundleFeatures = bundleFeatures;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundleByRequiresBundleId")
	public Set<BundleRelationship> getBundleRelationshipsForRequiresBundleId() {
		return this.bundleRelationshipsForRequiresBundleId;
	}

	public void setBundleRelationshipsForRequiresBundleId(
			Set<BundleRelationship> bundleRelationshipsForRequiresBundleId) {
		this.bundleRelationshipsForRequiresBundleId = bundleRelationshipsForRequiresBundleId;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundle")
	public Set<BundleDiscount> getBundleDiscounts() {
		return this.bundleDiscounts;
	}

	public void setBundleDiscounts(Set<BundleDiscount> bundleDiscounts) {
		this.bundleDiscounts = bundleDiscounts;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundleByBundleId")
	public Set<PromoAction> getPromoActionsForBundleId() {
		return this.promoActionsForBundleId;
	}

	public void setPromoActionsForBundleId(
			Set<PromoAction> promoActionsForBundleId) {
		this.promoActionsForBundleId = promoActionsForBundleId;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundleByUpgradeBundleId")
	public Set<PromoAction> getPromoActionsForUpgradeBundleId() {
		return this.promoActionsForUpgradeBundleId;
	}

	public void setPromoActionsForUpgradeBundleId(
			Set<PromoAction> promoActionsForUpgradeBundleId) {
		this.promoActionsForUpgradeBundleId = promoActionsForUpgradeBundleId;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundle")
	public Set<ServerBundle> getServerBundles() {
		return this.serverBundles;
	}

	public void setServerBundles(Set<ServerBundle> serverBundles) {
		this.serverBundles = serverBundles;
	}

	@OneToMany(fetch = FetchType.LAZY, mappedBy = "bundle")
	public Set<BundlePacking> getBundlePackings() {
		return this.bundlePackings;
	}

	public void setBundlePackings(Set<BundlePacking> bundlePackings) {
		this.bundlePackings = bundlePackings;
	}

}
