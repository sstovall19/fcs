package com.fonality.suretax;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.conn.ConnectTimeoutException;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;

import com.fonality.suretax.entity.GenericRequest;
import com.fonality.suretax.entity.GenericResponse;
import com.fonality.suretax.entity.Group;
import com.fonality.suretax.entity.Item;
import com.fonality.suretax.entity.ItemMessage;
import com.fonality.suretax.entity.Tax;
import com.fonality.util.FSPConstants;
import com.fonality.util.ObjectUtils;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

/**
 * SureTaxClient is a representation of a SureTax API call, containing data corresponding to both 
 * the inputs and outputs of a SureTax API call. 
 * 
 * Typical workflow for a SureTaxClient is as follows:
 *  - Create new SureTaxClient object
 *  - Set jurisdiction
 *  - Create line item list with successive calls to addLineItem methods
 *  - Execute transaction with call to submitRequest
 *  - Process results
 *  
 * @author Fonality
 *
 */
public class SureTaxClient {

	private static final String DEFAULT_REQUEST_API = "https://testapi.taxrating.net/Services/V01/SureTax.asmx/PostRequest";
	private static final String REGULATORY_CODE_DEFAULT = "99";
	private static final String REGULATORY_CODE_VOIP = "03";
	private static final String TAX_SITUS_RULE_ZIP = "04";
	private static final String TAX_SITUS_RULE_ZIP_PLUS4 = "05";
	private static final String NON_SURETAX_ERROR_CODE = "0000";
	
	private static final int MAX_ATTEMPTS_DEFAULT = 5;
	private static final long RETRY_DELAY_MIN_DEFAULT = 1000;
	private static final long RETRY_DELAY_MAX_DEFAULT = 30000;
	
	private static final Logger LOGGER = Logger.getLogger(SureTaxClient.class.getName());	
	
	//HTTP Settings
	private int maxAttempts = MAX_ATTEMPTS_DEFAULT;
	private long retryDelayMin = RETRY_DELAY_MIN_DEFAULT; //Milliseconds
	private long retryDelayMax = RETRY_DELAY_MAX_DEFAULT; //Milliseconds
	private int connectTimeoutMillis = 0;
	
	//Request components
	private GenericRequest invoice;
	private List<Item> itemList;
	private String clientNumber;
	private String validationKey;
	private String serviceURL;
	private int lineNumber = 1;
	private BigDecimal totalRevenue = new BigDecimal(0.00);
	private String zipcode;
	private String plus4;
	private String taxSitusRuleCode;
	private boolean isTestMode = false;
	
	//Response components
	private GenericResponse apiResponse;
	private boolean isSuccess;
	private String responseCode;
	private String responseMessage;
	private BigDecimal totalTax;
	private List<Tax> taxList;
	
	
	/**
	 * Constructs a SureTaxLient with the given client number and validation key, and a default request api
	 * @param clientNumber Client ID number provided by SureTax
	 * @param validationKey Client validation key provided by SureTax
	 */
	public SureTaxClient(String clientNumber, String validationKey) {
		itemList = new ArrayList<Item>();
		this.clientNumber = clientNumber;
		this.validationKey = validationKey;
		serviceURL = DEFAULT_REQUEST_API;
	}
	
	/**
	 * Constructs a SureTaxLient with the given client number, validation key, and request api
	 * @param clientNumber Client ID number provided by SureTax
	 * @param validationKey Client validation key provided by SureTax
	 * @param requestApi The URL of the SureTax API
	 */
	public SureTaxClient(String clientNumber, String validationKey, String requestApi) {
		itemList = new ArrayList<Item>();
		this.clientNumber = clientNumber;
		this.validationKey = validationKey;
		serviceURL = requestApi;
	}
	
	/**
	 * Constructs a SureTaxLient with the given client number, validation key, request api and timeout/retry parameters
	 * @param clientNumber Client ID number provided by SureTax
	 * @param validationKey Client validation key provided by SureTax
	 * @param requestApi The URL of the SureTax API
	 * @param numTries The maximum number of HTTP request attempts to make
	 * @param minDelay The initial delay between retries, in milliseconds
	 * @param maxDelay The maximum allowable delay between retries, in milliseconds
	 * @param timeout The timeout, in milliseconds, to apply to the HTTP connection. If set to zero, the system default will
	 * be used
	 */
	public SureTaxClient(String clientNumber, String validationKey, String requestApi, int numTries, long minDelay, long maxDelay, int timeout) {
		itemList = new ArrayList<Item>();
		this.clientNumber = clientNumber;
		this.validationKey = validationKey;
		serviceURL = requestApi;
		maxAttempts = numTries;
		retryDelayMin = minDelay;
		retryDelayMax = maxDelay;
		connectTimeoutMillis = timeout;
	}

