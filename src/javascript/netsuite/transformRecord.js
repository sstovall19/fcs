function transformRecord(input)
{
	var retVal = new Object();
	retVal.status = false;
	retVal.id = 0;
	retVal.error = '';

    var fromId = input.fromId
    var fromRecord = input.fromType; 
    var toRecord = input.toType;
	var recordDefault = input.recordDefault;

   nlapiLogExecution('DEBUG', 'fromId: ' + fromId + ', fromType: ' + fromRecord + ', toType:' + toRecord + ', recordDefault:' + recordDefault);
   try {
	   var transformedRecord = nlapiTransformRecord(fromRecord, fromId, toRecord);
	   nlapiLogExecution('DEBUG', 'Transformed record: ' ,transformedRecord);

	   for (var key in recordDefault) {
			nlapiLogExecution('DEBUG', 'Default Key: ' ,key);
			nlapiLogExecution('DEBUG', 'Default Value: ' ,recordDefault[key]);
			
			transformedRecord.setFieldValue(key, recordDefault[key]);			
	   }
	   
	   var newRecordId = nlapiSubmitRecord(transformedRecord, true); 
	   nlapiLogExecution('DEBUG', fromRecord +': ' + fromId + ' transformed into ' + toRecord + ': ' + newRecordId);
	   retVal.status = true;
	   retVal.id = newRecordId;
   } catch (e) {
	   nlapiLogExecution('ERROR', 'Error occurred in transforming ' + fromRecord +': ' + fromId + ' into ' + toRecord);
	   nlapiLogExecution('ERROR', e.name || e.getCode(), e.message || e.getDetails());
	   retVal.error = e.getDetails();
   }   
  
   return retVal;
}