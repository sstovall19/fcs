
package com.fonality.billsoft;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for FactoryWarrantyAttributes complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="FactoryWarrantyAttributes">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="AgreementType" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="SellerRequired" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "FactoryWarrantyAttributes", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", propOrder = {
    "agreementType",
    "sellerRequired"
})
public class FactoryWarrantyAttributes {

    @XmlElement(name = "AgreementType")
    protected Integer agreementType;
    @XmlElement(name = "SellerRequired")
    protected Boolean sellerRequired;

    /**
     * Gets the value of the agreementType property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getAgreementType() {
        return agreementType;
    }

    /**
     * Sets the value of the agreementType property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setAgreementType(Integer value) {
        this.agreementType = value;
    }

    /**
     * Gets the value of the sellerRequired property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isSellerRequired() {
        return sellerRequired;
    }

    /**
     * Sets the value of the sellerRequired property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setSellerRequired(Boolean value) {
        this.sellerRequired = value;
    }

}
