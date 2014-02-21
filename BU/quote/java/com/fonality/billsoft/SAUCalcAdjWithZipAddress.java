
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
 *         &lt;element name="anAdjustment" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}SalesUseTransaction" minOccurs="0"/>
 *         &lt;element name="aNexusList" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ArrayOfNexus" minOccurs="0"/>
 *         &lt;element name="anExclusionList" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ArrayOfExclusion" minOccurs="0"/>
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
    "anAdjustment",
    "aNexusList",
    "anExclusionList"
})
@XmlRootElement(name = "SAUCalcAdjWithZipAddress")
public class SAUCalcAdjWithZipAddress {

    @XmlElementRef(name = "anAdjustment", namespace = "http://tempuri.org/", type = JAXBElement.class, required = false)
    protected JAXBElement<SalesUseTransaction> anAdjustment;
    @XmlElementRef(name = "aNexusList", namespace = "http://tempuri.org/", type = JAXBElement.class, required = false)
    protected JAXBElement<ArrayOfNexus> aNexusList;
    @XmlElementRef(name = "anExclusionList", namespace = "http://tempuri.org/", type = JAXBElement.class, required = false)
    protected JAXBElement<ArrayOfExclusion> anExclusionList;

    /**
     * Gets the value of the anAdjustment property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}
     *     
     */
    public JAXBElement<SalesUseTransaction> getAnAdjustment() {
        return anAdjustment;
    }

    /**
     * Sets the value of the anAdjustment property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}
     *     
     */
    public void setAnAdjustment(JAXBElement<SalesUseTransaction> value) {
        this.anAdjustment = value;
    }

    /**
     * Gets the value of the aNexusList property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}
     *     
     */
    public JAXBElement<ArrayOfNexus> getANexusList() {
        return aNexusList;
    }

    /**
     * Sets the value of the aNexusList property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}
     *     
     */
    public void setANexusList(JAXBElement<ArrayOfNexus> value) {
        this.aNexusList = value;
    }

    /**
     * Gets the value of the anExclusionList property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}
     *     
     */
    public JAXBElement<ArrayOfExclusion> getAnExclusionList() {
        return anExclusionList;
    }

    /**
     * Sets the value of the anExclusionList property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}
     *     
     */
    public void setAnExclusionList(JAXBElement<ArrayOfExclusion> value) {
        this.anExclusionList = value;
    }

}
