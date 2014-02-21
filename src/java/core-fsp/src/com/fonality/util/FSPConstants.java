package com.fonality.util;

/*********************************************************************************
 * //* Copyright (C) 2012 Fonality. All Rights Reserved. //* //* Filename: FSPConstants.java //*
 * Revision: 1.0 //* Author: Satya Boddu //* Created On: Nov 27, 2012 //* Modified by: //* Modified
 * On: //* //* Description: Base constants class for the FSP application. /
 ********************************************************************************/

public class FSPConstants {

	// EMAIL CONFIGURATION PROPERTIES **************************************/
	public static final String EMAIL_SMTP_HOST = "host";
	public static final String EMAIL_SMTP_USER = "user";
	public static final String EMAIL_SMTP_PWD = "pass";
	public static final String EMAIL_SMTP_PORT = "port";

	public static final String EMAIL_QUOTE_FAILURE_TYPE = "Quote";
	public static final String EMAIL_ORDER_FAILURE_TYPE = "Order";
	public static final String EMAIL_PROV_FAILURE_TYPE = "Provisioning";
	public static final String EMAIL_CDR_USAGE_TYPE = "CdrUsage";

	// VALIDATION PROPERTIES **************************************/
	public static final String INPUT_EMPTY = "Input empty";
	public static final String INPUT_ERROR_MESSAGE_EMPTY = "Error Message is missing";
	public static final String INPUT_ERROR_MODULE_EMPTY = "Error Module is missing";
	public static final String INVALID_ERROR_MODULE = "Invalid Error Module";
	public static final String INVALID_ORDER = "Order does not exists";
	public static final String INVALID_ORDER_GROUP = "Order group does not exists";
	public static final String INVALID_ECHO_SIGN_ID = "EchoSign Agreement Id does not exists";
	public static final String INVALID_MODE = "Invalid Mode";
	public static final String MODE_EMPTY = "Mode is missing";
	public static final String ORDER_GROUP_EMPTY = "Order Group is missing";
	public static final String CUSTOMER_EMPTY = "Customer Id is missing";
	public static final String SERVER_EMPTY = "Server Id is missing";
	public static final String START_DATE_EMPTY = "Start Date is missing";
	public static final String END_DATE_EMPTY = "End Date is missing";
	public static final String INVALID_SERVER = "Invalid Server Id";
	public static final String INVALID_START_DATE = "Invalid Start Date";
	public static final String INVALID_END_DATE = "Invalid End Date";
	public static final String INVALID_PAYMENT_METHOD = "Payment Method is Blank/Null";
	public static final String EMAIL_FAILURE = "Problem occurred in sending e-mail";

	public static final String ORDER_EMAIL_TYPE = "Order";
	public static final String QUOTE_EMAIL_TYPE = "Quote";
	public static final String PROV_EMAIL_TYPE = "Provisioning";

	public static final String EMAIL_SUBJECT = "Subject";
	public static final String EMAIL_TEMPLATE = "Template";
	public static final String EMAIL_TO = "TO_ADDR";
	public static final String EMAIL_CC = "CC_ADDR";
	public static final String EMAIL_FROM = "From";

	// FAILURE EMAIL PROPERTIES **************************************/
	public static final String QUOTE_EMAIL_SUBJECT = "QUOTE Transaction Failure";
	public static final String PROV_EMAIL_SUBJECT = "PROVISIONING Transaction Failure";
	public static final String ORDER_EMAIL_SUBJECT = "ORDER Transaction Failure";

	public static final String QUOTE_EMAIL_FROM = "quote_error_from";
	public static final String ORDER_EMAIL_FROM = "order_error_from";
	public static final String PROV_EMAIL_FROM = "prov_error_from";
	public static final String CDR_USAGE_EMAIL_FROM = "cdr_usage_from";

	public static final String QUOTE_EMAIL_TO = "quote_error_to";
	public static final String ORDER_EMAIL_TO = "order_error_to";
	public static final String PROV_EMAIL_TO = "prov_error_to";

