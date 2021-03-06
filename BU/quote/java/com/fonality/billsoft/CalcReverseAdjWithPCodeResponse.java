
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
 *         &lt;element name="CalcReverseAdjWithPCodeResult" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ReverseTaxResults" minOccurs="0"/>
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
    "calcReverseAdjWithPCodeResult"
})
@XmlRootElement(name = "CalcReverseAdjWithPCodeResponse")
public class CalcReverseAdjWithPCodeResponse {

    @XmlElementRef(name = "CalcReverseAdjWithPCodeResult", namespace = "http://tempuri.org/", type = JAXBElement.class, required = false)
    protected JAXBElement<ReverseTaxResults> calcReverseAdjWithPCodeResult;

    /**
     * Gets the value of the calcReverseAdjWithPCodeResult property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}
     *     
     */
    public JAXBElement<ReverseTaxResults> getCalcReverseAdjWithPCodeResult() {
        return calcReverseAdjWithPCodeResult;
    }

    /**
     * Sets the value of the calcReverseAdjWithPCodeResult property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}
     *     
     */
    public void setCalcReverseAdjWithPCodeResult(JAXBElement<ReverseTaxResults> value) {
        this.calcReverseAdjWithPCodeResult = value;
    }

}
