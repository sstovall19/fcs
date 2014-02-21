/**
 * @fileOverview
 * @name Echosign Populate Transaction Link.js
 * @author Eliseo Beltran ebeltran@fonality.com
 */

 /**
  * This will set the 'Transaction Link' field in the EchoSign Agreement form.
  * <br />
  * <br />EchoSign Agreement is the record created using the 'Send Signature' button in the Estimate record.
  * <br />Deployed on Record: <b>EchoSign Agreement</b>
  * <br />Type: <b>User Event Script</b>
  * <br />
  * @param {string} [type] Sets up an event handler for the given element.
  */

 /**
  * Added a text in the message box of the record to include contact details of the sales rep.
  * Modified by Yong Caballero | 03.12.2011
  */

 function beforeSubmit(type)
{
	if(type == 'create');
	{
		var logger = new Logger();
		logger.enableDebug();
		var rec = nlapiGetNewRecord();
		
		var _parent = rec.getFieldValue('custrecord_echosign_parent_record_2');
		rec.setFieldValue('custrecordtransactionlink', _parent);
		
		var agreementMessage = nlapiGetFieldValue('custrecord_echosign_message_2');
		
		if (agreementMessage == null) {
			agreementMessage = 'Please';
		}
		
		if(_parent != "" || _parent != null)
		{
			var fname = nlapiLookupField('employee',nlapiLookupField('estimate',_parent,'salesrep'),'firstname');
			var lname = nlapiLookupField('employee',nlapiLookupField('estimate',_parent,'salesrep'),'lastname');
			var salesRepEmail = nlapiLookupField('estimate',_parent,'custbody_scemail');
		}
		
		var salesRep = fname + ' ' + lname;		
		
		nlapiSetFieldValue('custrecord_echosign_message_2', agreementMessage + ' Kindly contact your sales rep, ' + salesRep + ' (' + salesRepEmail + '), for any questions about the contract.');
		var transactionLink = rec.getFieldValue('custrecordtransactionlink');
		logger.debug('Linked Estimate Record : ' + _parent + ' | Transaction Link: ' + transactionLink, _parent +	' | ' + transactionLink);
	}
}