	public static final String QUOTE_EMAIL_CC = "quote_error_cc";
	public static final String ORDER_EMAIL_CC = "order_error_cc";
	public static final String PROV_EMAIL_CC = "prov_error_cc";
	public static final String CDR_USAGE_EMAIL_CC = "cdr_usage_cc";

	public static final String QUOTE_FAILURE_TEMPLATE = "content/quote_failure.vm";
	public static final String ORDER_FAILURE_TEMPLATE = "content/order_failure.vm";
	public static final String PROV_FAILURE_TEMPLATE = "content/prov_failure.vm";
	public static final String CDR_USAGE_TEMPLATE = "content/cdr_usage.vm";
	public static final String BILLING_FAILURE_TEMPLATE = "content/billing_failure.vm";
	public static final String BILLING_WARNING_TEMPLATE = "content/billing_warning.vm";

	public static final String CDR_USAGE_EMAIL_SUBJECT = "Customer Usage Data Report";
	public static final String CDR_USAGE_ATTACHMENT_NAME = "Customer_Usage_Data_Report.pdf";

	// BILLING FAILURE EMAIL PROPERTIES **************************************/
	public static final String BILLING_FAILURE_EMAIL_SUBJECT = "Billing Transaction Failure";
	public static final String BILLING_WARNING_EMAIL_SUBJECT = "Billing Transaction processed with warnings";
	public static final String BILLING_FAILURE_TO_ADDRESS = "billing_error_to";
	public static final String BILLING_FAILURE_CC_ADDRESS = "billing_error_cc";
	public static final String BILLING_WARNING_TO_ADDRESS = "billing_warning_to";
	public static final String BILLING_WARNING_CC_ADDRESS = "billing_warning_cc";
	public static final String BILLING_FAILURE_FROM_ADDRESS = "billing_error_from";

	public static final String BILLING_SCHEDULE_ID = "billingScheduleId";
	public static final String ORDER_TRANS_ID = "transactionId";
	public static final String ERROR_TYPE = "errorType";
	public static final String ERROR_DESC = "description";
	public static final String TIME_PERIOD = "timePeriod";
	public static final String START_DATE = "startDate";
	public static final String END_DATE = "endDate";
	public static final String CUSTOMER_NAME = "customerName";
	public static final String TIME = "time";

	// CONFIGURATION CONSTANTS ************************************************/
	public static final String CONFIG_PATH_ENV_NAME = "CONF_TARGET";
	public static final String DB_CONFIG_FILE_NAME = "database/main";
	public static final String BILLING_CONFIG_FILE_NAME = "order/billing";
	public static final String SHIPPING_METHOD_CONFIG_FILE_NAME = "order/shipping_methods";
	public static final String MAIL_CONFIG_FILE_NAME = "mail";
	public static final String BILLSOFT_CONFIG_FILE_NAME = "taxation";
	public static final String CONFIG_FILE_EXTENSION = ".conf";
	public static final String CONFIG_FILE_PACK_EXTENSION = ".mp";
	public static final String MAIL_CONFIG_HEADER = "mail";
	public static final String CONFIG_SERVER_TEST = "test";
	public static final String CONFIG_SERVER_DEV = "devel";
	public static final String CONFIG_SERVER_PROD = "production";
	public static final String NETSUITE_CONFIG_FILE_NAME = "netsuite";
	public static final String MEMCACHED_CONFIG_FILE_NAME = "cache/memcached";
	public static final String SURETAX_CONFIG_CLIENT_ID = "clientId";
	public static final String SURETAX_CONFIG_VALIDATION_KEY = "validationKey";
	public static final String SURETAX_CONFIG_CONNECT_TIMEOUT = "httpConnectionTimeout";
	public static final String SURETAX_CONFIG_CONNECT_ATTEMPTS = "maxConnectionAttempts";
	public static final String SURETAX_CONFIG_RETRY_DELAY_MIN = "retryDelayMin";
	public static final String SURETAX_CONFIG_RETRY_DELAY_MAX = "retryDelayMax";
	public static final String SURETAX_CONFIG_API_URL = "requestApiUrl";

