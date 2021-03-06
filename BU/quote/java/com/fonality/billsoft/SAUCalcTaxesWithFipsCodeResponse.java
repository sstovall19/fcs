
package com.fonality.billsoft;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="SAUCalcTaxesWithFipsCodeResult" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ArrayOfTaxData" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "sauCalcTaxesWithFipsCodeResult"
})
@XmlRootElement(name = "SAUCalcTaxesWithFipsCodeResponse")
public class SAUCalcTaxesWithFipsCodeResponse {

    @XmlElementRef(name = "SAUCalcTaxesWithFipsCodeResult", namespace = "http://tempuri.org/", type = JAXBElement.class, required = false)
    protected JAXBElement<ArrayOfTaxData> sauCalcTaxesWithFipsCodeResult;

    /**
     * Gets the value of the sauCalcTaxesWithFipsCodeResult property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}
     *     
     */
    public JAXBElement<ArrayOfTaxData> getSAUCalcTaxesWithFipsCodeResult() {
        return sauCalcTaxesWithFipsCodeResult;
    }

    /**
     * Sets the value of the sauCalcTaxesWithFipsCodeResult property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}
     *     
     */
    public void setSAUCalcTaxesWithFipsCodeResult(JAXBElement<ArrayOfTaxData> value) {
        this.sauCalcTaxesWithFipsCodeResult = value;
    }

}