	/**
	 * Sets the zipcode for taxation purposes, and establishes that only the 5-character zip will be used.
	 * @param zipcode The zipcode to use for taxation purposes
	 */
	public void setJurisdictionWithZip(String zipcode) {
		this.zipcode = zipcode;
		plus4 = "";
		taxSitusRuleCode = TAX_SITUS_RULE_ZIP;
	}
	
	/**
	 * Sets the zipcode "plus 4" for taxation purposes, and establishes that the full 9-character zip will be used.
	 * @param zipcode The base 5-character zip
	 * @param plus4 The extra 4 digits of the zip
	 */
	public void setJurisdictionWithZip(String zipcode, String plus4) {
		this.zipcode = zipcode;
		this.plus4 = plus4;
		taxSitusRuleCode = TAX_SITUS_RULE_ZIP_PLUS4;
	}

	/**
	 * Adds a new taxable line item to the current line item list. This method is primarily intended to be called by more specific wrapper
	 * methods
	 * @param totalPrice The total charged (taxable) price of this line item. If the line item consists of multiple units, this value is the sum of all unit prices
	 * @param taxTypeCode The SureTax transaction type code associated with this line item or SKU
	 * @param invoiceNumber ID of the invoice to which this line item applies
	 * @param transactionDate Date that charges were incurred
	 * @param seconds Duration in seconds of telephony usage (or 0 if not applicable)
	 * @param units Number of items
	 * @param regCode SureTax regulatory code
	 */
	public void addLineItem(BigDecimal totalPrice, String taxTypeCode, String invoiceNumber, Date transactionDate, int seconds,
			int units, String regCode) {
		Item i = new Item();
		i.setBillToNumber("");
		i.setCustomerNumber("00000001");
		i.setInvoiceNumber(invoiceNumber);
		i.setOrigNumber("");
		i.setP2PPlus4("");
		i.setP2PZipcode("");
		i.setPlus4(plus4);
		i.setRegulatoryCode(regCode);
		i.setRevenue(totalPrice);
		i.setSalesTypeCode("B");
		i.setSeconds(seconds);
		i.setTaxExemptionCodeList(new ArrayList<String>());
		i.setTaxIncludedCode("0");
		i.setTaxSitusRule(taxSitusRuleCode);
		i.setTermNumber("");
		i.setUnits(units);
		i.setUnitType("00");
		i.setZipcode(zipcode); 
		i.setTransTypeCode(taxTypeCode);
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
		i.setTransDate(format.format(transactionDate));
		i.setLineNumber(Integer.toString(lineNumber++));
		itemList.add(i);	
		totalRevenue = totalRevenue.add(totalPrice.multiply(new BigDecimal(units)));
	}
	
	/**
	 * Adds a new taxable line item to the current line item list. This method should be used for non-telephony charges
	 * @param totalPrice The total charged (taxable) price of this line item
	 * @param taxTypeCode The SureTax transaction type code associated with this line item or SKU
	 * @param invoiceNumber ID of the invoice to which this line item applies
	 * @param transDate Date that charges were incurred
	 * @param units Number of items
	 */
	public void addNonTelcoItem(BigDecimal totalPrice, String taxTypeCode, String invoiceNumber, Date transDate, int units) {
		addLineItem(totalPrice, taxTypeCode, invoiceNumber, transDate, 0, units, REGULATORY_CODE_DEFAULT);		
	}
	
	/**
	 * Adds a new taxable line item to the current line item list, representing a single telephony usage charge
	 * @param totalPrice The total charged (taxable) price of this call
	 * @param taxTypeCode The SureTax transaction type code associated with this type of usage
	 * @param invoiceNumber ID of the invoice to which this line item applies
	 * @param transDate Date the usage took place
	 * @param seconds Duration in seconds of telephony usage
	 */
	public void addUsageItem(BigDecimal totalPrice, String taxTypeCode, String invoiceNumber, Date transDate, int seconds) {
		addLineItem(totalPrice, taxTypeCode, invoiceNumber, transDate, seconds, 1, REGULATORY_CODE_VOIP);		
	}
	
