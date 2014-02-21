/*
 * set up validation rules
 **/
function validatorDefaults(validate){
if(!validate){
	/* Setup default validator settings */
	$.validator.setDefaults({
		submitHandler: function(validator, formobj)
		{
			$('input[type=submit]', formobj).attr('disabled', 'disabled').val('Loading...');
			$(formobj).form.submit();
		},
		errorClass: 'ui-state-error ui-corner-all validation-class',
		validClass: '',
		useDialog: false,
		errorDiv: 'validation-block',
		errorCSS: 'padding: 5px; margin: 5px;',
		success: true,
		useErrorDiv: true,
		errorPlacement: function(error, element)
		{
			//error.html('<div style="position: relative; padding: 2px;" class="error_msg ui-state-error ui-corner-all">'+error.html()+'</div>');
			/* See if we have a class defined for validator placement	
			**
			** v-right
			** v-left
			** v-top
			** v-bottom
			** v-top-right
			** v-bottom-right
			** v-top-left
			** v-bottom-left

			If you set the element's class to v-dialog, the error will be displayed in an alert dialog
			*/
			var p_my = 'left center';
			var p_of = 'right center';

			var e;
			var p_e = element;

			// Get element to append error to
			if(element.hasClass('test-v-dialog'))
			{
				alert(error, 'Please fix the following error');
				return false;
			}
			else
			{
				if( element.is(":radio") )
				{
					e = element.parent().next().next();
					p_e = element.parent().last().next();
				}
				else
				{
					if ( element.is(":checkbox") )
					{
						e = element.next();
						p_e = element.next();
					}
					else
					{
						e = element.parent().next();
						p_e = element;
					}
				}

				// Get position
				if(element.hasClass('v-left'))
				{
					p_my = 'right center';
					p_of = 'left center';
				}
				else
				if(element.hasClass('v-top'))
				{
					p_my = 'center bottom';
					p_of = 'center top';
				}
				else
				if(element.hasClass('v-bottom'))
				{
					p_my = 'center top';
					p_of = 'center bottom';
				}
				else
				if(element.hasClass('v-top-right'))
				{
					p_my = 'left bottom';
					p_of = 'right top';
				}
				else
				if (element.hasClass('v-bottom-right'))
				{
					p_my = 'left top';
					p_of = 'right bottom';
				}
				else
				if (element.hasClass('v-top-left'))
				{
					p_my = 'right bottom';
					p_of = 'left top';
				}
				else
				if (element.hasClass('v-bottom-left'))
				{
					p_my = 'right top';
					p_of = 'left bottom';
				}

				error.appendTo(e);

				error.position({
					my: p_my,
					at: p_of,
					of: p_e
				});


			}
		},
		showLabel: function(element, message, validator) {

			var form_field = $(element);

			if(validator.settings.useDialog == true || form_field.hasClass('v-dialog'))
			{
				if(!validator.is_displayed)
				{
					validator.is_displayed = true;
					validator.settings.useDialog = true;
					alert(validator.errorList[0].message);
				}
				return false;
			}
			else if(validator.settings.errorDiv && ( validator.settings.useErrorDiv == true || form_field.hasClass('v-div') || $(element.form).hasClass('v-div')))
			{
				if($('#'+validator.settings.errorDiv).length == 0 && validator.numberOfInvalids() > 0)
				{
					validator.settings.useErrorDiv = true;
					var error_list = $('<ul>', {
						id: validator.settings.errorDiv+'_error_list'
					});

					// Create new error div dom element
					var error_div = $('<div>', {
						id: validator.settings.errorDiv,
						"class": validator.settings.errorClass,
						width: "100%",
						html: error_list,
						style: validator.settings.errorCSS + ' display: none;'
					});

					// Prepend the error div to the form
					$(element.form).prepend(error_div);
				}

				var form_element = $(element).attr('name');

				if(!message)
				{
					//confirm(validator.numberOfInvalids());
					if($('#error_map_'+form_element).is(':visible'))
						$('#error_map_'+form_element).fadeOut();
				}
				else
				{
					if($('#error_map_'+form_element).length > 0)
					{
						$('#error_map_'+form_element).html(message).fadeIn();
					}
					else
					{
						var li = $('<li>', {
							id: 'error_map_'+form_element,
							html: message 
						});

						$(li).appendTo('#'+validator.settings.errorDiv+'_error_list');
						$('#'+validator.settings.errorDiv).fadeIn();
					}
				}

				if(validator.numberOfInvalids() == 0)
				{
					if($('#'+validator.settings.errorDiv).is(':visible') && !$('#'+validator.settings.errorDiv).is(':hidden'))
					{
						$('#'+validator.settings.errorDiv).fadeOut();
					}
				}
				else
				{
					$('#'+validator.settings.errorDiv).fadeIn();
				}
				return false;
			}

			var label = validator.errorsFor( element );

			if ( label.length )
			{
				// check if we have a generated label, replace the message then
				label.attr("generated") && label.text(message);
			}
			else
			{
				// create label
				label = $("<" + validator.settings.errorElement + "/>");
					label.attr({"for":  validator.idOrName(element), generated: true})
					.addClass(validator.settings.errorClass)
					.html(message || "");
				if ( validator.settings.wrapper )
				{
					// make sure the element is visible, even in IE
					// actually showing the wrapped element is handled elsewhere
					label = label.hide().show().wrap("<" + validator.settings.wrapper + ">").parent();
				}
				if ( !validator.labelContainer.append(label).length )
					validator.settings.errorPlacement
						? validator.settings.errorPlacement(label, $(element) )
						: label.insertAfter(element);
			}
			if ( !message && validator.settings.success )
			{
				label.text("");
				label.removeClass( validator.settings.errorClass ).addClass(validator.settings.validClass);
				typeof validator.settings.success == "string"
					? label.addClass( validator.settings.success )
					: validator.settings.success( label );

				validator.isDisplayed = false;
			}

			label.css('z-index', z_index);
			validator.toShow = validator.toShow.add(label);
		}
	});
 }
}

