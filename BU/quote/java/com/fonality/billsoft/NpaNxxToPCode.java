
package com.fonality.billsoft;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
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
 *         &lt;element name="anNpaNxx" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" minOccurs="0"/>
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
    "anNpaNxx"
})
@XmlRootElement(name = "NpaNxxToPCode")
public class NpaNxxToPCode {

    @XmlSchemaType(name = "unsignedInt")
    protected Long anNpaNxx;

    /**
     * Gets the value of the anNpaNxx property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getAnNpaNxx() {
        return anNpaNxx;
    }

    /**
     * Sets the value of the anNpaNxx property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setAnNpaNxx(Long value) {
        this.anNpaNxx = value;
    }

}
