
package com.fonality.billsoft;

import java.math.BigDecimal;
import java.math.BigInteger;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlElementDecl;
import javax.xml.bind.annotation.XmlRegistry;
import javax.xml.datatype.Duration;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.namespace.QName;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the com.fonality.bs package. 
 * <p>An ObjectFactory allows you to programatically 
 * construct new instances of the Java representation 
 * for XML content. The Java representation of XML 
 * content can consist of schema derived interfaces 
 * and classes representing the binding of schema 
 * type definitions, element declarations and model 
 * groups.  Factory methods for each of these are 
 * provided in this class.
 * 
 */
@XmlRegistry
public class ObjectFactory {

    private final static QName _AnyURI_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "anyURI");
    private final static QName _InstallationAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "InstallationAttributes");
    private final static QName _TaxExemption_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "TaxExemption");
    private final static QName _Char_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "char");
    private final static QName _AddressData_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "AddressData");
    private final static QName _Float_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "float");
    private final static QName _FactoryWarrantyAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "FactoryWarrantyAttributes");
    private final static QName _Long_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "long");
    private final static QName _DiscountAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "DiscountAttributes");
    private final static QName _Base64Binary_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "base64Binary");
    private final static QName _Byte_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "byte");
    private final static QName _ShipAndHandlingAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ShipAndHandlingAttributes");
    private final static QName _SalesUseTransaction_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "SalesUseTransaction");
    private final static QName _Boolean_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "boolean");
    private final static QName _ArrayOfAddressData_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ArrayOfAddressData");
    private final static QName _TradeInAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "TradeInAttributes");
    private final static QName _ArrayOfSalesUseTransaction_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ArrayOfSalesUseTransaction");
    private final static QName _FinanceAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "FinanceAttributes");
    private final static QName _ArrayOfNexus_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ArrayOfNexus");
    private final static QName _Nexus_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "Nexus");
    private final static QName _UnsignedByte_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "unsignedByte");
    private final static QName _ArrayOfExclusion_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ArrayOfExclusion");
    private final static QName _AnyType_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "anyType");
    private final static QName _Int_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "int");
    private final static QName _ZipAddress_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ZipAddress");
    private final static QName _SoftwareMaintAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "SoftwareMaintAttributes");
    private final static QName _Double_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "double");
    private final static QName _Exclusion_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "Exclusion");
    private final static QName _ArrayOfCustomerTaxData_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ArrayOfCustomerTaxData");
    private final static QName _ArrayOfTaxData_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ArrayOfTaxData");
    private final static QName _DateTime_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "dateTime");
    private final static QName _QName_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "QName");
    private final static QName _CustomerTaxData_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "CustomerTaxData");
    private final static QName _UnsignedShort_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "unsignedShort");
    private final static QName _DemurrageAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "DemurrageAttributes");
    private final static QName _TaxData_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "TaxData");
    private final static QName _Short_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "short");
    private final static QName _FreightAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "FreightAttributes");
    private final static QName _DepositAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "DepositAttributes");
    private final static QName _DefaultAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "DefaultAttributes");
    private final static QName _UnsignedInt_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "unsignedInt");
    private final static QName _ArrayOfTaxExemption_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ArrayOfTaxExemption");
    private final static QName _Decimal_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "decimal");
    private final static QName _Guid_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "guid");
    private final static QName _Duration_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "duration");
    private final static QName _ReverseTaxResults_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ReverseTaxResults");
    private final static QName _String_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "string");
    private final static QName _ServiceContractAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ServiceContractAttributes");
    private final static QName _MaintAgreementAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "MaintAgreementAttributes");
    private final static QName _UnsignedLong_QNAME = new QName("http://schemas.microsoft.com/2003/10/Serialization/", "unsignedLong");
    private final static QName _Transaction_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "Transaction");
    private final static QName _ExtWarrantyAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ExtWarrantyAttributes");
    private final static QName _GetTaxCategoryResponseGetTaxCategoryResult_QNAME = new QName("http://tempuri.org/", "GetTaxCategoryResult");
    private final static QName _CalcReverseAdjWithNpaNxxAnAdjustment_QNAME = new QName("http://tempuri.org/", "anAdjustment");
    private final static QName _CalcReverseTaxesWithFipsCodeResponseCalcReverseTaxesWithFipsCodeResult_QNAME = new QName("http://tempuri.org/", "CalcReverseTaxesWithFipsCodeResult");
    private final static QName _FipsToPCodeAFips_QNAME = new QName("http://tempuri.org/", "aFips");
    private final static QName _SAUCalcTaxesAndAdjWithPCodeInCustModeAnAdjustmentList_QNAME = new QName("http://tempuri.org/", "anAdjustmentList");
    private final static QName _SAUCalcTaxesAndAdjWithPCodeInCustModeATransactionList_QNAME = new QName("http://tempuri.org/", "aTransactionList");
    private final static QName _SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME = new QName("http://tempuri.org/", "anExclusionList");
    private final static QName _SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME = new QName("http://tempuri.org/", "aNexusList");
    private final static QName _SAUCalcTaxesWithFipsCodeATransaction_QNAME = new QName("http://tempuri.org/", "aTransaction");
    private final static QName _PCodeToFipsResponsePCodeToFipsResult_QNAME = new QName("http://tempuri.org/", "PCodeToFipsResult");
    private final static QName _CalcTaxesWithNpaNxxResponseCalcTaxesWithNpaNxxResult_QNAME = new QName("http://tempuri.org/", "CalcTaxesWithNpaNxxResult");
    private final static QName _CalcReverseTaxesWithZipAddressResponseCalcReverseTaxesWithZipAddressResult_QNAME = new QName("http://tempuri.org/", "CalcReverseTaxesWithZipAddressResult");
    private final static QName _CalcReverseTaxesWithPCodeResponseCalcReverseTaxesWithPCodeResult_QNAME = new QName("http://tempuri.org/", "CalcReverseTaxesWithPCodeResult");
    private final static QName _SAUCalcReverseAdjWithZipAddressResponseSAUCalcReverseAdjWithZipAddressResult_QNAME = new QName("http://tempuri.org/", "SAUCalcReverseAdjWithZipAddressResult");
    private final static QName _SAUCalcTaxesAndAdjWithZipAddressInCustModeResponseSAUCalcTaxesAndAdjWithZipAddressInCustModeResult_QNAME = new QName("http://tempuri.org/", "SAUCalcTaxesAndAdjWithZipAddressInCustModeResult");
    private final static QName _SAUCalcReverseTaxesWithPCodeResponseSAUCalcReverseTaxesWithPCodeResult_QNAME = new QName("http://tempuri.org/", "SAUCalcReverseTaxesWithPCodeResult");
    private final static QName _SAUCalcReverseTaxesWithFipsCodeResponseSAUCalcReverseTaxesWithFipsCodeResult_QNAME = new QName("http://tempuri.org/", "SAUCalcReverseTaxesWithFipsCodeResult");
    private final static QName _CalcReverseAdjWithNpaNxxResponseCalcReverseAdjWithNpaNxxResult_QNAME = new QName("http://tempuri.org/", "CalcReverseAdjWithNpaNxxResult");
    private final static QName _CalcReverseTaxesWithNpaNxxResponseCalcReverseTaxesWithNpaNxxResult_QNAME = new QName("http://tempuri.org/", "CalcReverseTaxesWithNpaNxxResult");
    private final static QName _NpaNxxToPCodeResponseNpaNxxToPCodeResult_QNAME = new QName("http://tempuri.org/", "NpaNxxToPCodeResult");
    private final static QName _CustomerTaxDataTaxLevel_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "TaxLevel");
    private final static QName _CustomerTaxDataDescription_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "Description");
    private final static QName _CustomerTaxDataCategoryDescription_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "CategoryDescription");
    private final static QName _CalcTaxesWithFipsCodeResponseCalcTaxesWithFipsCodeResult_QNAME = new QName("http://tempuri.org/", "CalcTaxesWithFipsCodeResult");
    private final static QName _CalcAdjWithPCodeResponseCalcAdjWithPCodeResult_QNAME = new QName("http://tempuri.org/", "CalcAdjWithPCodeResult");
    private final static QName _SalesUseTransactionSaleAttributes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "SaleAttributes");
    private final static QName _SalesUseTransactionShipFromFipsCode_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ShipFromFipsCode");
    private final static QName _SalesUseTransactionOptionalAlpha1_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "OptionalAlpha1");
    private final static QName _SalesUseTransactionShipFromPCode_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ShipFromPCode");
    private final static QName _SalesUseTransactionShipToAddress_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ShipToAddress");
    private final static QName _SalesUseTransactionShipFromAddress_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ShipFromAddress");
    private final static QName _SalesUseTransactionCompanyIdentifier_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "CompanyIdentifier");
    private final static QName _SalesUseTransactionFOB_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "FOB");
    private final static QName _SalesUseTransactionCustomerNumber_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "CustomerNumber");
    private final static QName _SalesUseTransactionShipToFipsCode_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ShipToFipsCode");
    private final static QName _SalesUseTransactionCustomerType_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "CustomerType");
    private final static QName _SalesUseTransactionShipToPCode_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ShipToPCode");
    private final static QName _SalesUseTransactionExemptions_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "Exemptions");
    private final static QName _ReverseTaxResultsTaxes_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "Taxes");
    private final static QName _CalcAdjWithZipAddressResponseCalcAdjWithZipAddressResult_QNAME = new QName("http://tempuri.org/", "CalcAdjWithZipAddressResult");
    private final static QName _TransactionTerminationAddress_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "TerminationAddress");
    private final static QName _TransactionOriginationPCode_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "OriginationPCode");
    private final static QName _TransactionTerminationNpaNxx_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "TerminationNpaNxx");
    private final static QName _TransactionOriginationNpaNxx_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "OriginationNpaNxx");
    private final static QName _TransactionBusinessClass_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "BusinessClass");
    private final static QName _TransactionTerminationPCode_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "TerminationPCode");
    private final static QName _TransactionServiceClass_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ServiceClass");
    private final static QName _TransactionBillToFipsCode_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "BillToFipsCode");
    private final static QName _TransactionBillToPCode_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "BillToPCode");
    private final static QName _TransactionTerminationFipsCode_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "TerminationFipsCode");
    private final static QName _TransactionBillToAddress_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "BillToAddress");
    private final static QName _TransactionBillToNpaNxx_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "BillToNpaNxx");
    private final static QName _TransactionOriginationFipsCode_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "OriginationFipsCode");
    private final static QName _TransactionOriginationAddress_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "OriginationAddress");
    private final static QName _SAUCalcReverseTaxesWithZipAddressResponseSAUCalcReverseTaxesWithZipAddressResult_QNAME = new QName("http://tempuri.org/", "SAUCalcReverseTaxesWithZipAddressResult");
    private final static QName _CalcAdjWithNpaNxxResponseCalcAdjWithNpaNxxResult_QNAME = new QName("http://tempuri.org/", "CalcAdjWithNpaNxxResult");
    private final static QName _CalcReverseAdjWithPCodeResponseCalcReverseAdjWithPCodeResult_QNAME = new QName("http://tempuri.org/", "CalcReverseAdjWithPCodeResult");
    private final static QName _CalcReverseAdjWithZipAddressResponseCalcReverseAdjWithZipAddressResult_QNAME = new QName("http://tempuri.org/", "CalcReverseAdjWithZipAddressResult");
    private final static QName _CalcReverseAdjWithFipsCodeResponseCalcReverseAdjWithFipsCodeResult_QNAME = new QName("http://tempuri.org/", "CalcReverseAdjWithFipsCodeResult");
    private final static QName _AddressDataZipP4End_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ZipP4End");
    private final static QName _AddressDataZipBegin_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ZipBegin");
    private final static QName _AddressDataCountryISO_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "CountryISO");
    private final static QName _AddressDataZipEnd_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ZipEnd");
    private final static QName _AddressDataZipP4Begin_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ZipP4Begin");
    private final static QName _AddressDataCounty_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "County");
    private final static QName _AddressDataLocality_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "Locality");
    private final static QName _AddressDataState_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "State");
    private final static QName _SAUCalcAdjWithZipAddressResponseSAUCalcAdjWithZipAddressResult_QNAME = new QName("http://tempuri.org/", "SAUCalcAdjWithZipAddressResult");
    private final static QName _CalcAdjWithFipsCodeResponseCalcAdjWithFipsCodeResult_QNAME = new QName("http://tempuri.org/", "CalcAdjWithFipsCodeResult");
    private final static QName _SAUCalcTaxesAndAdjWithFipsCodeInCustModeResponseSAUCalcTaxesAndAdjWithFipsCodeInCustModeResult_QNAME = new QName("http://tempuri.org/", "SAUCalcTaxesAndAdjWithFipsCodeInCustModeResult");
    private final static QName _CalcTaxesWithPCodeResponseCalcTaxesWithPCodeResult_QNAME = new QName("http://tempuri.org/", "CalcTaxesWithPCodeResult");
    private final static QName _ZipAddressZipP4_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ZipP4");
    private final static QName _ZipAddressZipCode_QNAME = new QName("http://schemas.datacontract.org/2004/07/EZTaxWebService", "ZipCode");
    private final static QName _SAUCalcTaxesWithFipsCodeResponseSAUCalcTaxesWithFipsCodeResult_QNAME = new QName("http://tempuri.org/", "SAUCalcTaxesWithFipsCodeResult");
    private final static QName _CalcTaxesWithZipAddressResponseCalcTaxesWithZipAddressResult_QNAME = new QName("http://tempuri.org/", "CalcTaxesWithZipAddressResult");
    private final static QName _SAUCalcReverseAdjWithPCodeResponseSAUCalcReverseAdjWithPCodeResult_QNAME = new QName("http://tempuri.org/", "SAUCalcReverseAdjWithPCodeResult");
    private final static QName _GetTaxDescriptionResponseGetTaxDescriptionResult_QNAME = new QName("http://tempuri.org/", "GetTaxDescriptionResult");
    private final static QName _GetAddressResponseGetAddressResult_QNAME = new QName("http://tempuri.org/", "GetAddressResult");
    private final static QName _ZipToPCodeResponseZipToPCodeResult_QNAME = new QName("http://tempuri.org/", "ZipToPCodeResult");
    private final static QName _SAUCalcAdjWithPCodeResponseSAUCalcAdjWithPCodeResult_QNAME = new QName("http://tempuri.org/", "SAUCalcAdjWithPCodeResult");
    private final static QName _SAUCalcAdjWithFipsCodeResponseSAUCalcAdjWithFipsCodeResult_QNAME = new QName("http://tempuri.org/", "SAUCalcAdjWithFipsCodeResult");
    private final static QName _SAUCalcReverseAdjWithFipsCodeResponseSAUCalcReverseAdjWithFipsCodeResult_QNAME = new QName("http://tempuri.org/", "SAUCalcReverseAdjWithFipsCodeResult");
    private final static QName _SAUCalcTaxesWithPCodeResponseSAUCalcTaxesWithPCodeResult_QNAME = new QName("http://tempuri.org/", "SAUCalcTaxesWithPCodeResult");
    private final static QName _FipsToPCodeResponseFipsToPCodeResult_QNAME = new QName("http://tempuri.org/", "FipsToPCodeResult");
    private final static QName _SAUCalcTaxesAndAdjWithPCodeInCustModeResponseSAUCalcTaxesAndAdjWithPCodeInCustModeResult_QNAME = new QName("http://tempuri.org/", "SAUCalcTaxesAndAdjWithPCodeInCustModeResult");
    private final static QName _SAUCalcTaxesWithZipAddressResponseSAUCalcTaxesWithZipAddressResult_QNAME = new QName("http://tempuri.org/", "SAUCalcTaxesWithZipAddressResult");
    private final static QName _ZipToPCodeAZipAddress_QNAME = new QName("http://tempuri.org/", "aZipAddress");

    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: com.fonality.bs
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link SAUCalcTaxesAndAdjWithPCodeInCustMode }
     * 
     */
    public SAUCalcTaxesAndAdjWithPCodeInCustMode createSAUCalcTaxesAndAdjWithPCodeInCustMode() {
        return new SAUCalcTaxesAndAdjWithPCodeInCustMode();
    }

    /**
     * Create an instance of {@link ArrayOfSalesUseTransaction }
     * 
     */
    public ArrayOfSalesUseTransaction createArrayOfSalesUseTransaction() {
        return new ArrayOfSalesUseTransaction();
    }

    /**
     * Create an instance of {@link ArrayOfNexus }
     * 
     */
    public ArrayOfNexus createArrayOfNexus() {
        return new ArrayOfNexus();
    }

    /**
     * Create an instance of {@link ArrayOfExclusion }
     * 
     */
    public ArrayOfExclusion createArrayOfExclusion() {
        return new ArrayOfExclusion();
    }

    /**
     * Create an instance of {@link SAUCalcAdjWithPCodeResponse }
     * 
     */
    public SAUCalcAdjWithPCodeResponse createSAUCalcAdjWithPCodeResponse() {
        return new SAUCalcAdjWithPCodeResponse();
    }

    /**
     * Create an instance of {@link ArrayOfTaxData }
     * 
     */
    public ArrayOfTaxData createArrayOfTaxData() {
        return new ArrayOfTaxData();
    }

    /**
     * Create an instance of {@link CalcReverseAdjWithNpaNxxResponse }
     * 
     */
    public CalcReverseAdjWithNpaNxxResponse createCalcReverseAdjWithNpaNxxResponse() {
        return new CalcReverseAdjWithNpaNxxResponse();
    }

    /**
     * Create an instance of {@link ReverseTaxResults }
     * 
     */
    public ReverseTaxResults createReverseTaxResults() {
        return new ReverseTaxResults();
    }

    /**
     * Create an instance of {@link SAUCalcReverseAdjWithPCode }
     * 
     */
    public SAUCalcReverseAdjWithPCode createSAUCalcReverseAdjWithPCode() {
        return new SAUCalcReverseAdjWithPCode();
    }

    /**
     * Create an instance of {@link SalesUseTransaction }
     * 
     */
    public SalesUseTransaction createSalesUseTransaction() {
        return new SalesUseTransaction();
    }

    /**
     * Create an instance of {@link CalcReverseTaxesWithFipsCode }
     * 
     */
    public CalcReverseTaxesWithFipsCode createCalcReverseTaxesWithFipsCode() {
        return new CalcReverseTaxesWithFipsCode();
    }

    /**
     * Create an instance of {@link Transaction }
     * 
     */
    public Transaction createTransaction() {
        return new Transaction();
    }

    /**
     * Create an instance of {@link SAUCalcReverseAdjWithZipAddressResponse }
     * 
     */
    public SAUCalcReverseAdjWithZipAddressResponse createSAUCalcReverseAdjWithZipAddressResponse() {
        return new SAUCalcReverseAdjWithZipAddressResponse();
    }

    /**
     * Create an instance of {@link FipsToPCodeResponse }
     * 
     */
    public FipsToPCodeResponse createFipsToPCodeResponse() {
        return new FipsToPCodeResponse();
    }

    /**
     * Create an instance of {@link SAUCalcReverseTaxesWithPCodeResponse }
     * 
     */
    public SAUCalcReverseTaxesWithPCodeResponse createSAUCalcReverseTaxesWithPCodeResponse() {
        return new SAUCalcReverseTaxesWithPCodeResponse();
    }

    /**
     * Create an instance of {@link CalcReverseTaxesWithNpaNxx }
     * 
     */
    public CalcReverseTaxesWithNpaNxx createCalcReverseTaxesWithNpaNxx() {
        return new CalcReverseTaxesWithNpaNxx();
    }

    /**
     * Create an instance of {@link CalcAdjWithZipAddress }
     * 
     */
    public CalcAdjWithZipAddress createCalcAdjWithZipAddress() {
        return new CalcAdjWithZipAddress();
    }

    /**
     * Create an instance of {@link SAUCalcReverseAdjWithFipsCodeResponse }
     * 
     */
    public SAUCalcReverseAdjWithFipsCodeResponse createSAUCalcReverseAdjWithFipsCodeResponse() {
        return new SAUCalcReverseAdjWithFipsCodeResponse();
    }

    /**
     * Create an instance of {@link SAUCalcReverseTaxesWithZipAddress }
     * 
     */
    public SAUCalcReverseTaxesWithZipAddress createSAUCalcReverseTaxesWithZipAddress() {
        return new SAUCalcReverseTaxesWithZipAddress();
    }

    /**
     * Create an instance of {@link SAUCalcTaxesWithZipAddressResponse }
     * 
     */
    public SAUCalcTaxesWithZipAddressResponse createSAUCalcTaxesWithZipAddressResponse() {
        return new SAUCalcTaxesWithZipAddressResponse();
    }

    /**
     * Create an instance of {@link SAUCalcTaxesWithFipsCodeResponse }
     * 
     */
    public SAUCalcTaxesWithFipsCodeResponse createSAUCalcTaxesWithFipsCodeResponse() {
        return new SAUCalcTaxesWithFipsCodeResponse();
    }

    /**
     * Create an instance of {@link NpaNxxToPCode }
     * 
     */
    public NpaNxxToPCode createNpaNxxToPCode() {
        return new NpaNxxToPCode();
    }

    /**
     * Create an instance of {@link CalcReverseAdjWithFipsCode }
     * 
     */
    public CalcReverseAdjWithFipsCode createCalcReverseAdjWithFipsCode() {
        return new CalcReverseAdjWithFipsCode();
    }

    /**
     * Create an instance of {@link GetServerTimeResponse }
     * 
     */
    public GetServerTimeResponse createGetServerTimeResponse() {
        return new GetServerTimeResponse();
    }

    /**
     * Create an instance of {@link ZipToPCodeResponse }
     * 
     */
    public ZipToPCodeResponse createZipToPCodeResponse() {
        return new ZipToPCodeResponse();
    }

    /**
     * Create an instance of {@link FipsToPCode }
     * 
     */
    public FipsToPCode createFipsToPCode() {
        return new FipsToPCode();
    }

    /**
     * Create an instance of {@link GetAddress }
     * 
     */
    public GetAddress createGetAddress() {
        return new GetAddress();
    }

    /**
     * Create an instance of {@link CalcAdjWithZipAddressResponse }
     * 
     */
    public CalcAdjWithZipAddressResponse createCalcAdjWithZipAddressResponse() {
        return new CalcAdjWithZipAddressResponse();
    }

    /**
     * Create an instance of {@link CalcReverseTaxesWithZipAddress }
     * 
     */
    public CalcReverseTaxesWithZipAddress createCalcReverseTaxesWithZipAddress() {
        return new CalcReverseTaxesWithZipAddress();
    }

    /**
     * Create an instance of {@link SAUCalcReverseTaxesWithFipsCodeResponse }
     * 
     */
    public SAUCalcReverseTaxesWithFipsCodeResponse createSAUCalcReverseTaxesWithFipsCodeResponse() {
        return new SAUCalcReverseTaxesWithFipsCodeResponse();
    }

    /**
     * Create an instance of {@link CalcReverseTaxesWithPCodeResponse }
     * 
     */
    public CalcReverseTaxesWithPCodeResponse createCalcReverseTaxesWithPCodeResponse() {
        return new CalcReverseTaxesWithPCodeResponse();
    }

    /**
     * Create an instance of {@link SAUCalcTaxesWithZipAddress }
     * 
     */
    public SAUCalcTaxesWithZipAddress createSAUCalcTaxesWithZipAddress() {
        return new SAUCalcTaxesWithZipAddress();
    }

    /**
     * Create an instance of {@link SAUCalcAdjWithFipsCode }
     * 
     */
    public SAUCalcAdjWithFipsCode createSAUCalcAdjWithFipsCode() {
        return new SAUCalcAdjWithFipsCode();
    }

    /**
     * Create an instance of {@link SAUCalcTaxesAndAdjWithZipAddressInCustMode }
     * 
     */
    public SAUCalcTaxesAndAdjWithZipAddressInCustMode createSAUCalcTaxesAndAdjWithZipAddressInCustMode() {
        return new SAUCalcTaxesAndAdjWithZipAddressInCustMode();
    }

    /**
     * Create an instance of {@link CalcReverseAdjWithNpaNxx }
     * 
     */
    public CalcReverseAdjWithNpaNxx createCalcReverseAdjWithNpaNxx() {
        return new CalcReverseAdjWithNpaNxx();
    }

    /**
     * Create an instance of {@link CalcReverseAdjWithZipAddress }
     * 
     */
    public CalcReverseAdjWithZipAddress createCalcReverseAdjWithZipAddress() {
        return new CalcReverseAdjWithZipAddress();
    }

    /**
     * Create an instance of {@link GetTaxDescription }
     * 
     */
    public GetTaxDescription createGetTaxDescription() {
        return new GetTaxDescription();
    }

    /**
     * Create an instance of {@link CalcReverseTaxesWithZipAddressResponse }
     * 
     */
    public CalcReverseTaxesWithZipAddressResponse createCalcReverseTaxesWithZipAddressResponse() {
        return new CalcReverseTaxesWithZipAddressResponse();
    }

    /**
     * Create an instance of {@link SAUCalcTaxesAndAdjWithZipAddressInCustModeResponse }
     * 
     */
    public SAUCalcTaxesAndAdjWithZipAddressInCustModeResponse createSAUCalcTaxesAndAdjWithZipAddressInCustModeResponse() {
        return new SAUCalcTaxesAndAdjWithZipAddressInCustModeResponse();
    }

    /**
     * Create an instance of {@link ArrayOfCustomerTaxData }
     * 
     */
    public ArrayOfCustomerTaxData createArrayOfCustomerTaxData() {
        return new ArrayOfCustomerTaxData();
    }

    /**
     * Create an instance of {@link SAUCalcReverseTaxesWithFipsCode }
     * 
     */
    public SAUCalcReverseTaxesWithFipsCode createSAUCalcReverseTaxesWithFipsCode() {
        return new SAUCalcReverseTaxesWithFipsCode();
    }

    /**
     * Create an instance of {@link CalcReverseAdjWithZipAddressResponse }
     * 
     */
    public CalcReverseAdjWithZipAddressResponse createCalcReverseAdjWithZipAddressResponse() {
        return new CalcReverseAdjWithZipAddressResponse();
    }

    /**
     * Create an instance of {@link SAUCalcTaxesAndAdjWithPCodeInCustModeResponse }
     * 
     */
    public SAUCalcTaxesAndAdjWithPCodeInCustModeResponse createSAUCalcTaxesAndAdjWithPCodeInCustModeResponse() {
        return new SAUCalcTaxesAndAdjWithPCodeInCustModeResponse();
    }

    /**
     * Create an instance of {@link SAUCalcReverseAdjWithZipAddress }
     * 
     */
    public SAUCalcReverseAdjWithZipAddress createSAUCalcReverseAdjWithZipAddress() {
        return new SAUCalcReverseAdjWithZipAddress();
    }

    /**
     * Create an instance of {@link CalcAdjWithNpaNxx }
     * 
     */
    public CalcAdjWithNpaNxx createCalcAdjWithNpaNxx() {
        return new CalcAdjWithNpaNxx();
    }

    /**
     * Create an instance of {@link CalcTaxesWithPCode }
     * 
     */
    public CalcTaxesWithPCode createCalcTaxesWithPCode() {
        return new CalcTaxesWithPCode();
    }

    /**
     * Create an instance of {@link CalcReverseTaxesWithPCode }
     * 
     */
    public CalcReverseTaxesWithPCode createCalcReverseTaxesWithPCode() {
        return new CalcReverseTaxesWithPCode();
    }

    /**
     * Create an instance of {@link SAUCalcReverseAdjWithPCodeResponse }
     * 
     */
    public SAUCalcReverseAdjWithPCodeResponse createSAUCalcReverseAdjWithPCodeResponse() {
        return new SAUCalcReverseAdjWithPCodeResponse();
    }

    /**
     * Create an instance of {@link SAUCalcReverseTaxesWithZipAddressResponse }
     * 
     */
    public SAUCalcReverseTaxesWithZipAddressResponse createSAUCalcReverseTaxesWithZipAddressResponse() {
        return new SAUCalcReverseTaxesWithZipAddressResponse();
    }

    /**
     * Create an instance of {@link NpaNxxToPCodeResponse }
     * 
     */
    public NpaNxxToPCodeResponse createNpaNxxToPCodeResponse() {
        return new NpaNxxToPCodeResponse();
    }

    /**
     * Create an instance of {@link GetTaxCategory }
     * 
     */
    public GetTaxCategory createGetTaxCategory() {
        return new GetTaxCategory();
    }

    /**
     * Create an instance of {@link SAUCalcReverseAdjWithFipsCode }
     * 
     */
    public SAUCalcReverseAdjWithFipsCode createSAUCalcReverseAdjWithFipsCode() {
        return new SAUCalcReverseAdjWithFipsCode();
    }

    /**
     * Create an instance of {@link CalcReverseAdjWithPCode }
     * 
     */
    public CalcReverseAdjWithPCode createCalcReverseAdjWithPCode() {
        return new CalcReverseAdjWithPCode();
    }

    /**
     * Create an instance of {@link SAUCalcAdjWithPCode }
     * 
     */
    public SAUCalcAdjWithPCode createSAUCalcAdjWithPCode() {
        return new SAUCalcAdjWithPCode();
    }

    /**
     * Create an instance of {@link SAUCalcReverseTaxesWithPCode }
     * 
     */
    public SAUCalcReverseTaxesWithPCode createSAUCalcReverseTaxesWithPCode() {
        return new SAUCalcReverseTaxesWithPCode();
    }

    /**
     * Create an instance of {@link PCodeToFipsResponse }
     * 
     */
    public PCodeToFipsResponse createPCodeToFipsResponse() {
        return new PCodeToFipsResponse();
    }

    /**
     * Create an instance of {@link CalcReverseAdjWithPCodeResponse }
     * 
     */
    public CalcReverseAdjWithPCodeResponse createCalcReverseAdjWithPCodeResponse() {
        return new CalcReverseAdjWithPCodeResponse();
    }

    /**
     * Create an instance of {@link SAUCalcTaxesWithPCode }
     * 
     */
    public SAUCalcTaxesWithPCode createSAUCalcTaxesWithPCode() {
        return new SAUCalcTaxesWithPCode();
    }

    /**
     * Create an instance of {@link PCodeToFips }
     * 
     */
    public PCodeToFips createPCodeToFips() {
        return new PCodeToFips();
    }

    /**
     * Create an instance of {@link ZipToPCode }
     * 
     */
    public ZipToPCode createZipToPCode() {
        return new ZipToPCode();
    }

    /**
     * Create an instance of {@link ZipAddress }
     * 
     */
    public ZipAddress createZipAddress() {
        return new ZipAddress();
    }

    /**
     * Create an instance of {@link SAUCalcTaxesWithFipsCode }
     * 
     */
    public SAUCalcTaxesWithFipsCode createSAUCalcTaxesWithFipsCode() {
        return new SAUCalcTaxesWithFipsCode();
    }

    /**
     * Create an instance of {@link CalcReverseTaxesWithFipsCodeResponse }
     * 
     */
    public CalcReverseTaxesWithFipsCodeResponse createCalcReverseTaxesWithFipsCodeResponse() {
        return new CalcReverseTaxesWithFipsCodeResponse();
    }

    /**
     * Create an instance of {@link CalcAdjWithFipsCode }
     * 
     */
    public CalcAdjWithFipsCode createCalcAdjWithFipsCode() {
        return new CalcAdjWithFipsCode();
    }

    /**
     * Create an instance of {@link CalcTaxesWithZipAddress }
     * 
     */
    public CalcTaxesWithZipAddress createCalcTaxesWithZipAddress() {
        return new CalcTaxesWithZipAddress();
    }

    /**
     * Create an instance of {@link CalcAdjWithPCodeResponse }
     * 
     */
    public CalcAdjWithPCodeResponse createCalcAdjWithPCodeResponse() {
        return new CalcAdjWithPCodeResponse();
    }

    /**
     * Create an instance of {@link CalcAdjWithFipsCodeResponse }
     * 
     */
    public CalcAdjWithFipsCodeResponse createCalcAdjWithFipsCodeResponse() {
        return new CalcAdjWithFipsCodeResponse();
    }

    /**
     * Create an instance of {@link CalcAdjWithPCode }
     * 
     */
    public CalcAdjWithPCode createCalcAdjWithPCode() {
        return new CalcAdjWithPCode();
    }

    /**
     * Create an instance of {@link CalcReverseAdjWithFipsCodeResponse }
     * 
     */
    public CalcReverseAdjWithFipsCodeResponse createCalcReverseAdjWithFipsCodeResponse() {
        return new CalcReverseAdjWithFipsCodeResponse();
    }

    /**
     * Create an instance of {@link CalcTaxesWithPCodeResponse }
     * 
     */
    public CalcTaxesWithPCodeResponse createCalcTaxesWithPCodeResponse() {
        return new CalcTaxesWithPCodeResponse();
    }

    /**
     * Create an instance of {@link GetTaxCategoryResponse }
     * 
     */
    public GetTaxCategoryResponse createGetTaxCategoryResponse() {
        return new GetTaxCategoryResponse();
    }

    /**
     * Create an instance of {@link CalcAdjWithNpaNxxResponse }
     * 
     */
    public CalcAdjWithNpaNxxResponse createCalcAdjWithNpaNxxResponse() {
        return new CalcAdjWithNpaNxxResponse();
    }

    /**
     * Create an instance of {@link GetAddressResponse }
     * 
     */
    public GetAddressResponse createGetAddressResponse() {
        return new GetAddressResponse();
    }

    /**
     * Create an instance of {@link ArrayOfAddressData }
     * 
     */
    public ArrayOfAddressData createArrayOfAddressData() {
        return new ArrayOfAddressData();
    }

    /**
     * Create an instance of {@link CalcTaxesWithNpaNxx }
     * 
     */
    public CalcTaxesWithNpaNxx createCalcTaxesWithNpaNxx() {
        return new CalcTaxesWithNpaNxx();
    }

    /**
     * Create an instance of {@link SAUCalcAdjWithZipAddress }
     * 
     */
    public SAUCalcAdjWithZipAddress createSAUCalcAdjWithZipAddress() {
        return new SAUCalcAdjWithZipAddress();
    }

    /**
     * Create an instance of {@link CalcReverseTaxesWithNpaNxxResponse }
     * 
     */
    public CalcReverseTaxesWithNpaNxxResponse createCalcReverseTaxesWithNpaNxxResponse() {
        return new CalcReverseTaxesWithNpaNxxResponse();
    }

    /**
     * Create an instance of {@link GetTaxDescriptionResponse }
     * 
     */
    public GetTaxDescriptionResponse createGetTaxDescriptionResponse() {
        return new GetTaxDescriptionResponse();
    }

    /**
     * Create an instance of {@link CalcTaxesWithZipAddressResponse }
     * 
     */
    public CalcTaxesWithZipAddressResponse createCalcTaxesWithZipAddressResponse() {
        return new CalcTaxesWithZipAddressResponse();
    }

    /**
     * Create an instance of {@link CalcTaxesWithFipsCode }
     * 
     */
    public CalcTaxesWithFipsCode createCalcTaxesWithFipsCode() {
        return new CalcTaxesWithFipsCode();
    }

    /**
     * Create an instance of {@link SAUCalcAdjWithFipsCodeResponse }
     * 
     */
    public SAUCalcAdjWithFipsCodeResponse createSAUCalcAdjWithFipsCodeResponse() {
        return new SAUCalcAdjWithFipsCodeResponse();
    }

    /**
     * Create an instance of {@link SAUCalcAdjWithZipAddressResponse }
     * 
     */
    public SAUCalcAdjWithZipAddressResponse createSAUCalcAdjWithZipAddressResponse() {
        return new SAUCalcAdjWithZipAddressResponse();
    }

    /**
     * Create an instance of {@link SAUCalcTaxesAndAdjWithFipsCodeInCustModeResponse }
     * 
     */
    public SAUCalcTaxesAndAdjWithFipsCodeInCustModeResponse createSAUCalcTaxesAndAdjWithFipsCodeInCustModeResponse() {
        return new SAUCalcTaxesAndAdjWithFipsCodeInCustModeResponse();
    }

    /**
     * Create an instance of {@link GetServerTime }
     * 
     */
    public GetServerTime createGetServerTime() {
        return new GetServerTime();
    }

    /**
     * Create an instance of {@link CalcTaxesWithNpaNxxResponse }
     * 
     */
    public CalcTaxesWithNpaNxxResponse createCalcTaxesWithNpaNxxResponse() {
        return new CalcTaxesWithNpaNxxResponse();
    }

    /**
     * Create an instance of {@link CalcTaxesWithFipsCodeResponse }
     * 
     */
    public CalcTaxesWithFipsCodeResponse createCalcTaxesWithFipsCodeResponse() {
        return new CalcTaxesWithFipsCodeResponse();
    }

    /**
     * Create an instance of {@link SAUCalcTaxesAndAdjWithFipsCodeInCustMode }
     * 
     */
    public SAUCalcTaxesAndAdjWithFipsCodeInCustMode createSAUCalcTaxesAndAdjWithFipsCodeInCustMode() {
        return new SAUCalcTaxesAndAdjWithFipsCodeInCustMode();
    }

    /**
     * Create an instance of {@link SAUCalcTaxesWithPCodeResponse }
     * 
     */
    public SAUCalcTaxesWithPCodeResponse createSAUCalcTaxesWithPCodeResponse() {
        return new SAUCalcTaxesWithPCodeResponse();
    }

    /**
     * Create an instance of {@link ShipAndHandlingAttributes }
     * 
     */
    public ShipAndHandlingAttributes createShipAndHandlingAttributes() {
        return new ShipAndHandlingAttributes();
    }

    /**
     * Create an instance of {@link AddressData }
     * 
     */
    public AddressData createAddressData() {
        return new AddressData();
    }

    /**
     * Create an instance of {@link DemurrageAttributes }
     * 
     */
    public DemurrageAttributes createDemurrageAttributes() {
        return new DemurrageAttributes();
    }

    /**
     * Create an instance of {@link CustomerTaxData }
     * 
     */
    public CustomerTaxData createCustomerTaxData() {
        return new CustomerTaxData();
    }

    /**
     * Create an instance of {@link TaxData }
     * 
     */
    public TaxData createTaxData() {
        return new TaxData();
    }

    /**
     * Create an instance of {@link FactoryWarrantyAttributes }
     * 
     */
    public FactoryWarrantyAttributes createFactoryWarrantyAttributes() {
        return new FactoryWarrantyAttributes();
    }

    /**
     * Create an instance of {@link DiscountAttributes }
     * 
     */
    public DiscountAttributes createDiscountAttributes() {
        return new DiscountAttributes();
    }

    /**
     * Create an instance of {@link InstallationAttributes }
     * 
     */
    public InstallationAttributes createInstallationAttributes() {
        return new InstallationAttributes();
    }

    /**
     * Create an instance of {@link TaxExemption }
     * 
     */
    public TaxExemption createTaxExemption() {
        return new TaxExemption();
    }

    /**
     * Create an instance of {@link MaintAgreementAttributes }
     * 
     */
    public MaintAgreementAttributes createMaintAgreementAttributes() {
        return new MaintAgreementAttributes();
    }

    /**
     * Create an instance of {@link ExtWarrantyAttributes }
     * 
     */
    public ExtWarrantyAttributes createExtWarrantyAttributes() {
        return new ExtWarrantyAttributes();
    }

    /**
     * Create an instance of {@link Exclusion }
     * 
     */
    public Exclusion createExclusion() {
        return new Exclusion();
    }

    /**
     * Create an instance of {@link ServiceContractAttributes }
     * 
     */
    public ServiceContractAttributes createServiceContractAttributes() {
        return new ServiceContractAttributes();
    }

    /**
     * Create an instance of {@link ArrayOfTaxExemption }
     * 
     */
    public ArrayOfTaxExemption createArrayOfTaxExemption() {
        return new ArrayOfTaxExemption();
    }

    /**
     * Create an instance of {@link SoftwareMaintAttributes }
     * 
     */
    public SoftwareMaintAttributes createSoftwareMaintAttributes() {
        return new SoftwareMaintAttributes();
    }

    /**
     * Create an instance of {@link TradeInAttributes }
     * 
     */
    public TradeInAttributes createTradeInAttributes() {
        return new TradeInAttributes();
    }

    /**
     * Create an instance of {@link FinanceAttributes }
     * 
     */
    public FinanceAttributes createFinanceAttributes() {
        return new FinanceAttributes();
    }

    /**
     * Create an instance of {@link FreightAttributes }
     * 
     */
    public FreightAttributes createFreightAttributes() {
        return new FreightAttributes();
    }

    /**
     * Create an instance of {@link Nexus }
     * 
     */
    public Nexus createNexus() {
        return new Nexus();
    }

    /**
     * Create an instance of {@link DefaultAttributes }
     * 
     */
    public DefaultAttributes createDefaultAttributes() {
        return new DefaultAttributes();
    }

    /**
     * Create an instance of {@link DepositAttributes }
     * 
     */
    public DepositAttributes createDepositAttributes() {
        return new DepositAttributes();
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "anyURI")
    public JAXBElement<String> createAnyURI(String value) {
        return new JAXBElement<String>(_AnyURI_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link InstallationAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "InstallationAttributes")
    public JAXBElement<InstallationAttributes> createInstallationAttributes(InstallationAttributes value) {
        return new JAXBElement<InstallationAttributes>(_InstallationAttributes_QNAME, InstallationAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link TaxExemption }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "TaxExemption")
    public JAXBElement<TaxExemption> createTaxExemption(TaxExemption value) {
        return new JAXBElement<TaxExemption>(_TaxExemption_QNAME, TaxExemption.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Integer }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "char")
    public JAXBElement<Integer> createChar(Integer value) {
        return new JAXBElement<Integer>(_Char_QNAME, Integer.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link AddressData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "AddressData")
    public JAXBElement<AddressData> createAddressData(AddressData value) {
        return new JAXBElement<AddressData>(_AddressData_QNAME, AddressData.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Float }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "float")
    public JAXBElement<Float> createFloat(Float value) {
        return new JAXBElement<Float>(_Float_QNAME, Float.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link FactoryWarrantyAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "FactoryWarrantyAttributes")
    public JAXBElement<FactoryWarrantyAttributes> createFactoryWarrantyAttributes(FactoryWarrantyAttributes value) {
        return new JAXBElement<FactoryWarrantyAttributes>(_FactoryWarrantyAttributes_QNAME, FactoryWarrantyAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "long")
    public JAXBElement<Long> createLong(Long value) {
        return new JAXBElement<Long>(_Long_QNAME, Long.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link DiscountAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "DiscountAttributes")
    public JAXBElement<DiscountAttributes> createDiscountAttributes(DiscountAttributes value) {
        return new JAXBElement<DiscountAttributes>(_DiscountAttributes_QNAME, DiscountAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link byte[]}{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "base64Binary")
    public JAXBElement<byte[]> createBase64Binary(byte[] value) {
        return new JAXBElement<byte[]>(_Base64Binary_QNAME, byte[].class, null, ((byte[]) value));
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Byte }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "byte")
    public JAXBElement<Byte> createByte(Byte value) {
        return new JAXBElement<Byte>(_Byte_QNAME, Byte.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ShipAndHandlingAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ShipAndHandlingAttributes")
    public JAXBElement<ShipAndHandlingAttributes> createShipAndHandlingAttributes(ShipAndHandlingAttributes value) {
        return new JAXBElement<ShipAndHandlingAttributes>(_ShipAndHandlingAttributes_QNAME, ShipAndHandlingAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "SalesUseTransaction")
    public JAXBElement<SalesUseTransaction> createSalesUseTransaction(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_SalesUseTransaction_QNAME, SalesUseTransaction.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Boolean }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "boolean")
    public JAXBElement<Boolean> createBoolean(Boolean value) {
        return new JAXBElement<Boolean>(_Boolean_QNAME, Boolean.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfAddressData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ArrayOfAddressData")
    public JAXBElement<ArrayOfAddressData> createArrayOfAddressData(ArrayOfAddressData value) {
        return new JAXBElement<ArrayOfAddressData>(_ArrayOfAddressData_QNAME, ArrayOfAddressData.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link TradeInAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "TradeInAttributes")
    public JAXBElement<TradeInAttributes> createTradeInAttributes(TradeInAttributes value) {
        return new JAXBElement<TradeInAttributes>(_TradeInAttributes_QNAME, TradeInAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfSalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ArrayOfSalesUseTransaction")
    public JAXBElement<ArrayOfSalesUseTransaction> createArrayOfSalesUseTransaction(ArrayOfSalesUseTransaction value) {
        return new JAXBElement<ArrayOfSalesUseTransaction>(_ArrayOfSalesUseTransaction_QNAME, ArrayOfSalesUseTransaction.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link FinanceAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "FinanceAttributes")
    public JAXBElement<FinanceAttributes> createFinanceAttributes(FinanceAttributes value) {
        return new JAXBElement<FinanceAttributes>(_FinanceAttributes_QNAME, FinanceAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ArrayOfNexus")
    public JAXBElement<ArrayOfNexus> createArrayOfNexus(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_ArrayOfNexus_QNAME, ArrayOfNexus.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Nexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "Nexus")
    public JAXBElement<Nexus> createNexus(Nexus value) {
        return new JAXBElement<Nexus>(_Nexus_QNAME, Nexus.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Short }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "unsignedByte")
    public JAXBElement<Short> createUnsignedByte(Short value) {
        return new JAXBElement<Short>(_UnsignedByte_QNAME, Short.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ArrayOfExclusion")
    public JAXBElement<ArrayOfExclusion> createArrayOfExclusion(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_ArrayOfExclusion_QNAME, ArrayOfExclusion.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Object }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "anyType")
    public JAXBElement<Object> createAnyType(Object value) {
        return new JAXBElement<Object>(_AnyType_QNAME, Object.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Integer }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "int")
    public JAXBElement<Integer> createInt(Integer value) {
        return new JAXBElement<Integer>(_Int_QNAME, Integer.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ZipAddress")
    public JAXBElement<ZipAddress> createZipAddress(ZipAddress value) {
        return new JAXBElement<ZipAddress>(_ZipAddress_QNAME, ZipAddress.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SoftwareMaintAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "SoftwareMaintAttributes")
    public JAXBElement<SoftwareMaintAttributes> createSoftwareMaintAttributes(SoftwareMaintAttributes value) {
        return new JAXBElement<SoftwareMaintAttributes>(_SoftwareMaintAttributes_QNAME, SoftwareMaintAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Double }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "double")
    public JAXBElement<Double> createDouble(Double value) {
        return new JAXBElement<Double>(_Double_QNAME, Double.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Exclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "Exclusion")
    public JAXBElement<Exclusion> createExclusion(Exclusion value) {
        return new JAXBElement<Exclusion>(_Exclusion_QNAME, Exclusion.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfCustomerTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ArrayOfCustomerTaxData")
    public JAXBElement<ArrayOfCustomerTaxData> createArrayOfCustomerTaxData(ArrayOfCustomerTaxData value) {
        return new JAXBElement<ArrayOfCustomerTaxData>(_ArrayOfCustomerTaxData_QNAME, ArrayOfCustomerTaxData.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ArrayOfTaxData")
    public JAXBElement<ArrayOfTaxData> createArrayOfTaxData(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_ArrayOfTaxData_QNAME, ArrayOfTaxData.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link XMLGregorianCalendar }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "dateTime")
    public JAXBElement<XMLGregorianCalendar> createDateTime(XMLGregorianCalendar value) {
        return new JAXBElement<XMLGregorianCalendar>(_DateTime_QNAME, XMLGregorianCalendar.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link QName }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "QName")
    public JAXBElement<QName> createQName(QName value) {
        return new JAXBElement<QName>(_QName_QNAME, QName.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link CustomerTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CustomerTaxData")
    public JAXBElement<CustomerTaxData> createCustomerTaxData(CustomerTaxData value) {
        return new JAXBElement<CustomerTaxData>(_CustomerTaxData_QNAME, CustomerTaxData.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Integer }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "unsignedShort")
    public JAXBElement<Integer> createUnsignedShort(Integer value) {
        return new JAXBElement<Integer>(_UnsignedShort_QNAME, Integer.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link DemurrageAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "DemurrageAttributes")
    public JAXBElement<DemurrageAttributes> createDemurrageAttributes(DemurrageAttributes value) {
        return new JAXBElement<DemurrageAttributes>(_DemurrageAttributes_QNAME, DemurrageAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link TaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "TaxData")
    public JAXBElement<TaxData> createTaxData(TaxData value) {
        return new JAXBElement<TaxData>(_TaxData_QNAME, TaxData.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Short }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "short")
    public JAXBElement<Short> createShort(Short value) {
        return new JAXBElement<Short>(_Short_QNAME, Short.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link FreightAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "FreightAttributes")
    public JAXBElement<FreightAttributes> createFreightAttributes(FreightAttributes value) {
        return new JAXBElement<FreightAttributes>(_FreightAttributes_QNAME, FreightAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link DepositAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "DepositAttributes")
    public JAXBElement<DepositAttributes> createDepositAttributes(DepositAttributes value) {
        return new JAXBElement<DepositAttributes>(_DepositAttributes_QNAME, DepositAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link DefaultAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "DefaultAttributes")
    public JAXBElement<DefaultAttributes> createDefaultAttributes(DefaultAttributes value) {
        return new JAXBElement<DefaultAttributes>(_DefaultAttributes_QNAME, DefaultAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "unsignedInt")
    public JAXBElement<Long> createUnsignedInt(Long value) {
        return new JAXBElement<Long>(_UnsignedInt_QNAME, Long.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxExemption }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ArrayOfTaxExemption")
    public JAXBElement<ArrayOfTaxExemption> createArrayOfTaxExemption(ArrayOfTaxExemption value) {
        return new JAXBElement<ArrayOfTaxExemption>(_ArrayOfTaxExemption_QNAME, ArrayOfTaxExemption.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link BigDecimal }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "decimal")
    public JAXBElement<BigDecimal> createDecimal(BigDecimal value) {
        return new JAXBElement<BigDecimal>(_Decimal_QNAME, BigDecimal.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "guid")
    public JAXBElement<String> createGuid(String value) {
        return new JAXBElement<String>(_Guid_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Duration }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "duration")
    public JAXBElement<Duration> createDuration(Duration value) {
        return new JAXBElement<Duration>(_Duration_QNAME, Duration.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ReverseTaxResults")
    public JAXBElement<ReverseTaxResults> createReverseTaxResults(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_ReverseTaxResults_QNAME, ReverseTaxResults.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "string")
    public JAXBElement<String> createString(String value) {
        return new JAXBElement<String>(_String_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ServiceContractAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ServiceContractAttributes")
    public JAXBElement<ServiceContractAttributes> createServiceContractAttributes(ServiceContractAttributes value) {
        return new JAXBElement<ServiceContractAttributes>(_ServiceContractAttributes_QNAME, ServiceContractAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link MaintAgreementAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "MaintAgreementAttributes")
    public JAXBElement<MaintAgreementAttributes> createMaintAgreementAttributes(MaintAgreementAttributes value) {
        return new JAXBElement<MaintAgreementAttributes>(_MaintAgreementAttributes_QNAME, MaintAgreementAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link BigInteger }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.microsoft.com/2003/10/Serialization/", name = "unsignedLong")
    public JAXBElement<BigInteger> createUnsignedLong(BigInteger value) {
        return new JAXBElement<BigInteger>(_UnsignedLong_QNAME, BigInteger.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "Transaction")
    public JAXBElement<Transaction> createTransaction(Transaction value) {
        return new JAXBElement<Transaction>(_Transaction_QNAME, Transaction.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ExtWarrantyAttributes }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ExtWarrantyAttributes")
    public JAXBElement<ExtWarrantyAttributes> createExtWarrantyAttributes(ExtWarrantyAttributes value) {
        return new JAXBElement<ExtWarrantyAttributes>(_ExtWarrantyAttributes_QNAME, ExtWarrantyAttributes.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "GetTaxCategoryResult", scope = GetTaxCategoryResponse.class)
    public JAXBElement<String> createGetTaxCategoryResponseGetTaxCategoryResult(String value) {
        return new JAXBElement<String>(_GetTaxCategoryResponseGetTaxCategoryResult_QNAME, String.class, GetTaxCategoryResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = CalcReverseAdjWithNpaNxx.class)
    public JAXBElement<Transaction> createCalcReverseAdjWithNpaNxxAnAdjustment(Transaction value) {
        return new JAXBElement<Transaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, Transaction.class, CalcReverseAdjWithNpaNxx.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcReverseTaxesWithFipsCodeResult", scope = CalcReverseTaxesWithFipsCodeResponse.class)
    public JAXBElement<ReverseTaxResults> createCalcReverseTaxesWithFipsCodeResponseCalcReverseTaxesWithFipsCodeResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_CalcReverseTaxesWithFipsCodeResponseCalcReverseTaxesWithFipsCodeResult_QNAME, ReverseTaxResults.class, CalcReverseTaxesWithFipsCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aFips", scope = FipsToPCode.class)
    public JAXBElement<String> createFipsToPCodeAFips(String value) {
        return new JAXBElement<String>(_FipsToPCodeAFips_QNAME, String.class, FipsToPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfSalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustmentList", scope = SAUCalcTaxesAndAdjWithPCodeInCustMode.class)
    public JAXBElement<ArrayOfSalesUseTransaction> createSAUCalcTaxesAndAdjWithPCodeInCustModeAnAdjustmentList(ArrayOfSalesUseTransaction value) {
        return new JAXBElement<ArrayOfSalesUseTransaction>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnAdjustmentList_QNAME, ArrayOfSalesUseTransaction.class, SAUCalcTaxesAndAdjWithPCodeInCustMode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfSalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransactionList", scope = SAUCalcTaxesAndAdjWithPCodeInCustMode.class)
    public JAXBElement<ArrayOfSalesUseTransaction> createSAUCalcTaxesAndAdjWithPCodeInCustModeATransactionList(ArrayOfSalesUseTransaction value) {
        return new JAXBElement<ArrayOfSalesUseTransaction>(_SAUCalcTaxesAndAdjWithPCodeInCustModeATransactionList_QNAME, ArrayOfSalesUseTransaction.class, SAUCalcTaxesAndAdjWithPCodeInCustMode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcTaxesAndAdjWithPCodeInCustMode.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcTaxesAndAdjWithPCodeInCustMode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcTaxesAndAdjWithPCodeInCustMode.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcTaxesAndAdjWithPCodeInCustModeANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcTaxesAndAdjWithPCodeInCustMode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = SAUCalcTaxesWithFipsCode.class)
    public JAXBElement<SalesUseTransaction> createSAUCalcTaxesWithFipsCodeATransaction(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, SalesUseTransaction.class, SAUCalcTaxesWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcTaxesWithFipsCode.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcTaxesWithFipsCodeAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcTaxesWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcTaxesWithFipsCode.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcTaxesWithFipsCodeANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcTaxesWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "PCodeToFipsResult", scope = PCodeToFipsResponse.class)
    public JAXBElement<String> createPCodeToFipsResponsePCodeToFipsResult(String value) {
        return new JAXBElement<String>(_PCodeToFipsResponsePCodeToFipsResult_QNAME, String.class, PCodeToFipsResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = CalcReverseAdjWithZipAddress.class)
    public JAXBElement<Transaction> createCalcReverseAdjWithZipAddressAnAdjustment(Transaction value) {
        return new JAXBElement<Transaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, Transaction.class, CalcReverseAdjWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = CalcReverseAdjWithPCode.class)
    public JAXBElement<Transaction> createCalcReverseAdjWithPCodeAnAdjustment(Transaction value) {
        return new JAXBElement<Transaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, Transaction.class, CalcReverseAdjWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcTaxesWithNpaNxxResult", scope = CalcTaxesWithNpaNxxResponse.class)
    public JAXBElement<ArrayOfTaxData> createCalcTaxesWithNpaNxxResponseCalcTaxesWithNpaNxxResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_CalcTaxesWithNpaNxxResponseCalcTaxesWithNpaNxxResult_QNAME, ArrayOfTaxData.class, CalcTaxesWithNpaNxxResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcReverseTaxesWithZipAddressResult", scope = CalcReverseTaxesWithZipAddressResponse.class)
    public JAXBElement<ReverseTaxResults> createCalcReverseTaxesWithZipAddressResponseCalcReverseTaxesWithZipAddressResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_CalcReverseTaxesWithZipAddressResponseCalcReverseTaxesWithZipAddressResult_QNAME, ReverseTaxResults.class, CalcReverseTaxesWithZipAddressResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = SAUCalcReverseTaxesWithPCode.class)
    public JAXBElement<SalesUseTransaction> createSAUCalcReverseTaxesWithPCodeATransaction(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, SalesUseTransaction.class, SAUCalcReverseTaxesWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcReverseTaxesWithPCode.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcReverseTaxesWithPCodeAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcReverseTaxesWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcReverseTaxesWithPCode.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcReverseTaxesWithPCodeANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcReverseTaxesWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcReverseTaxesWithPCodeResult", scope = CalcReverseTaxesWithPCodeResponse.class)
    public JAXBElement<ReverseTaxResults> createCalcReverseTaxesWithPCodeResponseCalcReverseTaxesWithPCodeResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_CalcReverseTaxesWithPCodeResponseCalcReverseTaxesWithPCodeResult_QNAME, ReverseTaxResults.class, CalcReverseTaxesWithPCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcAdjWithPCode.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcAdjWithPCodeAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcAdjWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = SAUCalcAdjWithPCode.class)
    public JAXBElement<SalesUseTransaction> createSAUCalcAdjWithPCodeAnAdjustment(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, SalesUseTransaction.class, SAUCalcAdjWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcAdjWithPCode.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcAdjWithPCodeANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcAdjWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcReverseAdjWithZipAddressResult", scope = SAUCalcReverseAdjWithZipAddressResponse.class)
    public JAXBElement<ReverseTaxResults> createSAUCalcReverseAdjWithZipAddressResponseSAUCalcReverseAdjWithZipAddressResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_SAUCalcReverseAdjWithZipAddressResponseSAUCalcReverseAdjWithZipAddressResult_QNAME, ReverseTaxResults.class, SAUCalcReverseAdjWithZipAddressResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcAdjWithFipsCode.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcAdjWithFipsCodeAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcAdjWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = SAUCalcAdjWithFipsCode.class)
    public JAXBElement<SalesUseTransaction> createSAUCalcAdjWithFipsCodeAnAdjustment(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, SalesUseTransaction.class, SAUCalcAdjWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcAdjWithFipsCode.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcAdjWithFipsCodeANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcAdjWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = CalcAdjWithNpaNxx.class)
    public JAXBElement<Transaction> createCalcAdjWithNpaNxxAnAdjustment(Transaction value) {
        return new JAXBElement<Transaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, Transaction.class, CalcAdjWithNpaNxx.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfCustomerTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcTaxesAndAdjWithZipAddressInCustModeResult", scope = SAUCalcTaxesAndAdjWithZipAddressInCustModeResponse.class)
    public JAXBElement<ArrayOfCustomerTaxData> createSAUCalcTaxesAndAdjWithZipAddressInCustModeResponseSAUCalcTaxesAndAdjWithZipAddressInCustModeResult(ArrayOfCustomerTaxData value) {
        return new JAXBElement<ArrayOfCustomerTaxData>(_SAUCalcTaxesAndAdjWithZipAddressInCustModeResponseSAUCalcTaxesAndAdjWithZipAddressInCustModeResult_QNAME, ArrayOfCustomerTaxData.class, SAUCalcTaxesAndAdjWithZipAddressInCustModeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = CalcTaxesWithFipsCode.class)
    public JAXBElement<Transaction> createCalcTaxesWithFipsCodeATransaction(Transaction value) {
        return new JAXBElement<Transaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, Transaction.class, CalcTaxesWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = SAUCalcReverseTaxesWithZipAddress.class)
    public JAXBElement<SalesUseTransaction> createSAUCalcReverseTaxesWithZipAddressATransaction(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, SalesUseTransaction.class, SAUCalcReverseTaxesWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcReverseTaxesWithZipAddress.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcReverseTaxesWithZipAddressAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcReverseTaxesWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcReverseTaxesWithZipAddress.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcReverseTaxesWithZipAddressANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcReverseTaxesWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcReverseTaxesWithPCodeResult", scope = SAUCalcReverseTaxesWithPCodeResponse.class)
    public JAXBElement<ReverseTaxResults> createSAUCalcReverseTaxesWithPCodeResponseSAUCalcReverseTaxesWithPCodeResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_SAUCalcReverseTaxesWithPCodeResponseSAUCalcReverseTaxesWithPCodeResult_QNAME, ReverseTaxResults.class, SAUCalcReverseTaxesWithPCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = CalcReverseTaxesWithNpaNxx.class)
    public JAXBElement<Transaction> createCalcReverseTaxesWithNpaNxxATransaction(Transaction value) {
        return new JAXBElement<Transaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, Transaction.class, CalcReverseTaxesWithNpaNxx.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcReverseTaxesWithFipsCodeResult", scope = SAUCalcReverseTaxesWithFipsCodeResponse.class)
    public JAXBElement<ReverseTaxResults> createSAUCalcReverseTaxesWithFipsCodeResponseSAUCalcReverseTaxesWithFipsCodeResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_SAUCalcReverseTaxesWithFipsCodeResponseSAUCalcReverseTaxesWithFipsCodeResult_QNAME, ReverseTaxResults.class, SAUCalcReverseTaxesWithFipsCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcReverseAdjWithNpaNxxResult", scope = CalcReverseAdjWithNpaNxxResponse.class)
    public JAXBElement<ReverseTaxResults> createCalcReverseAdjWithNpaNxxResponseCalcReverseAdjWithNpaNxxResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_CalcReverseAdjWithNpaNxxResponseCalcReverseAdjWithNpaNxxResult_QNAME, ReverseTaxResults.class, CalcReverseAdjWithNpaNxxResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcReverseTaxesWithNpaNxxResult", scope = CalcReverseTaxesWithNpaNxxResponse.class)
    public JAXBElement<ReverseTaxResults> createCalcReverseTaxesWithNpaNxxResponseCalcReverseTaxesWithNpaNxxResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_CalcReverseTaxesWithNpaNxxResponseCalcReverseTaxesWithNpaNxxResult_QNAME, ReverseTaxResults.class, CalcReverseTaxesWithNpaNxxResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = CalcTaxesWithPCode.class)
    public JAXBElement<Transaction> createCalcTaxesWithPCodeATransaction(Transaction value) {
        return new JAXBElement<Transaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, Transaction.class, CalcTaxesWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = CalcReverseTaxesWithPCode.class)
    public JAXBElement<Transaction> createCalcReverseTaxesWithPCodeATransaction(Transaction value) {
        return new JAXBElement<Transaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, Transaction.class, CalcReverseTaxesWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "NpaNxxToPCodeResult", scope = NpaNxxToPCodeResponse.class)
    public JAXBElement<Long> createNpaNxxToPCodeResponseNpaNxxToPCodeResult(Long value) {
        return new JAXBElement<Long>(_NpaNxxToPCodeResponseNpaNxxToPCodeResult_QNAME, Long.class, NpaNxxToPCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Integer }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "TaxLevel", scope = CustomerTaxData.class)
    public JAXBElement<Integer> createCustomerTaxDataTaxLevel(Integer value) {
        return new JAXBElement<Integer>(_CustomerTaxDataTaxLevel_QNAME, Integer.class, CustomerTaxData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "Description", scope = CustomerTaxData.class)
    public JAXBElement<String> createCustomerTaxDataDescription(String value) {
        return new JAXBElement<String>(_CustomerTaxDataDescription_QNAME, String.class, CustomerTaxData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CategoryDescription", scope = CustomerTaxData.class)
    public JAXBElement<String> createCustomerTaxDataCategoryDescription(String value) {
        return new JAXBElement<String>(_CustomerTaxDataCategoryDescription_QNAME, String.class, CustomerTaxData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfSalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustmentList", scope = SAUCalcTaxesAndAdjWithFipsCodeInCustMode.class)
    public JAXBElement<ArrayOfSalesUseTransaction> createSAUCalcTaxesAndAdjWithFipsCodeInCustModeAnAdjustmentList(ArrayOfSalesUseTransaction value) {
        return new JAXBElement<ArrayOfSalesUseTransaction>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnAdjustmentList_QNAME, ArrayOfSalesUseTransaction.class, SAUCalcTaxesAndAdjWithFipsCodeInCustMode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfSalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransactionList", scope = SAUCalcTaxesAndAdjWithFipsCodeInCustMode.class)
    public JAXBElement<ArrayOfSalesUseTransaction> createSAUCalcTaxesAndAdjWithFipsCodeInCustModeATransactionList(ArrayOfSalesUseTransaction value) {
        return new JAXBElement<ArrayOfSalesUseTransaction>(_SAUCalcTaxesAndAdjWithPCodeInCustModeATransactionList_QNAME, ArrayOfSalesUseTransaction.class, SAUCalcTaxesAndAdjWithFipsCodeInCustMode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcTaxesAndAdjWithFipsCodeInCustMode.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcTaxesAndAdjWithFipsCodeInCustModeAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcTaxesAndAdjWithFipsCodeInCustMode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcTaxesAndAdjWithFipsCodeInCustMode.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcTaxesAndAdjWithFipsCodeInCustModeANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcTaxesAndAdjWithFipsCodeInCustMode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcTaxesWithFipsCodeResult", scope = CalcTaxesWithFipsCodeResponse.class)
    public JAXBElement<ArrayOfTaxData> createCalcTaxesWithFipsCodeResponseCalcTaxesWithFipsCodeResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_CalcTaxesWithFipsCodeResponseCalcTaxesWithFipsCodeResult_QNAME, ArrayOfTaxData.class, CalcTaxesWithFipsCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcAdjWithPCodeResult", scope = CalcAdjWithPCodeResponse.class)
    public JAXBElement<ArrayOfTaxData> createCalcAdjWithPCodeResponseCalcAdjWithPCodeResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_CalcAdjWithPCodeResponseCalcAdjWithPCodeResult_QNAME, ArrayOfTaxData.class, CalcAdjWithPCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Object }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "SaleAttributes", scope = SalesUseTransaction.class)
    public JAXBElement<Object> createSalesUseTransactionSaleAttributes(Object value) {
        return new JAXBElement<Object>(_SalesUseTransactionSaleAttributes_QNAME, Object.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ShipFromFipsCode", scope = SalesUseTransaction.class)
    public JAXBElement<String> createSalesUseTransactionShipFromFipsCode(String value) {
        return new JAXBElement<String>(_SalesUseTransactionShipFromFipsCode_QNAME, String.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "OptionalAlpha1", scope = SalesUseTransaction.class)
    public JAXBElement<String> createSalesUseTransactionOptionalAlpha1(String value) {
        return new JAXBElement<String>(_SalesUseTransactionOptionalAlpha1_QNAME, String.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ShipFromPCode", scope = SalesUseTransaction.class)
    public JAXBElement<Long> createSalesUseTransactionShipFromPCode(Long value) {
        return new JAXBElement<Long>(_SalesUseTransactionShipFromPCode_QNAME, Long.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ShipToAddress", scope = SalesUseTransaction.class)
    public JAXBElement<ZipAddress> createSalesUseTransactionShipToAddress(ZipAddress value) {
        return new JAXBElement<ZipAddress>(_SalesUseTransactionShipToAddress_QNAME, ZipAddress.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ShipFromAddress", scope = SalesUseTransaction.class)
    public JAXBElement<ZipAddress> createSalesUseTransactionShipFromAddress(ZipAddress value) {
        return new JAXBElement<ZipAddress>(_SalesUseTransactionShipFromAddress_QNAME, ZipAddress.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CompanyIdentifier", scope = SalesUseTransaction.class)
    public JAXBElement<String> createSalesUseTransactionCompanyIdentifier(String value) {
        return new JAXBElement<String>(_SalesUseTransactionCompanyIdentifier_QNAME, String.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Integer }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "FOB", scope = SalesUseTransaction.class)
    public JAXBElement<Integer> createSalesUseTransactionFOB(Integer value) {
        return new JAXBElement<Integer>(_SalesUseTransactionFOB_QNAME, Integer.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CustomerNumber", scope = SalesUseTransaction.class)
    public JAXBElement<String> createSalesUseTransactionCustomerNumber(String value) {
        return new JAXBElement<String>(_SalesUseTransactionCustomerNumber_QNAME, String.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ShipToFipsCode", scope = SalesUseTransaction.class)
    public JAXBElement<String> createSalesUseTransactionShipToFipsCode(String value) {
        return new JAXBElement<String>(_SalesUseTransactionShipToFipsCode_QNAME, String.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Integer }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CustomerType", scope = SalesUseTransaction.class)
    public JAXBElement<Integer> createSalesUseTransactionCustomerType(Integer value) {
        return new JAXBElement<Integer>(_SalesUseTransactionCustomerType_QNAME, Integer.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ShipToPCode", scope = SalesUseTransaction.class)
    public JAXBElement<Long> createSalesUseTransactionShipToPCode(Long value) {
        return new JAXBElement<Long>(_SalesUseTransactionShipToPCode_QNAME, Long.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxExemption }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "Exemptions", scope = SalesUseTransaction.class)
    public JAXBElement<ArrayOfTaxExemption> createSalesUseTransactionExemptions(ArrayOfTaxExemption value) {
        return new JAXBElement<ArrayOfTaxExemption>(_SalesUseTransactionExemptions_QNAME, ArrayOfTaxExemption.class, SalesUseTransaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = SAUCalcTaxesWithZipAddress.class)
    public JAXBElement<SalesUseTransaction> createSAUCalcTaxesWithZipAddressATransaction(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, SalesUseTransaction.class, SAUCalcTaxesWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcTaxesWithZipAddress.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcTaxesWithZipAddressAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcTaxesWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcTaxesWithZipAddress.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcTaxesWithZipAddressANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcTaxesWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "Taxes", scope = ReverseTaxResults.class)
    public JAXBElement<ArrayOfTaxData> createReverseTaxResultsTaxes(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_ReverseTaxResultsTaxes_QNAME, ArrayOfTaxData.class, ReverseTaxResults.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = CalcReverseTaxesWithZipAddress.class)
    public JAXBElement<Transaction> createCalcReverseTaxesWithZipAddressATransaction(Transaction value) {
        return new JAXBElement<Transaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, Transaction.class, CalcReverseTaxesWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcAdjWithZipAddressResult", scope = CalcAdjWithZipAddressResponse.class)
    public JAXBElement<ArrayOfTaxData> createCalcAdjWithZipAddressResponseCalcAdjWithZipAddressResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_CalcAdjWithZipAddressResponseCalcAdjWithZipAddressResult_QNAME, ArrayOfTaxData.class, CalcAdjWithZipAddressResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "TerminationAddress", scope = Transaction.class)
    public JAXBElement<ZipAddress> createTransactionTerminationAddress(ZipAddress value) {
        return new JAXBElement<ZipAddress>(_TransactionTerminationAddress_QNAME, ZipAddress.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "OriginationPCode", scope = Transaction.class)
    public JAXBElement<Long> createTransactionOriginationPCode(Long value) {
        return new JAXBElement<Long>(_TransactionOriginationPCode_QNAME, Long.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CompanyIdentifier", scope = Transaction.class)
    public JAXBElement<String> createTransactionCompanyIdentifier(String value) {
        return new JAXBElement<String>(_SalesUseTransactionCompanyIdentifier_QNAME, String.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "TerminationNpaNxx", scope = Transaction.class)
    public JAXBElement<Long> createTransactionTerminationNpaNxx(Long value) {
        return new JAXBElement<Long>(_TransactionTerminationNpaNxx_QNAME, Long.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "OriginationNpaNxx", scope = Transaction.class)
    public JAXBElement<Long> createTransactionOriginationNpaNxx(Long value) {
        return new JAXBElement<Long>(_TransactionOriginationNpaNxx_QNAME, Long.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Integer }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "BusinessClass", scope = Transaction.class)
    public JAXBElement<Integer> createTransactionBusinessClass(Integer value) {
        return new JAXBElement<Integer>(_TransactionBusinessClass_QNAME, Integer.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "TerminationPCode", scope = Transaction.class)
    public JAXBElement<Long> createTransactionTerminationPCode(Long value) {
        return new JAXBElement<Long>(_TransactionTerminationPCode_QNAME, Long.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Integer }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ServiceClass", scope = Transaction.class)
    public JAXBElement<Integer> createTransactionServiceClass(Integer value) {
        return new JAXBElement<Integer>(_TransactionServiceClass_QNAME, Integer.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CustomerNumber", scope = Transaction.class)
    public JAXBElement<String> createTransactionCustomerNumber(String value) {
        return new JAXBElement<String>(_SalesUseTransactionCustomerNumber_QNAME, String.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "BillToFipsCode", scope = Transaction.class)
    public JAXBElement<String> createTransactionBillToFipsCode(String value) {
        return new JAXBElement<String>(_TransactionBillToFipsCode_QNAME, String.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "BillToPCode", scope = Transaction.class)
    public JAXBElement<Long> createTransactionBillToPCode(Long value) {
        return new JAXBElement<Long>(_TransactionBillToPCode_QNAME, Long.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "TerminationFipsCode", scope = Transaction.class)
    public JAXBElement<String> createTransactionTerminationFipsCode(String value) {
        return new JAXBElement<String>(_TransactionTerminationFipsCode_QNAME, String.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "OptionalAlpha1", scope = Transaction.class)
    public JAXBElement<String> createTransactionOptionalAlpha1(String value) {
        return new JAXBElement<String>(_SalesUseTransactionOptionalAlpha1_QNAME, String.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "BillToAddress", scope = Transaction.class)
    public JAXBElement<ZipAddress> createTransactionBillToAddress(ZipAddress value) {
        return new JAXBElement<ZipAddress>(_TransactionBillToAddress_QNAME, ZipAddress.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "BillToNpaNxx", scope = Transaction.class)
    public JAXBElement<Long> createTransactionBillToNpaNxx(Long value) {
        return new JAXBElement<Long>(_TransactionBillToNpaNxx_QNAME, Long.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "OriginationFipsCode", scope = Transaction.class)
    public JAXBElement<String> createTransactionOriginationFipsCode(String value) {
        return new JAXBElement<String>(_TransactionOriginationFipsCode_QNAME, String.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Integer }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CustomerType", scope = Transaction.class)
    public JAXBElement<Integer> createTransactionCustomerType(Integer value) {
        return new JAXBElement<Integer>(_SalesUseTransactionCustomerType_QNAME, Integer.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxExemption }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "Exemptions", scope = Transaction.class)
    public JAXBElement<ArrayOfTaxExemption> createTransactionExemptions(ArrayOfTaxExemption value) {
        return new JAXBElement<ArrayOfTaxExemption>(_SalesUseTransactionExemptions_QNAME, ArrayOfTaxExemption.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "OriginationAddress", scope = Transaction.class)
    public JAXBElement<ZipAddress> createTransactionOriginationAddress(ZipAddress value) {
        return new JAXBElement<ZipAddress>(_TransactionOriginationAddress_QNAME, ZipAddress.class, Transaction.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcReverseTaxesWithZipAddressResult", scope = SAUCalcReverseTaxesWithZipAddressResponse.class)
    public JAXBElement<ReverseTaxResults> createSAUCalcReverseTaxesWithZipAddressResponseSAUCalcReverseTaxesWithZipAddressResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_SAUCalcReverseTaxesWithZipAddressResponseSAUCalcReverseTaxesWithZipAddressResult_QNAME, ReverseTaxResults.class, SAUCalcReverseTaxesWithZipAddressResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcAdjWithNpaNxxResult", scope = CalcAdjWithNpaNxxResponse.class)
    public JAXBElement<ArrayOfTaxData> createCalcAdjWithNpaNxxResponseCalcAdjWithNpaNxxResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_CalcAdjWithNpaNxxResponseCalcAdjWithNpaNxxResult_QNAME, ArrayOfTaxData.class, CalcAdjWithNpaNxxResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcReverseAdjWithZipAddress.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcReverseAdjWithZipAddressAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcReverseAdjWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = SAUCalcReverseAdjWithZipAddress.class)
    public JAXBElement<SalesUseTransaction> createSAUCalcReverseAdjWithZipAddressAnAdjustment(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, SalesUseTransaction.class, SAUCalcReverseAdjWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcReverseAdjWithZipAddress.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcReverseAdjWithZipAddressANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcReverseAdjWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "OptionalAlpha1", scope = TaxData.class)
    public JAXBElement<String> createTaxDataOptionalAlpha1(String value) {
        return new JAXBElement<String>(_SalesUseTransactionOptionalAlpha1_QNAME, String.class, TaxData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CompanyIdentifier", scope = TaxData.class)
    public JAXBElement<String> createTaxDataCompanyIdentifier(String value) {
        return new JAXBElement<String>(_SalesUseTransactionCompanyIdentifier_QNAME, String.class, TaxData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CustomerNumber", scope = TaxData.class)
    public JAXBElement<String> createTaxDataCustomerNumber(String value) {
        return new JAXBElement<String>(_SalesUseTransactionCustomerNumber_QNAME, String.class, TaxData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Integer }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "TaxLevel", scope = TaxData.class)
    public JAXBElement<Integer> createTaxDataTaxLevel(Integer value) {
        return new JAXBElement<Integer>(_CustomerTaxDataTaxLevel_QNAME, Integer.class, TaxData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "Description", scope = TaxData.class)
    public JAXBElement<String> createTaxDataDescription(String value) {
        return new JAXBElement<String>(_CustomerTaxDataDescription_QNAME, String.class, TaxData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CategoryDescription", scope = TaxData.class)
    public JAXBElement<String> createTaxDataCategoryDescription(String value) {
        return new JAXBElement<String>(_CustomerTaxDataCategoryDescription_QNAME, String.class, TaxData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcReverseAdjWithPCodeResult", scope = CalcReverseAdjWithPCodeResponse.class)
    public JAXBElement<ReverseTaxResults> createCalcReverseAdjWithPCodeResponseCalcReverseAdjWithPCodeResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_CalcReverseAdjWithPCodeResponseCalcReverseAdjWithPCodeResult_QNAME, ReverseTaxResults.class, CalcReverseAdjWithPCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = CalcAdjWithPCode.class)
    public JAXBElement<Transaction> createCalcAdjWithPCodeAnAdjustment(Transaction value) {
        return new JAXBElement<Transaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, Transaction.class, CalcAdjWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfSalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustmentList", scope = SAUCalcTaxesAndAdjWithZipAddressInCustMode.class)
    public JAXBElement<ArrayOfSalesUseTransaction> createSAUCalcTaxesAndAdjWithZipAddressInCustModeAnAdjustmentList(ArrayOfSalesUseTransaction value) {
        return new JAXBElement<ArrayOfSalesUseTransaction>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnAdjustmentList_QNAME, ArrayOfSalesUseTransaction.class, SAUCalcTaxesAndAdjWithZipAddressInCustMode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfSalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransactionList", scope = SAUCalcTaxesAndAdjWithZipAddressInCustMode.class)
    public JAXBElement<ArrayOfSalesUseTransaction> createSAUCalcTaxesAndAdjWithZipAddressInCustModeATransactionList(ArrayOfSalesUseTransaction value) {
        return new JAXBElement<ArrayOfSalesUseTransaction>(_SAUCalcTaxesAndAdjWithPCodeInCustModeATransactionList_QNAME, ArrayOfSalesUseTransaction.class, SAUCalcTaxesAndAdjWithZipAddressInCustMode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcTaxesAndAdjWithZipAddressInCustMode.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcTaxesAndAdjWithZipAddressInCustModeAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcTaxesAndAdjWithZipAddressInCustMode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcTaxesAndAdjWithZipAddressInCustMode.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcTaxesAndAdjWithZipAddressInCustModeANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcTaxesAndAdjWithZipAddressInCustMode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcReverseAdjWithZipAddressResult", scope = CalcReverseAdjWithZipAddressResponse.class)
    public JAXBElement<ReverseTaxResults> createCalcReverseAdjWithZipAddressResponseCalcReverseAdjWithZipAddressResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_CalcReverseAdjWithZipAddressResponseCalcReverseAdjWithZipAddressResult_QNAME, ReverseTaxResults.class, CalcReverseAdjWithZipAddressResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcReverseAdjWithFipsCodeResult", scope = CalcReverseAdjWithFipsCodeResponse.class)
    public JAXBElement<ReverseTaxResults> createCalcReverseAdjWithFipsCodeResponseCalcReverseAdjWithFipsCodeResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_CalcReverseAdjWithFipsCodeResponseCalcReverseAdjWithFipsCodeResult_QNAME, ReverseTaxResults.class, CalcReverseAdjWithFipsCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ZipP4End", scope = AddressData.class)
    public JAXBElement<String> createAddressDataZipP4End(String value) {
        return new JAXBElement<String>(_AddressDataZipP4End_QNAME, String.class, AddressData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ZipBegin", scope = AddressData.class)
    public JAXBElement<String> createAddressDataZipBegin(String value) {
        return new JAXBElement<String>(_AddressDataZipBegin_QNAME, String.class, AddressData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CountryISO", scope = AddressData.class)
    public JAXBElement<String> createAddressDataCountryISO(String value) {
        return new JAXBElement<String>(_AddressDataCountryISO_QNAME, String.class, AddressData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ZipEnd", scope = AddressData.class)
    public JAXBElement<String> createAddressDataZipEnd(String value) {
        return new JAXBElement<String>(_AddressDataZipEnd_QNAME, String.class, AddressData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ZipP4Begin", scope = AddressData.class)
    public JAXBElement<String> createAddressDataZipP4Begin(String value) {
        return new JAXBElement<String>(_AddressDataZipP4Begin_QNAME, String.class, AddressData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "County", scope = AddressData.class)
    public JAXBElement<String> createAddressDataCounty(String value) {
        return new JAXBElement<String>(_AddressDataCounty_QNAME, String.class, AddressData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "Locality", scope = AddressData.class)
    public JAXBElement<String> createAddressDataLocality(String value) {
        return new JAXBElement<String>(_AddressDataLocality_QNAME, String.class, AddressData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "State", scope = AddressData.class)
    public JAXBElement<String> createAddressDataState(String value) {
        return new JAXBElement<String>(_AddressDataState_QNAME, String.class, AddressData.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcAdjWithZipAddressResult", scope = SAUCalcAdjWithZipAddressResponse.class)
    public JAXBElement<ArrayOfTaxData> createSAUCalcAdjWithZipAddressResponseSAUCalcAdjWithZipAddressResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_SAUCalcAdjWithZipAddressResponseSAUCalcAdjWithZipAddressResult_QNAME, ArrayOfTaxData.class, SAUCalcAdjWithZipAddressResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcAdjWithFipsCodeResult", scope = CalcAdjWithFipsCodeResponse.class)
    public JAXBElement<ArrayOfTaxData> createCalcAdjWithFipsCodeResponseCalcAdjWithFipsCodeResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_CalcAdjWithFipsCodeResponseCalcAdjWithFipsCodeResult_QNAME, ArrayOfTaxData.class, CalcAdjWithFipsCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcReverseAdjWithPCode.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcReverseAdjWithPCodeAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcReverseAdjWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = SAUCalcReverseAdjWithPCode.class)
    public JAXBElement<SalesUseTransaction> createSAUCalcReverseAdjWithPCodeAnAdjustment(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, SalesUseTransaction.class, SAUCalcReverseAdjWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcReverseAdjWithPCode.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcReverseAdjWithPCodeANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcReverseAdjWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfCustomerTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcTaxesAndAdjWithFipsCodeInCustModeResult", scope = SAUCalcTaxesAndAdjWithFipsCodeInCustModeResponse.class)
    public JAXBElement<ArrayOfCustomerTaxData> createSAUCalcTaxesAndAdjWithFipsCodeInCustModeResponseSAUCalcTaxesAndAdjWithFipsCodeInCustModeResult(ArrayOfCustomerTaxData value) {
        return new JAXBElement<ArrayOfCustomerTaxData>(_SAUCalcTaxesAndAdjWithFipsCodeInCustModeResponseSAUCalcTaxesAndAdjWithFipsCodeInCustModeResult_QNAME, ArrayOfCustomerTaxData.class, SAUCalcTaxesAndAdjWithFipsCodeInCustModeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcTaxesWithPCodeResult", scope = CalcTaxesWithPCodeResponse.class)
    public JAXBElement<ArrayOfTaxData> createCalcTaxesWithPCodeResponseCalcTaxesWithPCodeResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_CalcTaxesWithPCodeResponseCalcTaxesWithPCodeResult_QNAME, ArrayOfTaxData.class, CalcTaxesWithPCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = CalcTaxesWithNpaNxx.class)
    public JAXBElement<Transaction> createCalcTaxesWithNpaNxxATransaction(Transaction value) {
        return new JAXBElement<Transaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, Transaction.class, CalcTaxesWithNpaNxx.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = SAUCalcReverseTaxesWithFipsCode.class)
    public JAXBElement<SalesUseTransaction> createSAUCalcReverseTaxesWithFipsCodeATransaction(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, SalesUseTransaction.class, SAUCalcReverseTaxesWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcReverseTaxesWithFipsCode.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcReverseTaxesWithFipsCodeAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcReverseTaxesWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcReverseTaxesWithFipsCode.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcReverseTaxesWithFipsCodeANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcReverseTaxesWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ZipP4", scope = ZipAddress.class)
    public JAXBElement<String> createZipAddressZipP4(String value) {
        return new JAXBElement<String>(_ZipAddressZipP4_QNAME, String.class, ZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "ZipCode", scope = ZipAddress.class)
    public JAXBElement<String> createZipAddressZipCode(String value) {
        return new JAXBElement<String>(_ZipAddressZipCode_QNAME, String.class, ZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CountryISO", scope = ZipAddress.class)
    public JAXBElement<String> createZipAddressCountryISO(String value) {
        return new JAXBElement<String>(_AddressDataCountryISO_QNAME, String.class, ZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "County", scope = ZipAddress.class)
    public JAXBElement<String> createZipAddressCounty(String value) {
        return new JAXBElement<String>(_AddressDataCounty_QNAME, String.class, ZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "Locality", scope = ZipAddress.class)
    public JAXBElement<String> createZipAddressLocality(String value) {
        return new JAXBElement<String>(_AddressDataLocality_QNAME, String.class, ZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "State", scope = ZipAddress.class)
    public JAXBElement<String> createZipAddressState(String value) {
        return new JAXBElement<String>(_AddressDataState_QNAME, String.class, ZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = CalcReverseAdjWithFipsCode.class)
    public JAXBElement<Transaction> createCalcReverseAdjWithFipsCodeAnAdjustment(Transaction value) {
        return new JAXBElement<Transaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, Transaction.class, CalcReverseAdjWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcTaxesWithFipsCodeResult", scope = SAUCalcTaxesWithFipsCodeResponse.class)
    public JAXBElement<ArrayOfTaxData> createSAUCalcTaxesWithFipsCodeResponseSAUCalcTaxesWithFipsCodeResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_SAUCalcTaxesWithFipsCodeResponseSAUCalcTaxesWithFipsCodeResult_QNAME, ArrayOfTaxData.class, SAUCalcTaxesWithFipsCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "CountryISO", scope = Exclusion.class)
    public JAXBElement<String> createExclusionCountryISO(String value) {
        return new JAXBElement<String>(_AddressDataCountryISO_QNAME, String.class, Exclusion.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "State", scope = Exclusion.class)
    public JAXBElement<String> createExclusionState(String value) {
        return new JAXBElement<String>(_AddressDataState_QNAME, String.class, Exclusion.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "CalcTaxesWithZipAddressResult", scope = CalcTaxesWithZipAddressResponse.class)
    public JAXBElement<ArrayOfTaxData> createCalcTaxesWithZipAddressResponseCalcTaxesWithZipAddressResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_CalcTaxesWithZipAddressResponseCalcTaxesWithZipAddressResult_QNAME, ArrayOfTaxData.class, CalcTaxesWithZipAddressResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcReverseAdjWithPCodeResult", scope = SAUCalcReverseAdjWithPCodeResponse.class)
    public JAXBElement<ReverseTaxResults> createSAUCalcReverseAdjWithPCodeResponseSAUCalcReverseAdjWithPCodeResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_SAUCalcReverseAdjWithPCodeResponseSAUCalcReverseAdjWithPCodeResult_QNAME, ReverseTaxResults.class, SAUCalcReverseAdjWithPCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "GetTaxDescriptionResult", scope = GetTaxDescriptionResponse.class)
    public JAXBElement<String> createGetTaxDescriptionResponseGetTaxDescriptionResult(String value) {
        return new JAXBElement<String>(_GetTaxDescriptionResponseGetTaxDescriptionResult_QNAME, String.class, GetTaxDescriptionResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfAddressData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "GetAddressResult", scope = GetAddressResponse.class)
    public JAXBElement<ArrayOfAddressData> createGetAddressResponseGetAddressResult(ArrayOfAddressData value) {
        return new JAXBElement<ArrayOfAddressData>(_GetAddressResponseGetAddressResult_QNAME, ArrayOfAddressData.class, GetAddressResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "ZipToPCodeResult", scope = ZipToPCodeResponse.class)
    public JAXBElement<Long> createZipToPCodeResponseZipToPCodeResult(Long value) {
        return new JAXBElement<Long>(_ZipToPCodeResponseZipToPCodeResult_QNAME, Long.class, ZipToPCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://schemas.datacontract.org/2004/07/EZTaxWebService", name = "State", scope = Nexus.class)
    public JAXBElement<String> createNexusState(String value) {
        return new JAXBElement<String>(_AddressDataState_QNAME, String.class, Nexus.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcAdjWithPCodeResult", scope = SAUCalcAdjWithPCodeResponse.class)
    public JAXBElement<ArrayOfTaxData> createSAUCalcAdjWithPCodeResponseSAUCalcAdjWithPCodeResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_SAUCalcAdjWithPCodeResponseSAUCalcAdjWithPCodeResult_QNAME, ArrayOfTaxData.class, SAUCalcAdjWithPCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcAdjWithFipsCodeResult", scope = SAUCalcAdjWithFipsCodeResponse.class)
    public JAXBElement<ArrayOfTaxData> createSAUCalcAdjWithFipsCodeResponseSAUCalcAdjWithFipsCodeResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_SAUCalcAdjWithFipsCodeResponseSAUCalcAdjWithFipsCodeResult_QNAME, ArrayOfTaxData.class, SAUCalcAdjWithFipsCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = CalcReverseTaxesWithFipsCode.class)
    public JAXBElement<Transaction> createCalcReverseTaxesWithFipsCodeATransaction(Transaction value) {
        return new JAXBElement<Transaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, Transaction.class, CalcReverseTaxesWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ReverseTaxResults }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcReverseAdjWithFipsCodeResult", scope = SAUCalcReverseAdjWithFipsCodeResponse.class)
    public JAXBElement<ReverseTaxResults> createSAUCalcReverseAdjWithFipsCodeResponseSAUCalcReverseAdjWithFipsCodeResult(ReverseTaxResults value) {
        return new JAXBElement<ReverseTaxResults>(_SAUCalcReverseAdjWithFipsCodeResponseSAUCalcReverseAdjWithFipsCodeResult_QNAME, ReverseTaxResults.class, SAUCalcReverseAdjWithFipsCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = SAUCalcTaxesWithPCode.class)
    public JAXBElement<SalesUseTransaction> createSAUCalcTaxesWithPCodeATransaction(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, SalesUseTransaction.class, SAUCalcTaxesWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcTaxesWithPCode.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcTaxesWithPCodeAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcTaxesWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcTaxesWithPCode.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcTaxesWithPCodeANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcTaxesWithPCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcTaxesWithPCodeResult", scope = SAUCalcTaxesWithPCodeResponse.class)
    public JAXBElement<ArrayOfTaxData> createSAUCalcTaxesWithPCodeResponseSAUCalcTaxesWithPCodeResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_SAUCalcTaxesWithPCodeResponseSAUCalcTaxesWithPCodeResult_QNAME, ArrayOfTaxData.class, SAUCalcTaxesWithPCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Long }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "FipsToPCodeResult", scope = FipsToPCodeResponse.class)
    public JAXBElement<Long> createFipsToPCodeResponseFipsToPCodeResult(Long value) {
        return new JAXBElement<Long>(_FipsToPCodeResponseFipsToPCodeResult_QNAME, Long.class, FipsToPCodeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = CalcAdjWithZipAddress.class)
    public JAXBElement<Transaction> createCalcAdjWithZipAddressAnAdjustment(Transaction value) {
        return new JAXBElement<Transaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, Transaction.class, CalcAdjWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcAdjWithZipAddress.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcAdjWithZipAddressAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcAdjWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = SAUCalcAdjWithZipAddress.class)
    public JAXBElement<SalesUseTransaction> createSAUCalcAdjWithZipAddressAnAdjustment(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, SalesUseTransaction.class, SAUCalcAdjWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcAdjWithZipAddress.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcAdjWithZipAddressANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcAdjWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aTransaction", scope = CalcTaxesWithZipAddress.class)
    public JAXBElement<Transaction> createCalcTaxesWithZipAddressATransaction(Transaction value) {
        return new JAXBElement<Transaction>(_SAUCalcTaxesWithFipsCodeATransaction_QNAME, Transaction.class, CalcTaxesWithZipAddress.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfCustomerTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcTaxesAndAdjWithPCodeInCustModeResult", scope = SAUCalcTaxesAndAdjWithPCodeInCustModeResponse.class)
    public JAXBElement<ArrayOfCustomerTaxData> createSAUCalcTaxesAndAdjWithPCodeInCustModeResponseSAUCalcTaxesAndAdjWithPCodeInCustModeResult(ArrayOfCustomerTaxData value) {
        return new JAXBElement<ArrayOfCustomerTaxData>(_SAUCalcTaxesAndAdjWithPCodeInCustModeResponseSAUCalcTaxesAndAdjWithPCodeInCustModeResult_QNAME, ArrayOfCustomerTaxData.class, SAUCalcTaxesAndAdjWithPCodeInCustModeResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfExclusion }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anExclusionList", scope = SAUCalcReverseAdjWithFipsCode.class)
    public JAXBElement<ArrayOfExclusion> createSAUCalcReverseAdjWithFipsCodeAnExclusionList(ArrayOfExclusion value) {
        return new JAXBElement<ArrayOfExclusion>(_SAUCalcTaxesAndAdjWithPCodeInCustModeAnExclusionList_QNAME, ArrayOfExclusion.class, SAUCalcReverseAdjWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SalesUseTransaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = SAUCalcReverseAdjWithFipsCode.class)
    public JAXBElement<SalesUseTransaction> createSAUCalcReverseAdjWithFipsCodeAnAdjustment(SalesUseTransaction value) {
        return new JAXBElement<SalesUseTransaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, SalesUseTransaction.class, SAUCalcReverseAdjWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfNexus }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aNexusList", scope = SAUCalcReverseAdjWithFipsCode.class)
    public JAXBElement<ArrayOfNexus> createSAUCalcReverseAdjWithFipsCodeANexusList(ArrayOfNexus value) {
        return new JAXBElement<ArrayOfNexus>(_SAUCalcTaxesAndAdjWithPCodeInCustModeANexusList_QNAME, ArrayOfNexus.class, SAUCalcReverseAdjWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Transaction }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "anAdjustment", scope = CalcAdjWithFipsCode.class)
    public JAXBElement<Transaction> createCalcAdjWithFipsCodeAnAdjustment(Transaction value) {
        return new JAXBElement<Transaction>(_CalcReverseAdjWithNpaNxxAnAdjustment_QNAME, Transaction.class, CalcAdjWithFipsCode.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ArrayOfTaxData }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "SAUCalcTaxesWithZipAddressResult", scope = SAUCalcTaxesWithZipAddressResponse.class)
    public JAXBElement<ArrayOfTaxData> createSAUCalcTaxesWithZipAddressResponseSAUCalcTaxesWithZipAddressResult(ArrayOfTaxData value) {
        return new JAXBElement<ArrayOfTaxData>(_SAUCalcTaxesWithZipAddressResponseSAUCalcTaxesWithZipAddressResult_QNAME, ArrayOfTaxData.class, SAUCalcTaxesWithZipAddressResponse.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ZipAddress }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://tempuri.org/", name = "aZipAddress", scope = ZipToPCode.class)
    public JAXBElement<ZipAddress> createZipToPCodeAZipAddress(ZipAddress value) {
        return new JAXBElement<ZipAddress>(_ZipToPCodeAZipAddress_QNAME, ZipAddress.class, ZipToPCode.class, value);
    }

}
