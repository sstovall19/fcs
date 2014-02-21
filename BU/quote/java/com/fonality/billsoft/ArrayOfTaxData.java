
package com.fonality.billsoft;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ArrayOfTaxData complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ArrayOfTaxData">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="TaxData" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}TaxData" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ArrayOfTaxData", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", propOrder = {
    "taxData"
})
public class ArrayOfTaxData {

    @XmlElement(name = "TaxData", nillable = true)
    protected List<TaxData> taxData;

    /**
     * Gets the value of the taxData property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the taxData property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getTaxData().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link TaxData }
     * 
     * 
     */
    public List<TaxData> getTaxData() {
        if (taxData == null) {
            taxData = new ArrayList<TaxData>();
        }
        return this.taxData;
    }

}