	// MISC CONSTANTS *******************************************************/
	public static final String EMPTY = "";
	public static final String SPACE = " ";
	public static final String COMMA_SPACE = ", ";
	public static final String COMMA = ",";
	public static final String HYPHEN_SPACE = " - ";
	public static final String COLON = ":";
	public static final String COLON_SPACE = " : ";
	public static final String ZERO = "0";
	public static final String NEW_LINE = "\n";
	public static final String BREAK = "<br />";
	public static final String DOUBLE_QUOTE = "\"";
	public static final String USA_ISO3_CODE = "USA";
	public static final String USA_ISO2_CODE = "US";
	public static final long EXIT_CODE_FAILURE = 1;
	public static final long EXIT_CODE_SUCCESS = 0;
	public static final String ADMIN_ROLE = "admin";
	public static final String AUTH_HEADER = "Authorization";
	public static final String SUCCESS = "Success";
	public static final String AGREEMENT_ID_PARAM = "agreementId";
	public static final String OWNER_ID_PARAM = "ownerId";
	public static final String TRANSACTION_ID_PARAM = "transactionId";
	public static final String FILE_ID_PARAM = "fileId";
	public static final String TYPE_ID_PARAM = "type";
	public static final String PDF_EXT = ".pdf";
	public static final double FAX_PAGE_COST = 0.07;
	public static final int HASHCODE_PRIME = 31;
	public static final String USAGE_MIN = "minutes";

	public static final String STATUS = "status";
	public static final String ID = "id";
	public static final String MESSAGE = "message";
	public static final String ERROR = "error";
	public static final String URL = "url";
	public static final String SIGNED_STATUS = "signed_status";

	public static final String NS_SESSION_TIMEOUT_MILLIS = "3600000"; // 1 hour

	public static final String NS_ACCOUNT = "account";
	public static final String NS_USER = "user";
	public static final String NS_PWD = "pass";
	public static final String NS_ROLE = "role";
	public static final String NS_WS_URL = "ws.url";
	public static final String NS_PASSWORD_PARAM = "password";
	public static final String NS_EMAIL_PARAM = "email";
	public static final String NS_SENDERID_PARAM = "senderid";
	public static final String NS_LOGIN_URL_PARAM = "ns.login.url";
	public static final String NS_ORDER_ID_PARAM = "orderId";
	public static final String NS_ITMFLMNT_ID_PARAM = "fulfillmentId";
	public static final String NS_ECHO_SIGN_ADD_AGR_URL_PARAM = "ns.echosignagr.add.url";
	public static final String NS_ECHO_SIGN_SEND_AGR_URL_PARAM = "ns.echosignagr.send.url";
	public static final String NS_ECHO_SIGN_UPDATE_AGR_URL_PARAM = "ns.echosignagr.update.url";
	public static final String NS_EMAIL_TRANSACTION_URL_PARAM = "ns.email.transaction.url";
	public static final String NS_ITEM_FULFIL_PRINT_LABEL_URL_PARAM = "ns.item.fulfillment.print.url";
	public static final String NS_TRANSFORM_RECORD_URL_PARAM = "ns.transform.record.url";
	public static final String NS_ID_TOKEN = "id=";
	public static final String NS_ECHO_SIGN_RECTYPE_TOKEN = "rectype=146";
	public static final String NS_USAGE_REPORT_NAME = "Customer_Usage_Report_";
	public static final String NS_ECHO_SIGN_STATUS_SUCCESS = "success";
	public static final String ECHO_SIGN_SEND = "sendDocument";
	public static final String ECHO_SIGN_GET = "getDocument";
	public static final String TIME_OUT_IN_MILLIS = "timeout.millis";
	public static final String DEFAULT_CONF = "default";

	// Netsuite Script constants
	public static final String NS_SCRIPT_ERROR = "error";
	public static final String NS_SCRIPT_FROM_ID_PARAM = "fromId";
	public static final String NS_SCRIPT_FROM_TYPE_PARAM = "fromType";
	public static final String NS_SCRIPT_TO_TYPE_PARAM = "toType";
	public static final String NS_SCRIPT_CONTENT_TYPE_PARAM = "Content-Type";
	public static final String NS_SCRIPT_CONTENT_TYPE_JSON = "application/json";
	public static final String NS_SCRIPT_UTF_ENCODING = "UTF-8";

