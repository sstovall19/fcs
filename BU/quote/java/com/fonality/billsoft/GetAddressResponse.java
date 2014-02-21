
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
 *         &lt;element name="GetAddressResult" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ArrayOfAddressData" minOccurs="0"/>
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
    "getAddressResult"
})
@XmlRootElement(name = "GetAddressResponse")
public class GetAddressResponse {

    @XmlElementRef(name = "GetAddressResult", namespace = "http://tempuri.org/", type = JAXBElement.class, required = false)
    protected JAXBElement<ArrayOfAddressData> getAddressResult;

    /**
     * Gets the value of the getAddressResult property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfAddressData }{@code >}
     *     
     */
    public JAXBElement<ArrayOfAddressData> getGetAddressResult() {
        return getAddressResult;
    }

    /**
     * Sets the value of the getAddressResult property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfAddressData }{@code >}
     *     
     */
    public void setGetAddressResult(JAXBElement<ArrayOfAddressData> value) {
        this.getAddressResult = value;
    }

}
