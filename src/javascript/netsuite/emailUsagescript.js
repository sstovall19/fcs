function emailTransactionUsage(request, response){

var transactionId= request.getParameter("transactionId");
var fileId= request.getParameter("fileId");
var type= request.getParameter("type");

nlapiLogExecution('DEBUG', 'TransactionId: ', transactionId);
nlapiLogExecution('DEBUG', 'FileId: ', fileId);
nlapiLogExecution('DEBUG', 'Type: ', type);

var transaction= nlapiLoadRecord(type, transactionId);
var recipient = transaction.getFieldValue('email');
var transId = transaction.getFieldValue('tranid');
var sender = transaction.getFieldValue('salesrep');

type = type.replace(/^./, function(str){ return str.toUpperCase(); });

var subject = 'Fonality: ' + type + ' #' +  transId;
var message = 'Please find attached the receipt / invoice for your most recent Fonality Billing.  We appreciate your business!   ';

var records = new Object();
var files = new Array();

records['transaction'] =transactionId;

//print the transaction to a PDF file object
var file = nlapiPrintRecord('TRANSACTION', transactionId, 'DEFAULT', null);
files[0] = file;

if (fileId != 0) {
var customFile = nlapiLoadFile(fileId);
files[1] = customFile ;
}

nlapiSendEmail(sender,recipient ,subject, message, null, null, records, files);

nlapiLogExecution('DEBUG', 'Email Sent to: ' + recipient , recipient );
response.write("Success \n");
    
}