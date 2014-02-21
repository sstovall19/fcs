
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
 * <p>Java class for Transaction complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Transaction">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="AdjustmentMethod" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="BillToAddress" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ZipAddress" minOccurs="0"/>
 *         &lt;element name="BillToFipsCode" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="BillToNpaNxx" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="BillToPCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="BusinessClass" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="Charge" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="CompanyIdentifier" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CountyExempt" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="CountyPCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="CustomerNumber" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CustomerType" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="Date" type="{http://www.w3.org/2001/XMLSchema}dateTime" minOccurs="0"/>
 *         &lt;element name="Debit" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="DiscountType" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="ExemptionType" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="Exemptions" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ArrayOfTaxExemption" minOccurs="0"/>
 *         &lt;element name="FacilitiesBased" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="FederalExempt" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="FederalPCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Franchise" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="Incorporated" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="InvoiceNumber" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Lifeline" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="Lines" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="LocalExempt" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="LocalPCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
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
 *         &lt;element name="OriginationAddress" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ZipAddress" minOccurs="0"/>
 *         &lt;element name="OriginationFipsCode" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="OriginationNpaNxx" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="OriginationPCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="Regulated" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="Sale" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="ServiceClass" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="ServiceLevelNumber" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="ServiceType" type="{http://www.w3.org/2001/XMLSchema}short" minOccurs="0"/>
 *         &lt;element name="StateExempt" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="StatePCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="TerminationAddress" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ZipAddress" minOccurs="0"/>
 *         &lt;element name="TerminationFipsCode" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="TerminationNpaNxx" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="TerminationPCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
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
@XmlType(name = "Transaction", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", propOrder = {
    "adjustmentMethod",
    "billToAddress",
    "billToFipsCode",
    "billToNpaNxx",
    "billToPCode",
    "businessClass",
    "charge",
    "companyIdentifier",
    "countyExempt",
    "countyPCode",
    "customerNumber",
    "customerType",
    "date",
    "debit",
    "discountType",
    "exemptionType",
    "exemptions",
    "facilitiesBased",
    "federalExempt",
    "federalPCode",
    "franchise",
    "incorporated",
    "invoiceNumber",
    "lifeline",
    "lines",
    "localExempt",
    "localPCode",
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
    "originationAddress",
    "originationFipsCode",
    "originationNpaNxx",
    "originationPCode",
    "regulated",
    "sale",
    "serviceClass",
    "serviceLevelNumber",
    "serviceType",
    "stateExempt",
    "statePCode",
    "terminationAddress",
    "terminationFipsCode",
    "terminationNpaNxx",
    "terminationPCode",
    "transactionType"
})
public class Transaction {

