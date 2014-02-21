
package com.fonality.billsoft;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for TaxExemption complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="TaxExemption">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="PCode" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
 *         &lt;element name="TaxLevel" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="TaxType" type="{http://www.w3.org/2001/XMLSchema}short" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "TaxExemption", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", propOrder = {
    "pCode",
    "taxLevel",
    "taxType"
})
public class TaxExemption {

    @XmlElement(name = "PCode")
    @XmlSchemaType(name = "unsignedInt")
    protected Long pCode;
    @XmlElement(name = "TaxLevel")
    protected Integer taxLevel;
    @XmlElement(name = "TaxType")
    protected Short taxType;

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

}
