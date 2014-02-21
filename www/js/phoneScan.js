//get the phone order details and 
//populate in a json for posting in the db
function getPhoneDetails(){
	
	var json = {};
	 json['scanned_phones'] = {};
		
	$(".server_section").each(function(){
		var serverId = $(this).attr("id");
		json['scanned_phones'][serverId] = {};//add the server id
		if(typeof serverId != "undefined"){	  
			$(".server_section .Mfc").each(function(){		
				var mfc_name = $(this).attr("id");
				json['scanned_phones'][serverId][mfc_name] = {};//add the manifacture's name
			  if(typeof mfc_name != "undefined"){	 
				$(".server_section .Mfc .pType").each(function(){
					var phoneType = $(this).attr("id");
				   if(typeof phoneType != "undefined"){	
						json['scanned_phones'][serverId][mfc_name][phoneType] = [];//add the phone type
						
						$(".server_section input[type=text]").each(function(l){
						   if($(this).val() != '' && $(this).val() != "1"){	//if not empty, add to the json
							  var inputVal =  $(this).val().toUpperCase();
							  json['scanned_phones'][serverId][mfc_name][phoneType][l] = inputVal; //get the mac value
							     
							}	
						});
				   }	
			   });
			  }	
		   });
		}	
    });
	
	return JSON.stringify(json);
}

//create the dialog popup for 
//communicating with the user
function createDialog(){
	
	$('#status-window').dialog({
		modal: true,
		autoOpen: false,
		buttons: [],
		closeOnEscape: false,
		draggable: false,
		resizable: false,
		show: 'slow',
		open: function() {
			$(this).parent().children().children("a.ui-dialog-titlebar-close").remove();
		}
	});
}
//get the validation rules
function getRules(){
	var json = {};
	$(".server_section .mac").each(function(){	
	  json[$(this).attr("name")]= {};
	  json[$(this).attr("name")]['required'] = true;
	  json[$(this).attr("name")]['macaddress'] = true;
	});
	
	return json;
}


$(document).ready(function(){
	//Create status window dialog
	createDialog();	
 /*
  ##########################
  #  Order Details page    #
  ##########################
  */  
 if($("#order_details_form") && $("#order_details_form").prop("tagName") == "FORM") { 
	
	$("#order_details_form").validate({
			ignore: '',
	        rules: getRules(), 	        	  
	        submitHandler: function() { return false; }       
	        
	 }).form();
	
 }
 $("#order_details_form").submit();
 //post the scanned phones data to the db
 if($("#scan_phones") && $("#scan_phones").prop("tagName") == "INPUT"){
	$("#scan_phones").bind("click", function(){
		var valid = $("#order_details_form").valid();
		if(valid){
			//check for duplicates
			var inputData = {};
			var errorFlag = false;
			$(".server_section input[type=text]").each(function(){
				var inputVal = $(this).val().toUpperCase();
				
				if(typeof inputData[inputVal] == "undefined"){
					inputData[inputVal] = inputVal;
				}else{
					$(this).addClass("ui-state-error ui-corner-all validation-class");
					errorFlag = true;
				}
				
			});
			if(errorFlag)return false;
			
			//post the json with the mac addresses to the db
			var jsonData = getPhoneDetails();
			
			$('#status-message').text('Scanning...');
			$('#status-window').dialog('open');
			
			$.ajax({
		        type: "POST",
		        url: "/",
		        data: {
		        	   m: $(".order_mode").first().attr("id"),
		        	   action: $(".order_action").first().attr("id"),
		        	   scanned_phones: jsonData,
		        	   order_id: $("#order_details_form").attr("name")
		        	   },      
		        dataType: "json",
		        success: function(result) {
		        	$('#status-window').dialog('close');
		        	if(result.status != null) {
		        	   info("Your phones have been scanned.", "Success!");	
		               location.href = result.redirect;
		        	}
		        }
		    });
				
		}else{
		  alert("All fields are required to be populated with a correct MAC address.");	
		  return false;
		}  
	 });
 }
 
 /*
 #############################
 #  Order entry page (main)  #
 #############################
 */ 
 if($("#order_entry_form") && $("#order_entry_form").prop("tagName") == "FORM"){	
		$("#order_entry_form").validate({
			ignore: '',
	        rules: {
	        	    order_id: {
	                        required: true,
	                        maxlength: 10,
	                        minlength: 2,
	                        number: true
	                },
	        }
	    });
		
		$("#get_order").click(function(){
			var valid = $("#order_entry_form").valid();
			if(valid){
				$('#status-message').text('Looking up the order...');
				$('#status-window').dialog('open');
			}
		});
	 }

});