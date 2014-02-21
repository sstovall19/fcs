/*
	Returns all data in a form to an object, used primarily for AJAX requests
*/
function get_form_data(selector)
{
	var form_data = {};

	$(selector+' :input').map(function(index, element)
	{
		if(element.type == 'checkbox')
		{
			if($(element).is(':checked'))
			{
				form_data[element.name] = 1;
			}
		}
		else
		{
			if(element.type != 'submit')
			{
				form_data[element.name] = $(element).val();
			}
		}
	});

	return form_data;
}

$.fn.form_data = function()
{
	var form_data = {};

	$(this).find('input').map(function(index, element)
	{
		if(element.type == 'checkbox')
		{
			if($(element).is(':checked'))
			{
				form_data[element.name] = 1;
			}
		}
		else
		{
			if(element.type != 'submit')
			{
				form_data[element.name] = $(element).val();
			}
		}
	});

	return form_data;
}

/* 
	Add jQuery function to allow sorting the options in a select box

	Usage:

		$(selector).sort_select_box();

		$('#some_id').sort_select_box();

*/
$.fn.sort_select_box = function()
{
	var my_options = $("option", $(this));
	var selectedIndex = $(this)[0].selectedIndex;
	my_options.sort(function(a,b)
	{
        	if (a.text > b.text) return 1;
        	else if (a.text < b.text) return -1;
        	else return 0
	});

	$(this).empty().append(my_options);
	$(this)[0].selectedIndex = selectedIndex;
}

/*
	Add JQuery function to allow sorting an unordered list

	Usage:

		$(ul_selector).sort_list();

		$('#id_of_my_unordered_list').sort_list();

*/
$.fn.sort_list = function()
{
	$(this).children('li').sort(function(a, b)
	{
		var upA = $(a).text().toUpperCase();
		var upB = $(b).text().toUpperCase();
		return (upA < upB) ? -1 : (upA > upB) ? 1 : 0;
	}).appendTo($(this));
}

$.fn.server_search = function()
{
	var element = $(this);

	element.keyup(function(e)
	{
		/* Don't handle non digit entries ( except backspace )
			48-57 96-105 8 
		*/ 
		if((e.keyCode < 48 || (e.keyCode > 57 && e.keyCode < 96) || e.keyCode > 105) && e.keyCode != 8)
		{
			return false;
		}

		if(element.val().length >= 4 && element.val() > 1000)
		{
			// Show the user some feedback
			element.css({ 
				'background':'url("images/loading.gif")',
				'background-position':'right',
				'background-repeat':'no-repeat'
			});

			$.ajax({
				url: '/',
				dataType: 'JSON',
				type: 'POST',
				data: { 'mode':'Core.Server_Search', 'action':'populate_search_box', 'server_id':element.val() },
				success: function(data)
				{
					element.css('background', '');
					
					if(data && data.results)
					{
						// Create result div if not exists
						if($('#server_search_results_div').length == 0)
						{
							var w = element.width();
							$('<div/>', {
								id: 'server_search_results_div',
								width: w*2
							}).appendTo('body');
						}

						$('#server_search_results_div').empty().fadeIn();

						var i;
						for(i in data.results)
						{
							$('<div/>', {
								html: data.results[i].label,
								'class': 'ui-widget ui-widget-content ui-state-default',
								style: 'padding: 2px;'
							}).appendTo('#server_search_results_div').click(function() { element.val(data.results[i].value); $('#server_search_results_div').fadeOut(); });
						}

						$('#server_search_results_div').position({
							my: 'left top',
							at: 'left bottom',
							of: element
						});
					}
				}
			});
		}		
	});
}

//capitalize a string
String.prototype.capitalize = function()
{ 
   return this.toLowerCase().replace(/^.|\s\S/g, function(a) { return a.toUpperCase(); });
}

