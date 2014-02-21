
package com.fonality.billsoft;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ReverseTaxResults complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ReverseTaxResults">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="BaseSaleAmount" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="Taxes" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ArrayOfTaxData" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ReverseTaxResults", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", propOrder = {
    "baseSaleAmount",
    "taxes"
})
public class ReverseTaxResults {

    @XmlElement(name = "BaseSaleAmount")
    protected Double baseSaleAmount;
    @XmlElementRef(name = "Taxes", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", type = JAXBElement.class, required = false)
    protected JAXBElement<ArrayOfTaxData> taxes;

    /**
     * Gets the value of the baseSaleAmount property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getBaseSaleAmount() {
        return baseSaleAmount;
    }

    /**
     * Sets the value of the baseSaleAmount property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setBaseSaleAmount(Double value) {
        this.baseSaleAmount = value;
    }

    /**
     * Gets the value of the taxes property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}
     *     
     */
    public JAXBElement<ArrayOfTaxData> getTaxes() {
        return taxes;
    }

    /**
     * Sets the value of the taxes property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}
     *     
     */
    public void setTaxes(JAXBElement<ArrayOfTaxData> value) {
        this.taxes = value;
    }

}
