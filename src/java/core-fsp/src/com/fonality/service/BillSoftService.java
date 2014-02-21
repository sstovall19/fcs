package com.fonality.service;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.Properties;

import javax.xml.bind.JAXBElement;
import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.namespace.QName;
import javax.xml.ws.handler.Handler;
import javax.xml.ws.handler.HandlerResolver;
import javax.xml.ws.handler.PortInfo;

import com.billsoft.eztaxasp.ArrayOfTaxData;
import com.billsoft.eztaxasp.EZTaxWebService;
import com.billsoft.eztaxasp.IEZTaxWebService;
import com.billsoft.eztaxasp.TaxData;
import com.billsoft.eztaxasp.Transaction;
import com.billsoft.eztaxasp.ZipAddress;
import com.fonality.bu.entity.EntityAddress;
import com.fonality.bu.entity.TaxTuple;
import com.fonality.util.BillSoftProperties;
import com.fonality.util.EZTaxSOAPHandler;

public class BillSoftService {
	
    private IEZTaxWebService eztax = null;
    private Properties bsProps = null;
    private long pcode;

    public BillSoftService(boolean isTestMode) throws IOException {
 
		bsProps = BillSoftProperties.getProperties(isTestMode);
		
		// Create an instance of the EZTaxWebService
		EZTaxWebService eztaxWebService = new EZTaxWebService();

		// Used for JAXBElement namespaces
		String xmlns = bsProps.getProperty("xmlns");

		// Define the name for the CustonBinding endpoint
		QName customBindingPort = new QName( bsProps.getProperty("namespaceURI"), "BasicHttpBinding_IEZTaxWebService1", "");

		// Add a custom HandlerResolver in order to add the custom headers for the EZTax service credentials
		final String uname = bsProps.getProperty("user");
		final String pass = bsProps.getProperty("pass");
		eztaxWebService.setHandlerResolver(new HandlerResolver() {
			public List<Handler> getHandlerChain(PortInfo portInfo) {
				List<Handler> handlers = new ArrayList<Handler>();
				handlers.add(new EZTaxSOAPHandler(uname, pass));
				return handlers;
			}
		});

		// Instantiate the interface class
		eztax = eztaxWebService.getPort(customBindingPort, IEZTaxWebService.class);   
    }
    
	/**
	 * Convert a DB-mapped address into a BillSoft-compatible Zip Address
	 * @param address The address to convert
	 * @param xmlns The SOAP namespace of the BillSoft service
	 * @return The ZipAddress object
	 */
	private static ZipAddress generateZipAddress(EntityAddress address, String xmlns) {
		ZipAddress zipAddress = new ZipAddress();
		//Country must be a 3-character ISO code
		zipAddress.setCountryISO(new JAXBElement<String>(new QName(xmlns, "CountryISO"), String.class, address.getCountry()));
		//State must be the two-character abbreviation
		zipAddress.setState(new JAXBElement<String>(new QName(xmlns, "State"), String.class, address.getStateProv()));
		zipAddress.setLocality(new JAXBElement<String>(new QName(xmlns, "Locality"), String.class, address.getCity()));
		zipAddress.setZipCode(new JAXBElement<String>(new QName(xmlns, "ZipCode"), String.class, address.getPostal()));
		
		return zipAddress;
	}
	
    /**
     * Convert a FCS DB EntityAddress object into a BillSoft-compatible PCode
     * @param shipAddress The FCS DB address object
     * @return The PCode
      */
    public void generatePCode(EntityAddress shipAddress) {
    	
		// Used for JAXBElement namespaces
		String xmlns = bsProps.getProperty("xmlns");
		
		// Create a ZipAddress object in order to specify a location for the taxing jurisdiction
		ZipAddress address = generateZipAddress(shipAddress, xmlns);
	
		// ZipAddress to PCode conversion
		pcode = (eztax.zipToPCode(address));
	 	
    }
    
