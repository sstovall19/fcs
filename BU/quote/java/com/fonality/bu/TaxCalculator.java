package com.fonality.bu;


import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.xml.namespace.QName;
import javax.xml.soap.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.ParameterException;
import com.fonality.billsoft.EZTaxWebService;
import com.fonality.billsoft.IEZTaxWebService;
import com.fonality.bu.entity.Input;
import com.fonality.bu.entity.Bundle;
import com.fonality.bu.entity.Order_Group;
import com.fonality.bu.entity.Shipping;
import com.fonality.util.Base64;
import com.fonality.util.CommandParams;
import com.fonality.util.SOAPBuilder;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class TaxCalculator {

	/**
	 * @param args
	 * @throws IOException 
	 */
	public static void main(String[] args) throws IOException {

		//Set up command-line arguments parser
		CommandParams cp = new CommandParams();
		JCommander parser = new JCommander(cp);
		try {
			parser.parse(args);
			//Check for rollback
			if (cp.rollback) {
				System.err.println("Asked to Roll Back but this BU does not do anything that can be rolled back.");
				System.exit(1);
			}
		} catch (ParameterException pe) {
			System.err.println("Improper usage");
			System.exit(0);
		}
		
		//This is not a rollback, so continue with deserialization of input data
		Gson gson = new GsonBuilder().setPrettyPrinting().create();
		String serializedOutput = "Fail";

		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));//We should define an encoding here
	    String s;
		StringBuilder inputBuf = new StringBuilder();
	    while ((s = in.readLine()) != null)
			inputBuf.append(s);
		String fullInput = inputBuf.toString();
//		System.out.println(fullInput);
		Input inputObj = gson.fromJson(fullInput, Input.class);
		calculateAndInsertTaxRates(inputObj);
		serializedOutput = gson.toJson(inputObj);
		//This is not just a test output line. This generates the expected output of the BU
		System.out.println(serializedOutput);
		//sendSOAP();
	    // An empty line or Ctrl-Z terminates the program
		System.exit(1);
	 }	
	
	private static void calculateAndInsertTaxRates(Input inputObj) {
		double taxTotal = 0.0;
		for(Order_Group server : inputObj.getOrder_group()) {
			Shipping address = server.getShipping();
			if (address.getCountry().equalsIgnoreCase("United States")) {
				String state = address.getState();
				String zip = address.getPostal();
			}
			for(Bundle item : server.getBundle()) {
				//Calculate tax on item
				taxTotal += 5;
			}
		}
		
		//Add tax total to total price
	}
	
	private static void sendSOAP() {
		
        String destination = "https://eztaxasp.billsoft.com/EZTaxWebService/EZTaxWebService.svc";
		try {
			// First create the connection
	        SOAPConnection connection = SOAPBuilder.getNewConnection();
	
	        // Next, create the actual message
	        SOAPMessage message = SOAPBuilder.getNewMessage();
	
	        SOAPEnvelope envelope = SOAPBuilder.getEnvelope(message);
	        //Set security headers
	        SOAPBuilder.setBillSoftSecurityHeaders(message, envelope);
	        // Create and populate the body
            SOAPBody body = envelope.getBody();

            // Create the main element and namespace
            QName bodyName = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "EZTaxWebService", "a");
//            SOAPElement bodyElement = body.addChildElement(envelope.createName(operation, "ns1", "urn:"+urn));		
           // body.addBodyElement(bodyName);
            message.saveChanges();
            try {
				message.writeTo(System.out);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            SOAPMessage reply = connection.call(message, destination);
            SOAPBody replyBody = reply.getSOAPBody();
            if (replyBody.hasFault()) {
            	System.out.println();
            	System.out.println(replyBody.getFault().getFaultString());
            }
            try {
            	System.out.println();
            	reply.writeTo(System.out);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

        } catch (SOAPException se) {
			//
		}
	}
	
	private static void sendSOAP2() {
		EZTaxWebService ezTaxService = new EZTaxWebService();
		IEZTaxWebService ezTax = ezTaxService.getBasicHttpBindingIEZTaxWebService();
		
		//ezTax.
	}
	
}
