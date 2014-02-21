
package com.fonality.billsoft;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ArrayOfSalesUseTransaction complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ArrayOfSalesUseTransaction">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="SalesUseTransaction" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}SalesUseTransaction" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ArrayOfSalesUseTransaction", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", propOrder = {
    "salesUseTransaction"
})
public class ArrayOfSalesUseTransaction {

    @XmlElement(name = "SalesUseTransaction", nillable = true)
    protected List<SalesUseTransaction> salesUseTransaction;

    /**
     * Gets the value of the salesUseTransaction property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the salesUseTransaction property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getSalesUseTransaction().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link SalesUseTransaction }
     * 
     * 
     */
    public List<SalesUseTransaction> getSalesUseTransaction() {
        if (salesUseTransaction == null) {
            salesUseTransaction = new ArrayList<SalesUseTransaction>();
        }
        return this.salesUseTransaction;
    }

}
