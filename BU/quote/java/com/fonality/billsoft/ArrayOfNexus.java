
package com.fonality.billsoft;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ArrayOfNexus complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ArrayOfNexus">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="Nexus" type="{http://schemas.datacontract.org/2004/07/EZTaxWebService}Nexus" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ArrayOfNexus", namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", propOrder = {
    "nexus"
})
public class ArrayOfNexus {

    @XmlElement(name = "Nexus", nillable = true)
    protected List<Nexus> nexus;

    /**
     * Gets the value of the nexus property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the nexus property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getNexus().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Nexus }
     * 
     * 
     */
    public List<Nexus> getNexus() {
        if (nexus == null) {
            nexus = new ArrayList<Nexus>();
        }
        return this.nexus;
    }

}
