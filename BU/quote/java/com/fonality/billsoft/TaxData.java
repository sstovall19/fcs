
package com.fonality.billsoft;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for TaxData complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="TaxData">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="AdjustmentType" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="Billable" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="CalculationType" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="CategoryDescription" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CategoryID" type="{http://www.w3.org/2001/XMLSchema}short" minOccurs="0"/>
 *         &lt;element name="CompanyIdentifier" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="Compliance" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="CustomerNumber" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="Description" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ExemptSaleAmount" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="ExemptionType" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="InvoiceNumber" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Lines" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="Locations" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="Minutes" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="Optional" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional10" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional4" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional5" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional6" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional7" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional8" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional9" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="OptionalAlpha1" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="PCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Rate" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="RefundUncollect" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="ServiceLevelNumber" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Surcharge" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="TaxAmount" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="TaxLevel" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="TaxType" type="{http://www.w3.org/2001/XMLSchema}short" minOccurs="0"/>
 *         &lt;element name="TaxableMeasure" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "TaxData", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", propOrder = {
    "adjustmentType",
    "billable",
    "calculationType",
    "categoryDescription",
    "categoryID",
    "companyIdentifier",
    "compliance",
    "customerNumber",
    "description",
    "exemptSaleAmount",
    "exemptionType",
    "invoiceNumber",
    "lines",
    "locations",
    "minutes",
    "optional",
    "optional10",
    "optional4",
    "optional5",
    "optional6",
    "optional7",
    "optional8",
    "optional9",
    "optionalAlpha1",
    "pCode",
    "rate",
    "refundUncollect",
    "serviceLevelNumber",
    "surcharge",
    "taxAmount",
    "taxLevel",
    "taxType",
    "taxableMeasure"
})
public class TaxData {