    @XmlElement(name = "AdjustmentMethod")
    protected Integer adjustmentMethod;
    @XmlElementRef(name = "BillToAddress", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<ZipAddress> billToAddress;
    @XmlElementRef(name = "BillToFipsCode", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> billToFipsCode;
    @XmlElementRef(name = "BillToNpaNxx", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Long> billToNpaNxx;
    @XmlElementRef(name = "BillToPCode", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Long> billToPCode;
    @XmlElementRef(name = "BusinessClass", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Integer> businessClass;
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
    @XmlElement(name = "Debit")
    protected Boolean debit;
    @XmlElement(name = "DiscountType")
    protected Integer discountType;
    @XmlElement(name = "ExemptionType")
    protected Integer exemptionType;
    @XmlElementRef(name = "Exemptions", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<ArrayOfTaxExemption> exemptions;
    @XmlElement(name = "FacilitiesBased")
    protected Boolean facilitiesBased;
    @XmlElement(name = "FederalExempt")
    protected Boolean federalExempt;
    @XmlElement(name = "FederalPCode")
    @XmlSchemaType(name = "unsignedInt")
    protected Long federalPCode;
    @XmlElement(name = "Franchise")
    protected Boolean franchise;
    @XmlElement(name = "Incorporated")
    protected Boolean incorporated;
    @XmlElement(name = "InvoiceNumber")
    @XmlSchemaType(name = "unsignedInt")
    protected Long invoiceNumber;
    @XmlElement(name = "Lifeline")
    protected Boolean lifeline;
    @XmlElement(name = "Lines")
    protected Integer lines;
    @XmlElement(name = "LocalExempt")
    protected Boolean localExempt;
    @XmlElement(name = "LocalPCode")
    @XmlSchemaType(name = "unsignedInt")
    protected Long localPCode;
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
    @XmlElementRef(name = "OriginationAddress", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<ZipAddress> originationAddress;
    @XmlElementRef(name = "OriginationFipsCode", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> originationFipsCode;
    @XmlElementRef(name = "OriginationNpaNxx", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Long> originationNpaNxx;
    @XmlElementRef(name = "OriginationPCode", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Long> originationPCode;
    @XmlElement(name = "Regulated")
    protected Boolean regulated;
    @XmlElement(name = "Sale")
    protected Boolean sale;
    @XmlElementRef(name = "ServiceClass", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Integer> serviceClass;
    @XmlElement(name = "ServiceLevelNumber")
    @XmlSchemaType(name = "unsignedInt")
    protected Long serviceLevelNumber;
    @XmlElement(name = "ServiceType")
    protected Short serviceType;
    @XmlElement(name = "StateExempt")
    protected Boolean stateExempt;
    @XmlElement(name = "StatePCode")
    @XmlSchemaType(name = "unsignedInt")
    protected Long statePCode;
    @XmlElementRef(name = "TerminationAddress", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<ZipAddress> terminationAddress;
    @XmlElementRef(name = "TerminationFipsCode", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> terminationFipsCode;
    @XmlElementRef(name = "TerminationNpaNxx", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Long> terminationNpaNxx;
    @XmlElementRef(name = "TerminationPCode", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<Long> terminationPCode;
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
     * Gets the value of the billToAddress property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}
     *     
     */
    public JAXBElement<ZipAddress> getBillToAddress() {
        return billToAddress;
    }

    /**
     * Sets the value of the billToAddress property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}
     *     
     */
    public void setBillToAddress(JAXBElement<ZipAddress> value) {
        this.billToAddress = value;
    }

    /**
     * Gets the value of the billToFipsCode property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getBillToFipsCode() {
        return billToFipsCode;
    }

    /**
     * Sets the value of the billToFipsCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setBillToFipsCode(JAXBElement<String> value) {
        this.billToFipsCode = value;
    }

    /**
     * Gets the value of the billToNpaNxx property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public JAXBElement<Long> getBillToNpaNxx() {
        return billToNpaNxx;
    }

    /**
     * Sets the value of the billToNpaNxx property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public void setBillToNpaNxx(JAXBElement<Long> value) {
        this.billToNpaNxx = value;
    }

    /**
     * Gets the value of the billToPCode property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public JAXBElement<Long> getBillToPCode() {
        return billToPCode;
    }

    /**
     * Sets the value of the billToPCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public void setBillToPCode(JAXBElement<Long> value) {
        this.billToPCode = value;
    }

    /**
     * Gets the value of the businessClass property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Integer }{@code >}
     *     
     */
    public JAXBElement<Integer> getBusinessClass() {
        return businessClass;
    }

    /**
     * Sets the value of the businessClass property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Integer }{@code >}
     *     
     */
    public void setBusinessClass(JAXBElement<Integer> value) {
        this.businessClass = value;
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
     * Gets the value of the debit property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isDebit() {
        return debit;
    }

    /**
     * Sets the value of the debit property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setDebit(Boolean value) {
        this.debit = value;
    }

    /**
     * Gets the value of the discountType property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDiscountType() {
        return discountType;
    }

    /**
     * Sets the value of the discountType property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDiscountType(Integer value) {
        this.discountType = value;
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
     * Gets the value of the facilitiesBased property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isFacilitiesBased() {
        return facilitiesBased;
    }

    /**
     * Sets the value of the facilitiesBased property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setFacilitiesBased(Boolean value) {
        this.facilitiesBased = value;
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
     * Gets the value of the franchise property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isFranchise() {
        return franchise;
    }

    /**
     * Sets the value of the franchise property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setFranchise(Boolean value) {
        this.franchise = value;
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
     * Gets the value of the lifeline property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isLifeline() {
        return lifeline;
    }

    /**
     * Sets the value of the lifeline property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setLifeline(Boolean value) {
        this.lifeline = value;
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
     * Gets the value of the originationAddress property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}
     *     
     */
    public JAXBElement<ZipAddress> getOriginationAddress() {
        return originationAddress;
    }

    /**
     * Sets the value of the originationAddress property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}
     *     
     */
    public void setOriginationAddress(JAXBElement<ZipAddress> value) {
        this.originationAddress = value;
    }

    /**
     * Gets the value of the originationFipsCode property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getOriginationFipsCode() {
        return originationFipsCode;
    }

    /**
     * Sets the value of the originationFipsCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setOriginationFipsCode(JAXBElement<String> value) {
        this.originationFipsCode = value;
    }

    /**
     * Gets the value of the originationNpaNxx property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public JAXBElement<Long> getOriginationNpaNxx() {
        return originationNpaNxx;
    }

    /**
     * Sets the value of the originationNpaNxx property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public void setOriginationNpaNxx(JAXBElement<Long> value) {
        this.originationNpaNxx = value;
    }

    /**
     * Gets the value of the originationPCode property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public JAXBElement<Long> getOriginationPCode() {
        return originationPCode;
    }

    /**
     * Sets the value of the originationPCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public void setOriginationPCode(JAXBElement<Long> value) {
        this.originationPCode = value;
    }

    /**
     * Gets the value of the regulated property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isRegulated() {
        return regulated;
    }

    /**
     * Sets the value of the regulated property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setRegulated(Boolean value) {
        this.regulated = value;
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
     * Gets the value of the serviceClass property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Integer }{@code >}
     *     
     */
    public JAXBElement<Integer> getServiceClass() {
        return serviceClass;
    }

    /**
     * Sets the value of the serviceClass property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Integer }{@code >}
     *     
     */
    public void setServiceClass(JAXBElement<Integer> value) {
        this.serviceClass = value;
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
     * Gets the value of the terminationAddress property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}
     *     
     */
    public JAXBElement<ZipAddress> getTerminationAddress() {
        return terminationAddress;
    }

    /**
     * Sets the value of the terminationAddress property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}
     *     
     */
    public void setTerminationAddress(JAXBElement<ZipAddress> value) {
        this.terminationAddress = value;
    }

    /**
     * Gets the value of the terminationFipsCode property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getTerminationFipsCode() {
        return terminationFipsCode;
    }

    /**
     * Sets the value of the terminationFipsCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setTerminationFipsCode(JAXBElement<String> value) {
        this.terminationFipsCode = value;
    }

    /**
     * Gets the value of the terminationNpaNxx property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public JAXBElement<Long> getTerminationNpaNxx() {
        return terminationNpaNxx;
    }

    /**
     * Sets the value of the terminationNpaNxx property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public void setTerminationNpaNxx(JAXBElement<Long> value) {
        this.terminationNpaNxx = value;
    }

    /**
     * Gets the value of the terminationPCode property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public JAXBElement<Long> getTerminationPCode() {
        return terminationPCode;
    }

    /**
     * Sets the value of the terminationPCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link Long }{@code >}
     *     
     */
    public void setTerminationPCode(JAXBElement<Long> value) {
        this.terminationPCode = value;
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