	/**
	 * Packs the current line item list into a single request and submits the request to SureTax for calculation
	 * 
	 * @param billingDate The date for which the invoice is submitted
	 * @param returnFileCode "Q" for non-binding quotes, "0" for actual, billed amounts
	 * @throws ClientProtocolException If the underlying json cannot be formatted via UTF-8. This exception should never be thrown
	 * @throws IOException
	 */
	public void submitGenericRequest(GregorianCalendar billingDate, String returnFileCode) throws ClientProtocolException, IOException {
		
		//Construct request entity
		invoice = new GenericRequest();
		invoice.setClientNumber(clientNumber);
		if (isTestMode)
			billingDate.add(Calendar.MONTH, -1);
		int monthNum = billingDate.get(Calendar.MONTH) - Calendar.JANUARY + 1;
		String dataMonth = Integer.toString(monthNum);
		invoice.setDataMonth(dataMonth);
		int yearNum = billingDate.get(Calendar.YEAR);
		String dataYear = Integer.toString(yearNum);
		invoice.setDataYear(dataYear);
		invoice.setItemList(itemList);
		invoice.setResponseGroup("00");
		invoice.setResponseType("D");
		invoice.setReturnFileCode(returnFileCode);
		invoice.setTotalRevenue(totalRevenue);
		invoice.setValidationkey(validationKey);
		invoice.setBusinessUnit("test"); //This field is required, though it can be empty
		invoice.setClientTracking("test"); //This field is required, though it can be empty
		
		//Convert to json
		Gson gson;
		if (isTestMode) {
			gson = new GsonBuilder().setPrettyPrinting().create();
		} else {
			gson = new Gson();
		}
		
		String json = gson.toJson(invoice);
		System.out.println(json);		

		//Connection
		HttpClient httpClient = new DefaultHttpClient();
		HttpParams params = httpClient.getParams();
		if (connectTimeoutMillis > 0) {
			HttpConnectionParams.setConnectionTimeout(params, connectTimeoutMillis);
		}
		HttpPost sureTaxPost = new HttpPost(serviceURL);
		List<NameValuePair> formParams = new ArrayList<NameValuePair>();
		formParams.add(new BasicNameValuePair("request", json));
		UrlEncodedFormEntity jsonEntity;
		jsonEntity = new UrlEncodedFormEntity(formParams, "UTF-8");
		HttpContext localContext = new BasicHttpContext();
		sureTaxPost.setEntity(jsonEntity);
		HttpResponse response = null;
		
		int numAttempts = 0;
		long retryDelay = retryDelayMin;
		boolean isTimeout = false;
		
		do {
			try {
				numAttempts++;
				LOGGER.debug("Submitting SureTax invoice with " + itemList.size() + " line items");
				response = httpClient.execute(sureTaxPost, localContext);
			} catch (ConnectTimeoutException cte) {
				LOGGER.info("Connection timeout: " + cte.getLocalizedMessage() + " Retrying in " + retryDelay + " milliseconds");
				isTimeout = true;
				try {
					Thread.sleep(retryDelay);
				} catch (InterruptedException ie) {
					Thread.currentThread().interrupt();
				}
				retryDelay = retryDelay * 2;
				if (retryDelay > retryDelayMax) {
					retryDelay = retryDelayMax;
				}
			} 
		} while (isTimeout && numAttempts < maxAttempts);
		
		if (isTimeout) {
			LOGGER.warn("Connection timeout. All retries failed.");
			responseCode = NON_SURETAX_ERROR_CODE;
			responseMessage = "Connection timeout. All retries failed.";
			isSuccess = false;
			return;
		}
		int statusCode = response.getStatusLine().getStatusCode();
		if (statusCode != HttpStatus.SC_OK) {
			LOGGER.error("Unexpected HTTP status code: " + statusCode);
			responseCode = NON_SURETAX_ERROR_CODE;
			responseMessage = "Unexpected HTTP status code: " + statusCode;
			isSuccess = false;
		}
		HttpEntity rEntity = response.getEntity();
		String responseStr = "";
		if (rEntity == null) {
			LOGGER.warn("Null response from SureTax API");
		} else{
			responseStr = EntityUtils.toString(rEntity);
		}
		
		System.out.println(responseStr);
		//Here's where we need to determine whether or not an error occurred
		int jsonStart = responseStr.indexOf("{");
		int jsonEnd = responseStr.lastIndexOf("}");
		if (jsonStart < 0) {
			responseCode = NON_SURETAX_ERROR_CODE;
			responseMessage = responseStr;
			isSuccess = false;
		} else {
			String responseJson = responseStr.substring(jsonStart, jsonEnd + 1);
			apiResponse = gson.fromJson(responseJson, GenericResponse.class);
			responseCode = apiResponse.getResponseCode();
			responseMessage = apiResponse.getHeaderMessage();
			if (apiResponse.getSuccessful().equalsIgnoreCase("y")) {
				if (responseCode.equals(FSPConstants.SURETAX_RESPONSE_CODE_SUCCESS)) {
					isSuccess = true;
					totalTax = new BigDecimal(apiResponse.getTotalTax());
					//Assume for now we will only have on group per invoice
					for (Group group : apiResponse.getGroupList()) {
						taxList = group.getTaxList();
					}
				} else {
					//Success with item errors, reported in FCS as failure
					isSuccess = false;
					responseMessage = responseMessage + dumpItemErrors();
				}
			} else {
				isSuccess = false;
			}
		}		
	}
	
