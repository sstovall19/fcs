
function create_lead(request,response)  {
	var lead;
	var required = ['companyname','firstname','lastname'];
	for (parameter in required) {
		if (request.getParameter(required[parameter])==null) {
			response.writeLine('FAILED|missing parameter "'+required[parameter]+'"');
			 return;
	     }
	}
    lead = nlapiCreateRecord("customer",{stage:'lead'});
	lead.setFieldValue('isperson', 'F');
	var form_fields = ["firstname","lastname","companyname","phone","email","leadsource","custentity_original_email", "custentity_purchase_authority","custentity_companysize","custentity116","custentity34","custentity_leadcategory"];
	var address_fields = ["addr1","addr2","city","state","country","zip"];
	
	for (var i in form_fields) {
		lead.setFieldValue(form_fields[i],request.getParameter(form_fields[i]));
	}
	for (var i in address_fields) {
		lead.setLineItemValue('addressbook', address_fields[i], 1, request.getParameter(address_fields[i]));
	}
	lead.setLineItemValue('addressbook', 'label', 1, request.getParameter("companyname"));
	lead.setFieldValue('entitystatus', '6'); 
    lead.setFieldValue('entityid',request.getParameter('companyname'));
	
	var customerId;
	try {
		customerId = nlapiSubmitRecord(lead, true);
	} catch(e) {
		if (e.message.indexOf("A customer record with this ID already exists.")>=0) {
			response.writeLine("DUPLICATE");
		} else {
			response.writeLine("FAILED|"+e.message);
		}
		return;
	}
	if (customerId!=null && customerId>0) {
		response.writeLine("OK");
	} else {
		response.writeLine("FAILED");
	}
	
}
