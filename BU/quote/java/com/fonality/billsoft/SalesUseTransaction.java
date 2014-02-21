
package com.fonality.billsoft;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.datatype.XMLGregorianCalendar;


/**
 * <p>Java class for SalesUseTransaction complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="SalesUseTransaction">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="AdjustmentMethod" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="Charge" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="CompanyIdentifier" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CountyExempt" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="CountyPCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="CustomerNumber" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CustomerType" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="Date" type="{http://www.w3.org/2001/XMLSchema}dateTime" minOccurs="0"/>
 *         &lt;element name="ExemptionType" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="Exemptions" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ArrayOfTaxExemption" minOccurs="0"/>
 *         &lt;element name="FOB" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="FederalExempt" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="FederalPCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Incorporated" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="InvoiceNumber" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="LocalExempt" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="LocalPCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional10" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional4" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional5" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional6" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional7" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional8" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Optional9" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="OptionalAlpha1" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="Sale" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="SaleAttributes" type="{http://www.w3.org/2001/XMLSchema}anyType" minOccurs="0"/>
 *         &lt;element name="ServiceType" type="{http://www.w3.org/2001/XMLSchema}short" minOccurs="0"/>
 *         &lt;element name="ShipFromAddress" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ZipAddress" minOccurs="0"/>
 *         &lt;element name="ShipFromFipsCode" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ShipFromPCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="ShipToAddress" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ZipAddress" minOccurs="0"/>
 *         &lt;element name="ShipToFipsCode" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ShipToPCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="StateExempt" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="StatePCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="TransactionType" type="{http://www.w3.org/2001/XMLSchema}short" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SalesUseTransaction", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", propOrder = {
    "adjustmentMethod",
    "charge",
    "companyIdentifier",
    "countyExempt",
    "countyPCode",
    "customerNumber",
    "customerType",
    "date",
    "exemptionType",
    "exemptions",
    "fob",
    "federalExempt",
    "federalPCode",
    "incorporated",
    "invoiceNumber",
    "localExempt",
    "localPCode",
    "optional",
    "optional10",
    "optional4",
    "optional5",
    "optional6",
    "optional7",
    "optional8",
    "optional9",
    "optionalAlpha1",
    "sale",
    "saleAttributes",
    "serviceType",
    "shipFromAddress",
    "shipFromFipsCode",
    "shipFromPCode",
    "shipToAddress",
    "shipToFipsCode",
    "shipToPCode",
    "stateExempt",
    "statePCode",
    "transactionType"
})
public class SalesUseTransaction {

    @XmlElement(name = "AdjustmentMethod")
    protected Integer adjustmentMethod;
    @XmlElement(name = "Charge")
    protected Double charge;
    @XmlElementRef(name = "CompanyIdentifier", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> companyIdentifier;
    @XmlElement(name = "CountyExempt")
    protected Boolean countyExempt;
    @XmlElement(name = "CountyPCode")
    @XmlSchemaType(name = "unsignedInt")
    protected Long countyPCode;
    @XmlElementRef(name = "CustomerNumber", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> customerNumber;
    @XmlElementRef(name = "CustomerType", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Integer> customerType;
    @XmlElement(name = "Date")
    @XmlSchemaType(name = "dateTime")
    protected XMLGregorianCalendar date;
    @XmlElement(name = "ExemptionType")
    protected Integer exemptionType;
    @XmlElementRef(name = "Exemptions", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<ArrayOfTaxExemption> exemptions;
    @XmlElementRef(name = "FOB", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Integer> fob;
    @XmlElement(name = "FederalExempt")
    protected Boolean federalExempt;
    @XmlElement(name = "FederalPCode")
    @XmlSchemaType(name = "unsignedInt")
    protected Long federalPCode;
    @XmlElement(name = "Incorporated")
    protected Boolean incorporated;
    @XmlElement(name = "InvoiceNumber")
    @XmlSchemaType(name = "unsignedInt")
    protected Long invoiceNumber;
    @XmlElement(name = "LocalExempt")
    protected Boolean localExempt;
    @XmlElement(name = "LocalPCode")
    @XmlSchemaType(name = "unsignedInt")
    protected Long localPCode;
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
    @XmlElement(name = "Sale")
    protected Boolean sale;
    @XmlElementRef(name = "SaleAttributes", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Object> saleAttributes;
    @XmlElement(name = "ServiceType")
    protected Short serviceType;
    @XmlElementRef(name = "ShipFromAddress", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<ZipAddress> shipFromAddress;
    @XmlElementRef(name = "ShipFromFipsCode", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> shipFromFipsCode;
    @XmlElementRef(name = "ShipFromPCode", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Long> shipFromPCode;
    @XmlElementRef(name = "ShipToAddress", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<ZipAddress> shipToAddress;
    @XmlElementRef(name = "ShipToFipsCode", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> shipToFipsCode;
    @XmlElementRef(name = "ShipToPCode", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Long> shipToPCode;
    @XmlElement(name = "StateExempt")
    protected Boolean stateExempt;
    @XmlElement(name = "StatePCode")
    @XmlSchemaType(name = "unsignedInt")
    protected Long statePCode;
    @XmlElement(name = "TransactionType")
    protected Short transactionType;

    /**
     * Gets the value of the adjustmentMethod property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getAdjustmentMethod() {
        return adjustmentMethod;
    }

    /**
     * Sets the value of the adjustmentMethod property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setAdjustmentMethod(Integer value) {
        this.adjustmentMethod = value;
    }

    /**
     * Gets the value of the charge property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getCharge() {
        return charge;
    }

    /**
     * Sets the value of the charge property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setCharge(Double value) {
        this.charge = value;
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
     * Gets the value of the countyExempt property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isCountyExempt() {
        return countyExempt;
    }

    /**
     * Sets the value of the countyExempt property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setCountyExempt(Boolean value) {
        this.countyExempt = value;
    }

    /**
     * Gets the value of the countyPCode property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getCountyPCode() {
        return countyPCode;
    }

    /**
     * Sets the value of the countyPCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setCountyPCode(Long value) {
        this.countyPCode = value;
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
     * Gets the value of the customerType property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Integer }{@code >}
     *     
     */
    public JAXBElement<Integer> getCustomerType() {
        return customerType;
    }

    /**
     * Sets the value of the customerType property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Integer }{@code >}
     *     
     */
    public void setCustomerType(JAXBElement<Integer> value) {
        this.customerType = value;
    }

    /**
     * Gets the value of the date property.
     * 
     * @return
     *     possible object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public XMLGregorianCalendar getDate() {
        return date;
    }

    /**
     * Sets the value of the date property.
     * 
     * @param value
     *     allowed object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public void setDate(XMLGregorianCalendar value) {
        this.date = value;
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
     * Gets the value of the exemptions property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfTaxExemption }{@code >}
     *     
     */
    public JAXBElement<ArrayOfTaxExemption> getExemptions() {
        return exemptions;
    }

    /**
     * Sets the value of the exemptions property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfTaxExemption }{@code >}
     *     
     */
    public void setExemptions(JAXBElement<ArrayOfTaxExemption> value) {
        this.exemptions = value;
    }

    /**
     * Gets the value of the fob property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Integer }{@code >}
     *     
     */
    public JAXBElement<Integer> getFOB() {
        return fob;
    }

    /**
     * Sets the value of the fob property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Integer }{@code >}
     *     
     */
    public void setFOB(JAXBElement<Integer> value) {
        this.fob = value;
    }

    /**
     * Gets the value of the federalExempt property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isFederalExempt() {
        return federalExempt;
    }

    /**
     * Sets the value of the federalExempt property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setFederalExempt(Boolean value) {
        this.federalExempt = value;
    }

    /**
     * Gets the value of the federalPCode property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getFederalPCode() {
        return federalPCode;
    }

    /**
     * Sets the value of the federalPCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setFederalPCode(Long value) {
        this.federalPCode = value;
    }

    /**
     * Gets the value of the incorporated property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isIncorporated() {
        return incorporated;
    }

    /**
     * Sets the value of the incorporated property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setIncorporated(Boolean value) {
        this.incorporated = value;
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
     * Gets the value of the localExempt property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isLocalExempt() {
        return localExempt;
    }

    /**
     * Sets the value of the localExempt property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setLocalExempt(Boolean value) {
        this.localExempt = value;
    }

    /**
     * Gets the value of the localPCode property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getLocalPCode() {
        return localPCode;
    }

    /**
     * Sets the value of the localPCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setLocalPCode(Long value) {
        this.localPCode = value;
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
     * Gets the value of the sale property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isSale() {
        return sale;
    }

    /**
     * Sets the value of the sale property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setSale(Boolean value) {
        this.sale = value;
    }

    /**
     * Gets the value of the saleAttributes property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Object }{@code >}
     *     
     */
    public JAXBElement<Object> getSaleAttributes() {
        return saleAttributes;
    }

    /**
     * Sets the value of the saleAttributes property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Object }{@code >}
     *     
     */
    public void setSaleAttributes(JAXBElement<Object> value) {
        this.saleAttributes = value;
    }

    /**
     * Gets the value of the serviceType property.
     * 
     * @return
     *     possible object is
     *     {@link Short }
     *     
     */
    public Short getServiceType() {
        return serviceType;
    }

    /**
     * Sets the value of the serviceType property.
     * 
     * @param value
     *     allowed object is
     *     {@link Short }
     *     
     */
    public void setServiceType(Short value) {
        this.serviceType = value;
    }

    /**
     * Gets the value of the shipFromAddress property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}
     *     
     */
    public JAXBElement<ZipAddress> getShipFromAddress() {
        return shipFromAddress;
    }

    /**
     * Sets the value of the shipFromAddress property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}
     *     
     */
    public void setShipFromAddress(JAXBElement<ZipAddress> value) {
        this.shipFromAddress = value;
    }

    /**
     * Gets the value of the shipFromFipsCode property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getShipFromFipsCode() {
        return shipFromFipsCode;
    }

    /**
     * Sets the value of the shipFromFipsCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setShipFromFipsCode(JAXBElement<String> value) {
        this.shipFromFipsCode = value;
    }

    /**
     * Gets the value of the shipFromPCode property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public JAXBElement<Long> getShipFromPCode() {
        return shipFromPCode;
    }

    /**
     * Sets the value of the shipFromPCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public void setShipFromPCode(JAXBElement<Long> value) {
        this.shipFromPCode = value;
    }

    /**
     * Gets the value of the shipToAddress property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}
     *     
     */
    public JAXBElement<ZipAddress> getShipToAddress() {
        return shipToAddress;
    }

    /**
     * Sets the value of the shipToAddress property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}
     *     
     */
    public void setShipToAddress(JAXBElement<ZipAddress> value) {
        this.shipToAddress = value;
    }

    /**
     * Gets the value of the shipToFipsCode property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getShipToFipsCode() {
        return shipToFipsCode;
    }

    /**
     * Sets the value of the shipToFipsCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setShipToFipsCode(JAXBElement<String> value) {
        this.shipToFipsCode = value;
    }

    /**
     * Gets the value of the shipToPCode property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public JAXBElement<Long> getShipToPCode() {
        return shipToPCode;
    }

    /**
     * Sets the value of the shipToPCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public void setShipToPCode(JAXBElement<Long> value) {
        this.shipToPCode = value;
    }

    /**
     * Gets the value of the stateExempt property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isStateExempt() {
        return stateExempt;
    }

    /**
     * Sets the value of the stateExempt property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setStateExempt(Boolean value) {
        this.stateExempt = value;
    }

    /**
     * Gets the value of the statePCode property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getStatePCode() {
        return statePCode;
    }

    /**
     * Sets the value of the statePCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setStatePCode(Long value) {
        this.statePCode = value;
    }

    /**
     * Gets the value of the transactionType property.
     * 
     * @return
     *     possible object is
     *     {@link Short }
     *     
     */
    public Short getTransactionType() {
        return transactionType;
    }

    /**
     * Sets the value of the transactionType property.
     * 
     * @param value
     *     allowed object is
     *     {@link Short }
     *     
     */
    public void setTransactionType(Short value) {
        this.transactionType = value;
    }

}