    @XmlElement(name = "AdjustmentType")
    protected Integer adjustmentType;
    @XmlElement(name = "Billable")
    protected Boolean billable;
    @XmlElement(name = "CalculationType")
    protected Integer calculationType;
    @XmlElementRef(name = "CategoryDescription", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> categoryDescription;
    @XmlElement(name = "CategoryID")
    protected Short categoryID;
    @XmlElementRef(name = "CompanyIdentifier", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> companyIdentifier;
    @XmlElement(name = "Compliance")
    protected Boolean compliance;
    @XmlElementRef(name = "CustomerNumber", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> customerNumber;
    @XmlElementRef(name = "Description", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> description;
    @XmlElement(name = "ExemptSaleAmount")
    protected Double exemptSaleAmount;
    @XmlElement(name = "ExemptionType")
    protected Integer exemptionType;
    @XmlElement(name = "InvoiceNumber")
    @XmlSchemaType(name = "unsignedInt")
    protected Long invoiceNumber;
    @XmlElement(name = "Lines")
    protected Integer lines;
    @XmlElement(name = "Locations")
    protected Integer locations;
    @XmlElement(name = "Minutes")
    protected Double minutes;
    @XmlElement(name = "Optional")
    @XmlSchemaType(name = "unsignedInt")
    protected Long optional;
    @XmlElement(name = "Optional10")
    @XmlSchemaType(name = "unsignedInt")
    protected Long optional10;
    @XmlElement(name = "Optional4")
    @XmlSchemaType(name = "unsignedInt")
    protected Long optional4;
    @XmlElement(name = "Optional5")
    @XmlSchemaType(name = "unsignedInt")
    protected Long optional5;
    @XmlElement(name = "Optional6")
    @XmlSchemaType(name = "unsignedInt")
    protected Long optional6;
    @XmlElement(name = "Optional7")
    @XmlSchemaType(name = "unsignedInt")
    protected Long optional7;
    @XmlElement(name = "Optional8")
    @XmlSchemaType(name = "unsignedInt")
    protected Long optional8;
    @XmlElement(name = "Optional9")
    @XmlSchemaType(name = "unsignedInt")
    protected Long optional9;
    @XmlElementRef(name = "OptionalAlpha1", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> optionalAlpha1;
    @XmlElement(name = "PCode")
    @XmlSchemaType(name = "unsignedInt")
    protected Long pCode;
    @XmlElement(name = "Rate")
    protected Double rate;
    @XmlElement(name = "RefundUncollect")
    protected Double refundUncollect;
    @XmlElement(name = "ServiceLevelNumber")
    @XmlSchemaType(name = "unsignedInt")
    protected Long serviceLevelNumber;
    @XmlElement(name = "Surcharge")
    protected Boolean surcharge;
    @XmlElement(name = "TaxAmount")
    protected Double taxAmount;
    @XmlElementRef(name = "TaxLevel", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Integer> taxLevel;
    @XmlElement(name = "TaxType")
    protected Short taxType;
    @XmlElement(name = "TaxableMeasure")
    protected Double taxableMeasure;

    /**
     * Gets the value of the adjustmentType property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getAdjustmentType() {
        return adjustmentType;
    }

    /**
     * Sets the value of the adjustmentType property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setAdjustmentType(Integer value) {
        this.adjustmentType = value;
    }

    /**
     * Gets the value of the billable property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isBillable() {
        return billable;
    }

    /**
     * Sets the value of the billable property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setBillable(Boolean value) {
        this.billable = value;
    }

    /**
     * Gets the value of the calculationType property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getCalculationType() {
        return calculationType;
    }

    /**
     * Sets the value of the calculationType property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCalculationType(Integer value) {
        this.calculationType = value;
    }

    /**
     * Gets the value of the categoryDescription property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getCategoryDescription() {
        return categoryDescription;
    }

    /**
     * Sets the value of the categoryDescription property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setCategoryDescription(JAXBElement<String> value) {
        this.categoryDescription = value;
    }

    /**
     * Gets the value of the categoryID property.
     * 
     * @return
     *     possible object is
     *     {@link Short }
     *     
     */
    public Short getCategoryID() {
        return categoryID;
    }

    /**
     * Sets the value of the categoryID property.
     * 
     * @param value
     *     allowed object is
     *     {@link Short }
     *     
     */
    public void setCategoryID(Short value) {
        this.categoryID = value;
    }

    /**
     * Gets the value of the companyIdentifier property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getCompanyIdentifier() {
        return companyIdentifier;
    }

    /**
     * Sets the value of the companyIdentifier property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setCompanyIdentifier(JAXBElement<String> value) {
        this.companyIdentifier = value;
    }

    /**
     * Gets the value of the compliance property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isCompliance() {
        return compliance;
    }

    /**
     * Sets the value of the compliance property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setCompliance(Boolean value) {
        this.compliance = value;
    }

    /**
     * Gets the value of the customerNumber property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getCustomerNumber() {
        return customerNumber;
    }

    /**
     * Sets the value of the customerNumber property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setCustomerNumber(JAXBElement<String> value) {
        this.customerNumber = value;
    }

    /**
     * Gets the value of the description property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getDescription() {
        return description;
    }

    /**
     * Sets the value of the description property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setDescription(JAXBElement<String> value) {
        this.description = value;
    }

    /**
     * Gets the value of the exemptSaleAmount property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getExemptSaleAmount() {
        return exemptSaleAmount;
    }

    /**
     * Sets the value of the exemptSaleAmount property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setExemptSaleAmount(Double value) {
        this.exemptSaleAmount = value;
    }

    /**
     * Gets the value of the exemptionType property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getExemptionType() {
        return exemptionType;
    }

    /**
     * Sets the value of the exemptionType property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setExemptionType(Integer value) {
        this.exemptionType = value;
    }

    /**
     * Gets the value of the invoiceNumber property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getInvoiceNumber() {
        return invoiceNumber;
    }

    /**
     * Sets the value of the invoiceNumber property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setInvoiceNumber(Long value) {
        this.invoiceNumber = value;
    }

    /**
     * Gets the value of the lines property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getLines() {
        return lines;
    }

    /**
     * Sets the value of the lines property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setLines(Integer value) {
        this.lines = value;
    }

    /**
     * Gets the value of the locations property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getLocations() {
        return locations;
    }

    /**
     * Sets the value of the locations property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setLocations(Integer value) {
        this.locations = value;
    }

    /**
     * Gets the value of the minutes property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getMinutes() {
        return minutes;
    }

    /**
     * Sets the value of the minutes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setMinutes(Double value) {
        this.minutes = value;
    }

    /**
     * Gets the value of the optional property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getOptional() {
        return optional;
    }

    /**
     * Sets the value of the optional property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setOptional(Long value) {
        this.optional = value;
    }

    /**
     * Gets the value of the optional10 property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getOptional10() {
        return optional10;
    }

    /**
     * Sets the value of the optional10 property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setOptional10(Long value) {
        this.optional10 = value;
    }

    /**
     * Gets the value of the optional4 property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getOptional4() {
        return optional4;
    }

    /**
     * Sets the value of the optional4 property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setOptional4(Long value) {
        this.optional4 = value;
    }

    /**
     * Gets the value of the optional5 property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getOptional5() {
        return optional5;
    }

    /**
     * Sets the value of the optional5 property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setOptional5(Long value) {
        this.optional5 = value;
    }

    /**
     * Gets the value of the optional6 property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getOptional6() {
        return optional6;
    }

    /**
     * Sets the value of the optional6 property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setOptional6(Long value) {
        this.optional6 = value;
    }

    /**
     * Gets the value of the optional7 property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getOptional7() {
        return optional7;
    }

    /**
     * Sets the value of the optional7 property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setOptional7(Long value) {
        this.optional7 = value;
    }

    /**
     * Gets the value of the optional8 property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getOptional8() {
        return optional8;
    }

    /**
     * Sets the value of the optional8 property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setOptional8(Long value) {
        this.optional8 = value;
    }

    /**
     * Gets the value of the optional9 property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getOptional9() {
        return optional9;
    }

    /**
     * Sets the value of the optional9 property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setOptional9(Long value) {
        this.optional9 = value;
    }

    /**
     * Gets the value of the optionalAlpha1 property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getOptionalAlpha1() {
        return optionalAlpha1;
    }

    /**
     * Sets the value of the optionalAlpha1 property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setOptionalAlpha1(JAXBElement<String> value) {
        this.optionalAlpha1 = value;
    }

    /**
     * Gets the value of the pCode property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getPCode() {
        return pCode;
    }

    /**
     * Sets the value of the pCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setPCode(Long value) {
        this.pCode = value;
    }

    /**
     * Gets the value of the rate property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getRate() {
        return rate;
    }

    /**
     * Sets the value of the rate property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setRate(Double value) {
        this.rate = value;
    }

    /**
     * Gets the value of the refundUncollect property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getRefundUncollect() {
        return refundUncollect;
    }

    /**
     * Sets the value of the refundUncollect property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setRefundUncollect(Double value) {
        this.refundUncollect = value;
    }

    /**
     * Gets the value of the serviceLevelNumber property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getServiceLevelNumber() {
        return serviceLevelNumber;
    }

    /**
     * Sets the value of the serviceLevelNumber property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setServiceLevelNumber(Long value) {
        this.serviceLevelNumber = value;
    }

    /**
     * Gets the value of the surcharge property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isSurcharge() {
        return surcharge;
    }

    /**
     * Sets the value of the surcharge property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setSurcharge(Boolean value) {
        this.surcharge = value;
    }

    /**
     * Gets the value of the taxAmount property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getTaxAmount() {
        return taxAmount;
    }

    /**
     * Sets the value of the taxAmount property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setTaxAmount(Double value) {
        this.taxAmount = value;
    }

    /**
     * Gets the value of the taxLevel property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Integer }{@code >}
     *     
     */
    public JAXBElement<Integer> getTaxLevel() {
        return taxLevel;
    }

    /**
     * Sets the value of the taxLevel property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Integer }{@code >}
     *     
     */
    public void setTaxLevel(JAXBElement<Integer> value) {
        this.taxLevel = value;
    }

    /**
     * Gets the value of the taxType property.
     * 
     * @return
     *     possible object is
     *     {@link Short }
     *     
     */
    public Short getTaxType() {
        return taxType;
    }

    /**
     * Sets the value of the taxType property.
     * 
     * @param value
     *     allowed object is
     *     {@link Short }
     *     
     */
    public void setTaxType(Short value) {
        this.taxType = value;
    }

    /**
     * Gets the value of the taxableMeasure property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getTaxableMeasure() {
        return taxableMeasure;
    }

    /**
     * Sets the value of the taxableMeasure property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setTaxableMeasure(Double value) {
        this.taxableMeasure = value;
    }

}
