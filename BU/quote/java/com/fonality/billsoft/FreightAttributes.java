
package com.fonality.billsoft;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for FreightAttributes complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="FreightAttributes">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="CommonCarrier" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="PaidToSeller" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="SellerReqShipping" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "FreightAttributes", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", propOrder = {
    "commonCarrier",
    "paidToSeller",
    "sellerReqShipping"
})
public class FreightAttributes {

    @XmlElement(name = "CommonCarrier")
    protected Boolean commonCarrier;
    @XmlElement(name = "PaidToSeller")
    protected Boolean paidToSeller;
    @XmlElement(name = "SellerReqShipping")
    protected Boolean sellerReqShipping;

    /**
     * Gets the value of the commonCarrier property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isCommonCarrier() {
        return commonCarrier;
    }

    /**
     * Sets the value of the commonCarrier property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setCommonCarrier(Boolean value) {
        this.commonCarrier = value;
    }

    /**
     * Gets the value of the paidToSeller property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isPaidToSeller() {
        return paidToSeller;
    }

    /**
     * Sets the value of the paidToSeller property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setPaidToSeller(Boolean value) {
        this.paidToSeller = value;
    }

    /**
     * Gets the value of the sellerReqShipping property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isSellerReqShipping() {
        return sellerReqShipping;
    }

    /**
     * Sets the value of the sellerReqShipping property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setSellerReqShipping(Boolean value) {
        this.sellerReqShipping = value;
    }

}
