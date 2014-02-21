
package com.fonality.billsoft;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for AddressData complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="AddressData">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="CountryISO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="County" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="Locality" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="State" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="TaxLevel" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="ZipBegin" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ZipEnd" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ZipP4Begin" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ZipP4End" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "AddressData", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", propOrder = {
    "countryISO",
    "county",
    "locality",
    "state",
    "taxLevel",
    "zipBegin",
    "zipEnd",
    "zipP4Begin",
    "zipP4End"
})
public class AddressData {

    @XmlElementRef(name = "CountryISO", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> countryISO;
    @XmlElementRef(name = "County", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> county;
    @XmlElementRef(name = "Locality", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> locality;
    @XmlElementRef(name = "State", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> state;
    @XmlElement(name = "TaxLevel")
    protected Integer taxLevel;
    @XmlElementRef(name = "ZipBegin", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> zipBegin;
    @XmlElementRef(name = "ZipEnd", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> zipEnd;
    @XmlElementRef(name = "ZipP4Begin", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> zipP4Begin;
    @XmlElementRef(name = "ZipP4End", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<String> zipP4End;

    /**
     * Gets the value of the countryISO property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getCountryISO() {
        return countryISO;
    }

    /**
     * Sets the value of the countryISO property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setCountryISO(JAXBElement<String> value) {
        this.countryISO = value;
    }

    /**
     * Gets the value of the county property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getCounty() {
        return county;
    }

    /**
     * Sets the value of the county property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setCounty(JAXBElement<String> value) {
        this.county = value;
    }

    /**
     * Gets the value of the locality property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getLocality() {
        return locality;
    }

    /**
     * Sets the value of the locality property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setLocality(JAXBElement<String> value) {
        this.locality = value;
    }

    /**
     * Gets the value of the state property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getState() {
        return state;
    }

    /**
     * Sets the value of the state property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setState(JAXBElement<String> value) {
        this.state = value;
    }

    /**
     * Gets the value of the taxLevel property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getTaxLevel() {
        return taxLevel;
    }

    /**
     * Sets the value of the taxLevel property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTaxLevel(Integer value) {
        this.taxLevel = value;
    }

    /**
     * Gets the value of the zipBegin property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getZipBegin() {
        return zipBegin;
    }

    /**
     * Sets the value of the zipBegin property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setZipBegin(JAXBElement<String> value) {
        this.zipBegin = value;
    }

    /**
     * Gets the value of the zipEnd property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getZipEnd() {
        return zipEnd;
    }

    /**
     * Sets the value of the zipEnd property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setZipEnd(JAXBElement<String> value) {
        this.zipEnd = value;
    }

    /**
     * Gets the value of the zipP4Begin property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getZipP4Begin() {
        return zipP4Begin;
    }

    /**
     * Sets the value of the zipP4Begin property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setZipP4Begin(JAXBElement<String> value) {
        this.zipP4Begin = value;
    }

    /**
     * Gets the value of the zipP4End property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getZipP4End() {
        return zipP4End;
    }

    /**
     * Sets the value of the zipP4End property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setZipP4End(JAXBElement<String> value) {
        this.zipP4End = value;
    }

}