	/**
	 * Packs the current line item list into a single request and submits the request to SureTax for calculation, using the current
	 * date for the taxation period and ensuring transience of data by way of quotation mode
	 * @throws ClientProtocolException  If the underlying json cannot be formatted via UTF-8. This exception should never be thrown
	 * @throws IOException
	 */
	public void submitQuoteRequest() throws ClientProtocolException, IOException {
		submitGenericRequest(new GregorianCalendar(), "Q");
	}
	
	/**
	 * Packs the current line item list into a single request and submits the request to SureTax for calculation, ensuring data
	 * permanence using live mode
	 * @param invoiceDate The date for which the invoice is submitted
	 * @throws ClientProtocolException If the underlying json cannot be formatted via UTF-8. This exception should never be thrown
	 * @throws IOException
	 */
	public void submitInvoiceRequest(GregorianCalendar invoiceDate) throws ClientProtocolException, IOException {
		submitGenericRequest(invoiceDate, "0");
	}

	/**
	 * Creates a String representation of all line items that failed during the API call, and the reasons for each failure
	 * @return The error string
	 */
	private String dumpItemErrors() {
		StringBuilder errorDump = new StringBuilder();
		List<ItemMessage> messageList = apiResponse.getItemMessages();
		String lineNumber = null;
		
		for (ItemMessage message : messageList) {
			lineNumber = message.getLineNumber(); 
			for (Item item : itemList) {
				if (item.getLineNumber().equals(lineNumber)) {
					errorDump.append('\n').append(item.toString()).append('\n').append("Response Code: ").append(message.getResponseCode())
						.append(", Message: ").append(message.getMessage());
				}
			}
		}
		return errorDump.toString();
	}
	
	/**
	 * Indicates whether any line items have been added to the transaction request
	 * 
	 * @return True if no line items have been added, false otherwise
	 */
	public boolean isEmpty() {
		return (!ObjectUtils.isValid(itemList));
	}
	
	/****************** Getters and Setters ****************************/
	
	/**
	 * Retrieves the overall response object. The value will be undefined prior to the request
	 * @return The response object
	 */
	public GenericResponse getApiResponse() {
		return apiResponse;
	}
	
	/**
	 * Sets the client to "test mode" for future API requests. This enables certain settings that are required for compatibility
	 * with SureTax's sandbox server
	 */
	public void setTestMode() {
		isTestMode = true;
	}

	/**
	 * Retrieves a flag from the API response indicating whether the request was successful or not
	 * @return The success flag
	 */
	public boolean isSuccess() {
		return isSuccess;
	}

	/**
	 * Retrieves the SureTax response code from the API response. Response codes and their meaning can be viewed in the
	 * SureTax Web Request API documentation
	 * @return The response code
	 */
	public String getResponseCode() {
		return responseCode;
	}

	/**
	 * Retrieves the SureTax response message from the API response
	 * @return The response message
	 */
	public String getResponseMessage() {
		return responseMessage;
	}

	/**
	 * Get the list of tax objects from the API response. Assumes only a single list was generated.
	 * @return The list of Tax objects
	 */
	public List<Tax> getTaxList() {
		return taxList;
	}

	/**
	 * Get the sum total of all taxes from the API response
	 * @return The total tax amount
	 */
	public BigDecimal getTotalTax() {
		return totalTax;
	}
	
}