	public static final String BILLING_PROCESS_ONE_TIME = "one_time_costs";

	// DB CONSTANTS ******************************************************?
	public static final int PRICE_MODEL_ANNUALLY = 1;
	public static final int PRICE_MODEL_MONTHLY = 2;
	public static final int PRICE_MODEL_USAGE = 3;
	public static final int PRICE_MODEL_ONE_TIME = 4;
	public static final int PRICE_MODEL_RENT = 5;
	public static final int PRICE_MODEL_BUY = 6;
	public static final int PRICE_MODEL_NONE = 8;
	public static final String PRICE_MODEL_NONE_NAME = "None";
	public static final String INVOICE_NS_TRANSACTION_TYPE = "invoice";
	public static final String CASHSALE_NS_TRANSACTION_TYPE = "cashSale";
	public static final String INVOICE_CUSTOM_FORM = "196";
	public static final String CASHSALE_CUSTOM_FORM = "135";
	public static final String BUNDLE_NAME_TAX = "sales_tax_and_regulatory_charges";
	public static final String BUNDLE_NAME_FAX = "fax_usage";
	public static final String BUNDLE_NAME_LINE_DISCOUNT = "line_discount";
	public static final String BUNDLE_NAME_MONTHLY_ADJUSTMENT = "monthlyadjustment";
	public static final String BUNDLE_NAME_DOWNPAYMENT = "downpayment";
	public static final String BUNDLE_INTERNATIONAL_STD_USAGE = "international_std_usage";
	public static final String BUNDLE_TOLLFREE_USAGE = "tollfree_usage";
	public static final String BUNDLE_PREMIUM_USAGE = "premium_usage";
	public static final String BUNDLE_EMERGENCY_USAGE = "emergency_usage";
	public static final String BUNDLE_INTERNATIONAL_MOBILE_USAGE = "international_mobile_usage";
	public static final String BUNDLE_STANDARD_USAGE = "standard_usage";
	public static final String BUNDLE_STANDARD_MOBILE_USAGE = "standard_usage";
	public static final String BUNDLE_NAME_FCS = "fcs";
	public static final String BUNDLE_NAME_FCS_PRO = "fcs_pro";
	public static final String PAYMENT_METHOD_CREDIT_CARD = "Credit card";

	// DB ENUMS ******************************************************************/
	public static final String INVOICE_TRANSACTION_TYPE = "INVOICE";
	public static final String CASHSALE_TRANSACTION_TYPE = "CASH_SALE";
	public static final String ORDER_TRANSACTION_STATUS_READY = "READY_TO_PROCESS";
	public static final String ORDER_TRANSACTION_STATUS_SUCCESS = "PROCESSED";
	public static final String ORDER_TRANSACTION_STATUS_NOT_PROCESSED = "NOT_PROCESSED";
	public static final String BILLING_SCHEDULE_STATUS_NOT_PROCESSED = "NOT_PROCESSED";
	public static final String BILLING_SCHEDULE_TYPE_SERVICE = "SERVICE";
	public static final String BILLING_SCHEDULE_TYPE_SYSTEM = "SYSTEM";
	public static final String BILLING_SCHEDULE_TYPE_ALL = "ALL";
	public static final String ORDERS_ORDER_TYPE_NEW = "NEW";
	public static final String ORDERS_ORDER_TYPE_ADDON = "ADDON";
	public static final String ORDERS_RECORD_TYPE_QUOTE = "QUOTE";
	public static final String ORDERS_RECORD_TYPE_ORDER = "ORDER";
	public static final String UNBOUND_CDR_CALL_TYPE_TOLLFREE = "tollfree";
	public static final String UNBOUND_CDR_CALL_TYPE_STANDARD = "standard";
	public static final String UNBOUND_CDR_CALL_TYPE_MOBILE = "mobile";
	public static final String UNBOUND_CDR_CALL_TYPE_EMERGENCY = "emergency";
	public static final String UNBOUND_CDR_CALL_TYPE_PREMIUM = "premium";
	public static final String BILLING_SCHEDULE_PROCESSED_ALL = "PROCESSED_ALL";
	public static final String BILLING_SCHEDULE_PROCESSED_TAX = "PROCESSED_MRC_AND_TAX";
	public static final String BILLING_ADDRESS_TYPE = "BILLING";
	public static final String BUNDLE_USAGE_CATEGORY = "usage_charge";
	public static final String PRE_PAY_DEFERRED_REVENUE = "FCS Pre-Pay Deferred Revenue";