	/**
	 * Generate a Transaction object to use with BillSoft's SOAP.
	 * @param pcode
	 * @param transactionId The transaction type for this transaction
	 * @param serviceId The service type for this transaction 
	 * @param xmlns The SOAP namespace of the BillSoft service
	 * @return A new Transaction object
	 * @throws DatatypeConfigurationException
	 */
	private Transaction generateTransaction(long pcode, TaxTuple taxTuple, String xmlns, boolean isLive) throws DatatypeConfigurationException {
		Transaction trans = new Transaction();
		trans.setBusinessClass(new JAXBElement<Integer>(new QName(xmlns, "BusinessClass"), Integer.class, 0)); // 1 = CLEC
		trans.setCharge(taxTuple.getTotalPrice().doubleValue());
		if (isLive)
			trans.setCompanyIdentifier(new JAXBElement<String>(new QName(xmlns, "CompanyIdentifier"), String.class, "FON"));
		else
			trans.setCompanyIdentifier(new JAXBElement<String>(new QName(xmlns, "CompanyIdentifier"), String.class, "")); // Blank for quote or test trans
		trans.setCustomerNumber(new JAXBElement<String>(new QName(xmlns, "CustomerNumber"), String.class, "0"));
		trans.setCustomerType(new JAXBElement<Integer>(new QName(xmlns, "CustomerType"), Integer.class, 1)); // 0 = Residential
		trans.setDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(new GregorianCalendar()));
		trans.setDebit(false); // true is only used for prepaid card transactions
		trans.setFacilitiesBased(false);
		trans.setFranchise(false);
		trans.setIncorporated(false); // Indicate that address is in an incorporated area. Use false for un-incorporated
		trans.setInvoiceNumber((long) 0); // Optional field
		trans.setLifeline(false);
		trans.setLines(0);
		trans.setLocations(0);
//		trans.setMinutes((double) taxTuple.getUsageMinutes());
		trans.setMinutes(0.0);
		trans.setRegulated(false);
		trans.setSale(true); // true = Retail, false = Wholesale
		trans.setServiceClass(new JAXBElement<Integer>(new QName(xmlns, "ServiceClass"), Integer.class, 0)); // 1 = Primary Long Distance
		trans.setServiceType(taxTuple.getServiceType());
		trans.setTransactionType(taxTuple.getTransactionType());

		// No exemptions for this transaction
		trans.setFederalExempt(false);
		trans.setStateExempt(false);
		trans.setCountyExempt(false);
		trans.setLocalExempt(false);

		// Set the bill-to, origination and termination using PCodes
		trans.setBillToPCode(new JAXBElement<Long>(new QName(xmlns, "BillToPCode"), Long.class, pcode));
		trans.setOriginationPCode(new JAXBElement<Long>(new QName(xmlns, "OriginationPCode"), Long.class, pcode));
		trans.setTerminationPCode(new JAXBElement<Long>(new QName(xmlns, "TerminationPCode"), Long.class, pcode));
		
		return trans;
	}
	
	private Transaction generateTransaction(long pcode, TaxTuple taxTuple, String xmlns) throws DatatypeConfigurationException {
		return generateTransaction(pcode, taxTuple, xmlns, false);
	}
	
	private Transaction generateUsageTransaction(TaxTuple taxTuple, String xmlns) throws DatatypeConfigurationException {
		Transaction trans = new Transaction();
		trans.setBusinessClass(new JAXBElement<Integer>(new QName(xmlns, "BusinessClass"), Integer.class, 0)); // 1 = CLEC
		trans.setCharge(taxTuple.getTotalPrice().doubleValue());
		trans.setCompanyIdentifier(new JAXBElement<String>(new QName(xmlns, "CompanyIdentifier"), String.class, bsProps.getProperty("companyID")));
		trans.setCustomerNumber(new JAXBElement<String>(new QName(xmlns, "CustomerNumber"), String.class, "0"));
		trans.setCustomerType(new JAXBElement<Integer>(new QName(xmlns, "CustomerType"), Integer.class, 1)); // 0 = Residential
		trans.setDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(taxTuple.getDate()));
		trans.setDebit(false); // true is only used for prepaid card transactions
		trans.setFacilitiesBased(false);
		trans.setFranchise(false);
		trans.setIncorporated(false); // Indicate that address is in an incorporated area. Use false for un-incorporated
		trans.setInvoiceNumber((long) 0); // Optional field
		trans.setLifeline(false);
		trans.setLines(0);
		trans.setLocations(0);
		trans.setMinutes((double) taxTuple.getUsageMinutes());
		trans.setRegulated(false);
		trans.setSale(true); // true = Retail, false = Wholesale
		trans.setServiceClass(new JAXBElement<Integer>(new QName(xmlns, "ServiceClass"), Integer.class, 0)); // 1 = Primary Long Distance
		trans.setServiceType(taxTuple.getServiceType());
		trans.setTransactionType(taxTuple.getTransactionType());

		// No exemptions for this transaction
		trans.setFederalExempt(false);
		trans.setStateExempt(false);
		trans.setCountyExempt(false);
		trans.setLocalExempt(false);

		long originNPANXX = Long.parseLong(taxTuple.getSourceNpaNxx());
		long destNPANXX = Long.parseLong(taxTuple.getDestNpaNxx());
