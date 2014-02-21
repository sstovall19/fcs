
package com.fonality.billsoft;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ArrayOfCustomerTaxData complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ArrayOfCustomerTaxData">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="CustomerTaxData" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}CustomerTaxData" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ArrayOfCustomerTaxData", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", propOrder = {
    "customerTaxData"
})
public class ArrayOfCustomerTaxData {

    @XmlElement(name = "CustomerTaxData", nillable = true)
    protected List<CustomerTaxData> customerTaxData;

    /**
     * Gets the value of the customerTaxData property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the customerTaxData property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCustomerTaxData().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CustomerTaxData }
     * 
     * 
     */
    public List<CustomerTaxData> getCustomerTaxData() {
        if (customerTaxData == null) {
            customerTaxData = new ArrayList<CustomerTaxData>();
        }
        return this.customerTaxData;
    }

}