	// Billable CDR processing other attributes
	public static final String UNBOUND_CDR_CALL_DIRECTIONS_INBOUND = "inbound";
	public static final String UNBOUND_CDR_CALL_DIRECTIONS_OUTBOUND = "outbound";
	public static final String[] TOLL_FREE_PREFIX = { "1300", "1800", "1855", "1866", "1877",
			"1888", "300", "800", "855", "866", "877", "888" };
	public static final String[] STANDARD_CALL_FREE_COUNTRY = { "US", "CA", "PR", "GU", "VI", "IT",
			"FR", "IE", "ES", "GB" };
	public static final String[] MOBILE_CALL_FREE_COUNTRY = { "US", "CA", "PR", "GU", "VI" };
	public static final String US_EMERGENCY = "911";
	public static final String PREMIUM = "900";
	public static final String ONE_PREMIUM = "1900";
	public static final String ONE_AU = "10011";
	public static final String ONE_US = "1011";
	public static final String AU = "0011";
	public static final String US = "011";

	// Bilable CDR Usage  Display Name Constants
	public static final String INTERNATIONAL_STD_TYPE = "International Standard";
	public static final String INTERNATIONAL_MOBILE_TYPE = "International Mobile";
	public static final String MOBILE_TYPE = "Mobile";
	public static final String TOLLFREE_TYPE = "Toll-Free (inbound only)";
	public static final String PREMIUM_TYPE = "Premium";
	public static final String EMERGENCY_TYPE = "Emergency";
	public static final String STANDARD_TYPE = "Standard";

	// BU Input  Json CONSTANTS *******************************************************/
	public static final String INPUT_JSON_CREDIT_CARD = "credit_card";
	public static final String INPUT_JSON_BILLING = "billing";
	public static final String INPUT_JSON_ORDER_ID = "order_id";

	// REPORT CONSTANTS *******************************************************/
	public static final String CUSTOMER_ID_PARAM = "customer_id";
	public static final String SERVER_ID_PARAM = "server_id";
	public static final String START_DATE_PARAM = "start_date";
	public static final String END_DATE_PARAM = "end_date";
	public static final String SERVER_CDR_LIST_PARAM = "server_cdr_list";
	public static final String CDR_USAGE_SERVER_REPORT_PARAM = "server_report_param";
	public static final String CDR_USAGE_SUMMARY_REPORT_PARAM = "summary_report_param";
	public static final String CDR_USAGE_SERVER_SUMMARY_REPORT_PARAM = "server_summary_report_param";
	public static final String CDR_USAGE_HEADER_LOGO_PATH_PARAM = "header_logo_path";
	public static final String REPORT_PATH_PARAM = "reportPath";
	public static final String DURATION_SUM_PARAM = "durationSum";
	public static final String AMOUNT_SUM_PARAM = "amountSum";
	public static final String CALL_TYPE_SUMMARY_PARAM = "call_type_summary";

	public static final String REPORT_DIR = "/conf/images";
	public static final String CDR_USAGE_REPORT_PATH = "/conf/reports/customerCdrUsageReport.jasper";
	public static final String CDR_USAGE_SERVER_REPORT_PATH = "/conf/reports/customerServerCdrUsageReport.jasper";
	public static final String CDR_USAGE_SUMMARY_REPORT_PATH = "/conf/reports/customerSummaryCdrUsageReport.jasper";
	public static final String CDR_USAGE_SERVER_SUMMARY_REPORT_PATH = "/conf/reports/customerServerSummaryCdrUsageReport.jasper";
	public static final String CDR_USAGE_HEADER_LOGO_PATH = "/conf/images/FCSBanner_CallDetails.png";

