
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
 *         &lt;element name="SAUCalcTaxesWithPCodeResult" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ArrayOfTaxData" minOccurs="0"/>
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
    "sauCalcTaxesWithPCodeResult"
})
@XmlRootElement(name = "SAUCalcTaxesWithPCodeResponse")
public class SAUCalcTaxesWithPCodeResponse {

    @XmlElementRef(name = "SAUCalcTaxesWithPCodeResult", namespace = "http://tempuri.org/", type = JAXBElement.class, required = false)
    protected JAXBElement<ArrayOfTaxData> sauCalcTaxesWithPCodeResult;

    /**
     * Gets the value of the sauCalcTaxesWithPCodeResult property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}
     *     
     */
    public JAXBElement<ArrayOfTaxData> getSAUCalcTaxesWithPCodeResult() {
        return sauCalcTaxesWithPCodeResult;
    }

    /**
     * Sets the value of the sauCalcTaxesWithPCodeResult property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}
     *     
     */
    public void setSAUCalcTaxesWithPCodeResult(JAXBElement<ArrayOfTaxData> value) {
        this.sauCalcTaxesWithPCodeResult = value;
    }

}