/* Handle errors automatically on AJAX requests ( assumes JSON data ).
** If you don't want this to happen, just set the complete function
** in your ajax request.
*/

function ajaxErrorHandler(){
	$.ajaxSetup({
		complete: function(obj, stat)
		{
			if($.type(obj) === 'object' && !$.isEmptyObject(obj))
			{
				var j;
				try
				{
					j = $.parseJSON(obj.responseText);
				}
				catch(e)
				{
					j = $.parseJSON('{"error":"Invalid Server Response - HTTP Response Code: '+obj.status+' '+obj.statusText+'"}');
				}

				if(obj.readyState > 0)
					check_json(j, this.errorCallback);
			}
			else
			{
				if($.type(obj) === 'object' && obj.readyState > 0)
					check_json(undefined, this.errorCallback);
			}
		},
		beforeSend: function(xhr, settings)
		{
			// this is added to ensure proper error handling
			if(settings.dataType.match(/json/i))
				settings.data = settings.data + '&to_json=1';
		}
	});
}

/*
 * queing up alert and info messages if the dialog is already shown 
 **/

function queueMessages(){
	
	$( "#dialog-message" ).dialog({
		modal: true,
		autoOpen: false,
		resizable: false,
		buttons: {
			Ok: function() {
				$( this ).dialog( "close" );

				// Check for queued messages
				if(dialog_messages.length)
				{
					var msg = dialog_messages.shift();

					if(msg[0] == 'alert')
					{
						alert(msg[1], msg[2]);
					}
					else
					{
						info(msg[1], msg[2]);
					}
				}
			}
		}
	});
	
	$( "#dialog-message-confirm" ).dialog({
		modal: true,
		autoOpen: false,
		resizable: false,
		buttons: {
			Ok: function() {
				$( this ).dialog( "close" );
				callback(true);
			},
			Cancel: function() {
				$( this ).dialog( "close" );
				callback(false);
			}
		}
	});

}

//Display an informational message
function info(msg, title)
{
	if(!title)
		title = 'Information';

	// If it's already displayed, queue up the message
	if($('#dialog-message').dialog("isOpen"))
	{
		dialog_messages.push(['info', msg, title]);
		return false;
	}

	$('#dialog-message-icon').removeClass('ui-icon-alert').addClass('ui-icon-info');
	$('#dialog-message-text').html(msg);
	$('#dialog-message').dialog('option', 'title', title).dialog('option', 'dialogClass', 'ui-state-highlight').dialog('open');
}

function alert(msg, title)
{
	if(!title)
		title = 'Alert!';

	// If it's already displayed, queue up the message
	if($('#dialog-message').dialog("isOpen"))
	{
		dialog_messages.push(['alert', msg, title]);
		return false;
	}

	$('#dialog-message-icon').removeClass('ui-icon-info').addClass('ui-icon-alert');
	$('#dialog-message-text').html(msg);
	$('#dialog-message').dialog('option', 'title', title).dialog('option', 'dialogClass', 'ui-state-error').dialog('open');
}

function check_json(j, callback)
{
	if(!j)
	{
		alert('The server did not respond properly to the request.', 'No response from server');
		if(callback)
			callback(j);
		return false;
	}

	if(typeof j === 'object')
	{
		if(j.TT_ALERT)
		{
			var errstr = '';
			if($.isArray(j.TT_ALERT))
			{
				for(i in j.TT_ALERT)
				{
					errstr = errstr + '<br>' + j.TT_ALERT[i];
				}
			}
			else
			{
				errstr = j.TT_ALERT;
			}

			alert(errstr, 'There was an error');
			if(callback)
				callback(j, errstr);
			return false;
		}

		if(j.error)
		{
			var errstr = '';
			if($.isArray(j.error))
			{
				for(i in j.error)
				{
					errstr = errstr + '<br>' + j.error[i];
				}
			}
			else
			{
				errstr = j.error;
			}

			alert(errstr, 'There was an error');
			if(callback)
				callback(j, j.error);
			return false;
		}
	}
	else
	{
		alert('The server did not respond properly to the request.', 'Server response was not JSON data');
		if(callback)
			callback(j, j.error);
		return false;
	}

	return true;
}

// Get the highest z-Index
function z_index()
{
	var index_highest = 0;

	$('div').each(function()
	{
		var index_current = parseInt($(this).css("z-index"), 10);
		if(index_current > index_highest)
		{
			index_highest = index_current;
		}
	});

	return index_highest + 1;
}