	// NetSuite Custom Field Constants
	public static final String CUSTOM_SERVER_ID = "custbody_serverid";
	public static final String CUSTOM_ECHOSIGN_ROLE = "custrecord_echosign_role";
	public static final String CUSTOM_ECHOSIGNER_AGREEMENT = "custrecord_echosign_agree";
	public static final String CUSTOM_ECHOSIGNDOC_AGREEMENT = "custrecord_echosign_agreement";
	public static final String CUSTOM_ECHOSIGNDOC_FILE = "custrecord_echosign_file";
	public static final String CUSTOM_ECHOSIGNAGR_STATUS = "custrecord_echosign_status_2";
	public static final String CUSTOM_ECHOSIGNAGR_SIGNED_FILE_ID = "custrecord_echosign_signed_doc_2";
	public static final String CUSTOM_CC_NUMBER = "custrecord44";

	public static final String CUSTOM_ECHOSIGN_EMAIL = "custrecord_echosign_email";
	public static final String CUSTOM_ECHOSIGN_SIGNER = "custrecord_echosign_signer";
	public static final String CUSTOM_ECHOSIGN_SIGNER_ORDER = "custrecord_echosign_signer_order";
	public static final String CUSTOM_ECHOSIGN_SIGNER_TO_ORDER = "custrecord_echosign_to_order";

	public static final String CUSTOM_ECHOSIGNER_TYPE_ID = "144";
	public static final String CUSTOM_ECHOSIGNDOCUMENT_TYPE_ID = "35";
	public static final String CUSTOM_ECHOSIGNAGREEMENT_TYPE_ID = "146";
	public static final String CUSTOM_ECHOSIGNER_ROLE_TYPE_ID = "27";
	public static final String CUSTOM_ECHOSIGNER_SIGNER_TYPE_ID = "-6";
	public static final String CUSTOM_ECHOSIGNER_ROLE_ID = "1";
	public static final String CUSTOM_CC_TYPE_ID = "254";

	public static final String CUSTOM_ORDER_LOCATION_FLD = "location";
	public static final String CUSTOM_ORDER_EXP_SHIP_DATE_FLD = "custbody2";
	public static final String CUSTOM_EST_TERMS_FLD = "custbody_bdy_term_2";
	public static final String CUSTOM_EST_USERS_FLD = "custbody_users";
	public static final String CUSTOM_EST_SHIP_METHOD_FLD = "shipmethod";

	public static final String NETSUITE_PAYMENT_METHOD_VISA = "visa";
	public static final String NETSUITE_PAYMENT_METHOD_MASTERCARD = "mastercard";
	public static final String NETSUITE_PAYMENT_METHOD_AMEX = "american_express";
	public static final String NETSUITE_PAYMENT_METHOD_DISCOVER = "discover";

	public static final String NETSUITE_OPPORTUNITY_RECORD = "opportunity";
	public static final String NETSUITE_ESTIMATE_RECORD = "estimate";
	public static final String NETSUITE_SALES_ORDER_RECORD = "salesorder";

	public static final String NETSUITE_SIGNED_STATUS = "Signed";
	public static final String NETSUITE_OUT_FOR_SIGNATURE_STATUS = "Out For Signature";

	public static final String NETSUITE_PRICE_LEVEL1 = "1";
	public static final String NETSUITE_PRICE_CUSTOM = "-1";

	// Billing failure constants
	public static final String DATA_ERROR = "Data Error";
	public static final String NETSUITE_ERROR = "NetSuite Error";
	public static final String BILLSOFT_ERROR = "BillSoft Error";
	public static final String REPORT_ERROR = "Report Error";
	public static final String BILLING_ERROR_LEVEL = "Error";
	public static final String BILLING_WARN_LEVEL = "Warn";

	// Billing processing methods returns constants
	public static final long EXIT_TAX_FAILURE = 2;
	public static final long EXIT_INVOICE_FAILURE = 3;
	public static final long EXIT_BILLING_FAILURE = 4;
	public static final long EXIT_BILLING_SUCCESS = 5;
	public static final long EXIT_TAX_SUCCESS = 6;

	//SureTax Constants ******************************/
	public static final String SURETAX_RESPONSE_CODE_SUCCESS = "9999";
}
