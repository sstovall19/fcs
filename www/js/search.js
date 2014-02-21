/*
	This handles the search capabilities
*/

var searchable_apps = new Array();
var search_delay;
var search_background;
var search_background_activity = 'rgb(255, 255, 255) url(images/loading.gif) no-repeat scroll 50% 50%';


$(document).ready(function()
{
	// Get current (default) background for icon
	search_background = $('#nav_search_button').css('background');

	$('#nav_search').keyup(function(e)
	{
		// Don't handle non character entries
		if((e.keyCode < 48 && e.keyCode != 8) || ( e.keyCode > 90 && e.keyCode < 188))
		{
			return false;
		}

		if($(this).val().length > 3)
		{
			var search_term = $(this).val();

			$('#nav_search_button').css('background', search_background_activity);

			clearTimeout(search_delay);

			search_delay = setTimeout(function()
			{
				// Get results
				application_search(search_term);
			}, 2000);
		}
		else
		{
			clearTimeout(search_delay);
			$('#nav_search_results').hide();
			$('#nav_search_button').css('background', search_background);
		}
	});	
});

// This pulls a list of applications that allow searching into an array
function get_searchable_apps(search_term)
{

	var form_data = {};
	form_data.mode = 'Core.Searchable_Apps';
	form_data.action = 'get_searchable_apps';

	$.ajax({
		url: '/',
		dataType: 'JSON',
		type: 'POST',
		data: form_data,
		success: function(data)
		{
			if(data && data.results)
			{
				var i;
				for(i in data.results)
				{
					searchable_apps.push(data.results[i]);
				}
			}
			else
			{
				return false;
			}

			if(search_term)
			{
				application_search(search_term);
			}
		}
	});

	return false;
}

function application_search(search_term)
{
	$('#nav_search_results').children().remove().css('z-index', z_index());

	if(!search_term)
		return false;

	if(searchable_apps.length > 0)
	{
		var i;
		var apps_searched = 0;

		for(i in searchable_apps)
		{
			if(search_term.match(searchable_apps[i].format))
			{
				$('#nav_search_button').css('background', search_background_activity);
				form_data = {};
				form_data.mode = searchable_apps[i].mode;
				form_data.action = searchable_apps[i].action;
				form_data[searchable_apps[i].param] = search_term;
		
				$.ajax({
					complete: function() { /* Disable auto error handling */ },
					url: '/',
					dataType: 'JSON',
					type: 'POST',
					data: form_data,
					success: function(data)
					{
						display_search_results(data, search_term);
						var search_num = i;
						// End of search - switch back to search icon
						$('#nav_search_button').css('background', search_background);
					}
				});
			}
			else if(i == (searchable_apps.length - 1))
			{
				$('#nav_search_button').css('background', search_background);
			}
		}
	}
	else
	{
		get_searchable_apps(search_term);
	}
}

function display_search_results(data, search_term)
{
	if(!data || !data.results)
		return false;

	if(!$('#nav_search_results').is(':visible'))
	{
		$('#nav_search_results').fadeIn('slow');
		$('#nav_search_results').position({
			my: "right top",
			at: "right bottom",
			of: "#nav_search_button"
		});

	}

	var i = 0;

	for(i in data.results)
	{
		var query = "";

		var p;

		// Build query string from params
		for(p in data.results[i].params)
		{
			query=query+'&'+p+'='+data.results[i].params[p];
		}

		// HREF Anchor
		if(!data.results[i].anchor)
			data.results[i].anchor = "";
		
		// HREF Target
		if(!data.results[i].target)
			data.results[i].target = "";

		$('#nav_search_results').append('<div class="ui-widget ui-state-default" style="clear: both; padding: 3px; margin: 2px;"><a target="'+data.results[i].target+'" href="/?mode='+data.results[i].mode+query+'&'+data.results[i].anchor+'">'+data.results[i].label+': '+search_term+'</a></span>').css('z-index', z_index());
	}
}

