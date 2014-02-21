package com.fonality.util;

import java.text.SimpleDateFormat;
import java.util.Date;

import javax.xml.soap.MessageFactory;
import javax.xml.soap.Name;
import javax.xml.soap.SOAPConnection;
import javax.xml.soap.SOAPConnectionFactory;
import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPHeader;
import javax.xml.soap.SOAPHeaderElement;
import javax.xml.soap.SOAPMessage;
import javax.xml.soap.SOAPPart;

public class SOAPBuilder {

	public static SOAPConnection getNewConnection() throws UnsupportedOperationException, SOAPException {
        SOAPConnectionFactory soapConnFactory = SOAPConnectionFactory.newInstance();
        SOAPConnection connection = soapConnFactory.createConnection();
        return connection;
	}
	
	public static SOAPMessage getNewMessage() throws SOAPException {
        MessageFactory messageFactory = MessageFactory.newInstance();
        SOAPMessage message = messageFactory.createMessage();

        return message;
	}
	
	public static SOAPEnvelope getEnvelope(SOAPMessage message) throws SOAPException {
        SOAPPart soapPart = message.getSOAPPart();
        SOAPEnvelope envelope = soapPart.getEnvelope();	
        envelope.setEncodingStyle("http://schemas.xmlsoap.org/soap/encoding/");

        return envelope;
	}
	
	public static void setBillSoftSecurityHeaders(SOAPMessage message, SOAPEnvelope envelope) throws SOAPException
	{
		//Name space constants
		final String NS_PREFIX_O = "o";
		final String NS_URI_O = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd";
		final String NS_PREFIX_U = "u";
		final String NS_URI_U = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd";
		
		final String PASSWORD_URL = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText";
		
		String username = "billsoft_fon";
        String password = "F0n*b1L!";
//        String authorization = Base64.encodeToString((username+":"+password).getBytes(), true);
//        MimeHeaders hd = message.getMimeHeaders();
//        hd.addHeader("Authorization", "Basic " + authorization);
        
        // Create "Security" root header
        SOAPHeader header = message.getSOAPHeader();
        if (header == null)
            header = envelope.addHeader();
        SOAPHeaderElement securityRoot = header.addHeaderElement(envelope.createName("Security", NS_PREFIX_O, NS_URI_O));
        securityRoot.setMustUnderstand(true);
        
        //Create "Username" and "Password" leaf headers
        SOAPHeaderElement uname = header.addHeaderElement(envelope.createName("Username",NS_PREFIX_O, NS_URI_O));
        uname.addTextNode(username);
        SOAPHeaderElement pword = header.addHeaderElement(envelope.createName("Password",NS_PREFIX_O, NS_URI_O));
        Name pwordType = envelope.createName("Type");
        pword.addAttribute(pwordType, "PASSWORD_URL");
        pword.addTextNode(password);
        //Create "UsernameToken" header, parent of "Username" and "Password"
        SOAPHeaderElement ut = header.addHeaderElement(envelope.createName("UsernameToken",NS_PREFIX_O, NS_URI_O));
        ut.addChildElement(uname);
        ut.addChildElement(pword);
        
        //Create "Created" and "Expires" leaf headers
        SOAPHeaderElement created = header.addHeaderElement(envelope.createName("Created",NS_PREFIX_U,NS_URI_U));
        Date now = new Date();
        //now.
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ"); 
        String dateStr = dateFormat.format(now);
        created.addTextNode(dateStr);
        SOAPHeaderElement expires = header.addHeaderElement(envelope.createName("Expires",NS_PREFIX_U,NS_URI_U));
        now.setTime(now.getTime() + 600);
        dateStr = dateFormat.format(now);
        expires.addTextNode(dateStr);
        //Create "Timestamp" header, parent of "Created" and "Expires"
        SOAPHeaderElement timestamp = header.addHeaderElement(envelope.createName("Timestamp",NS_PREFIX_U,NS_URI_U));
        Name id = envelope.createName("Id",NS_PREFIX_U, NS_URI_U);
        timestamp.addAttribute(id, "_0");
        timestamp.addChildElement(created);
        timestamp.addChildElement(expires);
        
        //Add "Timestamp" and "UsernameToken" headers as children of "Security" header
        securityRoot.addChildElement(timestamp);
        securityRoot.addChildElement(ut);
        
        
	}

}