//		System.out.println("Source = " + originNPANXX + ", Destination = " + destNPANXX);
		// Set the bill-to, origination and termination using NPANXX numbers
        trans.setBillToNpaNxx(new JAXBElement<Long>(new QName(xmlns, "BillToNpaNxx"), Long.class, originNPANXX));
        trans.setOriginationNpaNxx(new JAXBElement<Long>(new QName(xmlns, "OriginationNpaNxx"), Long.class, originNPANXX));
        trans.setTerminationNpaNxx(new JAXBElement<Long>(new QName(xmlns, "TerminationNpaNxx"), Long.class, destNPANXX));		

        return trans;
	}

	private void queryTaxData(long pcode, TaxTuple taxTuple) throws DatatypeConfigurationException, IOException {

		// Used for JAXBElement namespaces
		String xmlns = bsProps.getProperty("xmlns");

		// Create a transaction for processing tax calculations
		Transaction trans = generateTransaction(pcode, taxTuple, xmlns);
		// Calculate taxes (may need a timeout retry here)
		taxTuple.setTaxArray(eztax.calcTaxesWithPCode(trans)); 
	}

	private void queryUsageTaxData(TaxTuple taxTuple) throws DatatypeConfigurationException, IOException {
		// Used for JAXBElement namespaces
		String xmlns = bsProps.getProperty("xmlns");

		// Create a transaction for processing tax calculations
//		Transaction trans = generateUsageTransaction(taxTuple, xmlns);
		Transaction trans = generateTransaction(pcode, taxTuple, xmlns);
		// Calculate taxes (may need a timeout retry here)
//		taxTuple.setTaxArray(eztax.calcTaxesWithNpaNxx(trans)); 
		taxTuple.setTaxArray(eztax.calcTaxesWithPCode(trans)); 
	}
	
	/**
	 * This method performs a single BillSoft taxation transaction. Use only for one-off calculations that will
	 * not take advantage of multithreading
	 * 
	 * @param taxTuple The tax record to be calculated
	 * @throws DatatypeConfigurationException
	 * @throws IOException
	 */
	public void queryTaxData(TaxTuple taxTuple) throws DatatypeConfigurationException, IOException {

		// Used for JAXBElement namespaces
		String xmlns = bsProps.getProperty("xmlns");

		// Create a transaction for processing tax calculations
		Transaction trans = generateTransaction(pcode, taxTuple, xmlns);
		// Calculate taxes (may need a timeout retry here)
		taxTuple.setTaxArray(eztax.calcTaxesWithPCode(trans)); 		
	}
	
	public static String convertPhoneNumToNpaNxx(String phoneNum) {
		String npaNxxStr;
		if (phoneNum.startsWith("1")) {
			npaNxxStr = phoneNum.substring(1, 7);
		} else {
			npaNxxStr = phoneNum.substring(0, 6);
		}
		return npaNxxStr;
	}
	
    /**
     * Sum the total taxes of all parts of a given taxable item
     * @param taxes The array of tax data as generated by the BillSoft EZTax call
     * @return The sum of all tax amounts in the array
     */
	public double calcTaxes(ArrayOfTaxData taxes) {
		double taxTotal = 0.00;
		for (TaxData tax : taxes.getTaxData()) {
//			System.out.println(tax.getDescription().getValue() + ": " + tax.getTaxAmount());
			taxTotal += tax.getTaxAmount();
		}
//		System.out.println("Total for this code = " + taxTotal);
		return taxTotal;
	}

	public class EZTaxThread extends Thread {
		
		private long shipAddress;
		private TaxTuple taxInfo;
		
		public EZTaxThread(long address, TaxTuple taxTuple) {
			shipAddress = address;
			taxInfo = taxTuple;
		}
		
		public EZTaxThread(TaxTuple taxTuple) {
			shipAddress = pcode;
			taxInfo = taxTuple;
		}
		
		public void run() {
			try {
				queryTaxData(shipAddress, taxInfo);
			} catch (DatatypeConfigurationException | IOException e) {
				throw new RuntimeException(e);
			}
		}
	}
	
	public class UsageTaxThread extends Thread {
		
		private String sourceNpaNxx;
		private String destNpaNxx;
		private TaxTuple taxTuple;
		
		public UsageTaxThread(TaxTuple taxTuple) {
			this.taxTuple = taxTuple;
		}
		
		public void run() {
			try {
				queryUsageTaxData(taxTuple);
			} catch (DatatypeConfigurationException | IOException e) {
				throw new RuntimeException(e);
			}
		}
	}

}
