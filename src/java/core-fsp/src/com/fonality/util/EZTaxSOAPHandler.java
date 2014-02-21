package com.fonality.util;

import java.util.Set;
import java.util.TreeSet;
import javax.xml.namespace.QName;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPFactory;
import javax.xml.soap.SOAPHeader;
import javax.xml.soap.SOAPMessage;
import javax.xml.ws.handler.MessageContext;
import javax.xml.ws.handler.soap.SOAPHandler;
import javax.xml.ws.handler.soap.SOAPMessageContext;

/**
 * This class is used to add the user's credentials in custom SOAP headers for every 
 * request made to the EZTax Web Service.
 */
public class EZTaxSOAPHandler implements SOAPHandler<SOAPMessageContext> {
	
	private String userName = "";
	private String password = "";
	
	/*
	 * Constructor.
	 */
	public EZTaxSOAPHandler(String userName, String password) {
		this.userName = userName;
		this.password = password;
	}
	
	/**
	 * 
	 * @see javax.xml.ws.handler.soap.SOAPHandler#getHeaders()
	 */
	public Set<QName> getHeaders() {
		return new TreeSet();
	}
	
	/**
	 * Adds the custom SOAP headers to the message
	 * @see javax.xml.ws.handler.Handler#handleMessage(javax.xml.ws.handler.MessageContext)
	 */
	public boolean handleMessage(SOAPMessageContext context) {
		Boolean outboundProperty = (Boolean) context.get(MessageContext.MESSAGE_OUTBOUND_PROPERTY);
		
		if (outboundProperty.booleanValue()) {
			try {
				SOAPEnvelope envelope = context.getMessage().getSOAPPart().getEnvelope();
				SOAPFactory factory = SOAPFactory.newInstance();
				String prefix = "ez";
				String uri = "http://eztaxasp.billsoft.com/eztaxwebservice";
				
				SOAPElement userElem = factory.createElement("UserName", prefix, uri);
				userElem.addTextNode(userName);
				
				SOAPElement passElem = factory.createElement("Password", prefix, uri);
				passElem.addTextNode(password);
				
				SOAPHeader header = envelope.addHeader();
				header.addChildElement(userElem);
				header.addChildElement(passElem);
			} 
			catch (Exception e) {
				System.err.println("Exception in handler: " + e);
			}
		}
		
		return true;
	}
	
	/**
	 * 
	 * @see javax.xml.ws.handler.Handler#handleFault(javax.xml.ws.handler.MessageContext)
	 */
	public boolean handleFault(SOAPMessageContext context) {
		try {
            SOAPMessage msg = ((SOAPMessageContext) context).getMessage();
            if (context.getMessage().getSOAPBody().getFault() != null) {
                String detailName = null;
                try {
                    detailName = context.getMessage().getSOAPBody().getFault().getFaultString();//.getDetail().getFirstChild().getLocalName();
                    System.err.println("SOAP fault: "+detailName);
                } catch(Exception e) {}
            }
          } catch (SOAPException e) {
            e.printStackTrace();
          }		
		//throw new UnsupportedOperationException("Unsupported operation.");
		return true;
	}
	
	/**
	 * 
	 * @see javax.xml.ws.handler.Handler#close(javax.xml.ws.handler.MessageContext)
	 */
	public void close(MessageContext context) {
	}
}
