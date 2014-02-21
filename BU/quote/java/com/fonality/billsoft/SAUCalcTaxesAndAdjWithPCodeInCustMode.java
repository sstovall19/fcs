
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
 *         &lt;element name="aTransactionList" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ArrayOfSalesUseTransaction" minOccurs="0"/>
 *         &lt;element name="anAdjustmentList" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}ArrayOfSalesUseTransaction" minOccurs="0"/>
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
    "aTransactionList",
    "anAdjustmentList",
    "aNexusList",
    "anExclusionList"
})
@XmlRootElement(name = "SAUCalcTaxesAndAdjWithPCodeInCustMode")
public class SAUCalcTaxesAndAdjWithPCodeInCustMode {

    @XmlElementRef(name = "aTransactionList", namespace = "http://tempuri.org/", type = JAXBElement.class, required = false)
    protected JAXBElement<ArrayOfSalesUseTransaction> aTransactionList;
    @XmlElementRef(name = "anAdjustmentList", namespace = "http://tempuri.org/", type = JAXBElement.class, required = false)
    protected JAXBElement<ArrayOfSalesUseTransaction> anAdjustmentList;
    @XmlElementRef(name = "aNexusList", namespace = "http://tempuri.org/", type = JAXBElement.class, required = false)
    protected JAXBElement<ArrayOfNexus> aNexusList;
    @XmlElementRef(name = "anExclusionList", namespace = "http://tempuri.org/", type = JAXBElement.class, required = false)
    protected JAXBElement<ArrayOfExclusion> anExclusionList;

    /**
     * Gets the value of the aTransactionList property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfSalesUseTransaction }{@code >}
     *     
     */
    public JAXBElement<ArrayOfSalesUseTransaction> getATransactionList() {
        return aTransactionList;
    }

    /**
     * Sets the value of the aTransactionList property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfSalesUseTransaction }{@code >}
     *     
     */
    public void setATransactionList(JAXBElement<ArrayOfSalesUseTransaction> value) {
        this.aTransactionList = value;
    }

    /**
     * Gets the value of the anAdjustmentList property.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfSalesUseTransaction }{@code >}
     *     
     */
    public JAXBElement<ArrayOfSalesUseTransaction> getAnAdjustmentList() {
        return anAdjustmentList;
    }

    /**
     * Sets the value of the anAdjustmentList property.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link ArrayOfSalesUseTransaction }{@code >}
     *     
     */
    public void setAnAdjustmentList(JAXBElement<ArrayOfSalesUseTransaction> value) {
        this.anAdjustmentList = value;
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
