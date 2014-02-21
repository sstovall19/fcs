/*
	Order bundle dependecy handler

	This should be converted to an object really

var options = {};

options.dependencies = [
	{
		bundle_id: 51,
		provides_bundle_id: 52,
		provides_bundle_id_multiplier: 1
	},
	{
		bundle_id: 51,
		requires_bundle_id: 53,
		requires_bundle_id_multiplier: 1
	}
];

*/

// Hold value of elements before they are disabled, so that we can pre-populate them if they are re-enabled.
var bundle_dependency_disabled_value = {};
var bundles = {};
var bundle_dependency_hover_messages = {};

// Handle deps
function bundle_dependencies(options)
{
	var dependencies = options.dependencies;
	var alert_method = options.alert_method;

	var i;

	for(i in dependencies)
	{
		if(!bundles[dependencies[i].bundle_id])
		    bundles[dependencies[i].bundle_id] = new Array();
		bundles[dependencies[i].bundle_id].push(dependencies[i]);
	}


	for( i in bundles)
	{
		var form_element = false;

		if($('input[name="'+i+'"]').length)
		{
			form_element = $('input[name="'+i+'"]');
		}
		else
		{
			if($('select[name="'+i+'"]').length)
			{
				form_element = $('select[name="'+i+'"]');
			}
			else
			{
				if($('option[value="'+i+'"]').length)
				{
					form_element = $('option[value="'+i+'"]').parent();
				}
			}
		}

		if(!form_element)
		{
			continue;
		}

		//var element = $(form_element).attr('name');
		bundle_dependency_handler();
		
		$(form_element).bind('change blur', function(event)
		{
			   // var element = $(this).attr('name');
				bundle_dependency_handler();
				//bundle_dependency_handler(form_element, bundles[i][rule]);
			//}	
		});
	}
	
}

function bundle_dependency_target(id)
{
	var target = false;

	if($('input[name="'+id+'"]').length)
	{
		target = $('input[name="'+id+'"]');
	}
	else
	{
		if($('select[name="'+id+'"]').length)
			target = $('select[name="'+id+'"]');
	}

	if(!target)
	{
		if($('option[value="'+id+'"]').length)
			target = $('option[value="'+id+'"]');
	}

	return target;
}

function bundle_dependency_handler()
{
	var bundle_values = {};
	var bundle_disable = {};
	var bundle_enable = {};
	var bundle_requires = {};
	var bundle_max = {};
	var bundle_max_selected = new Array();
	var bundle_min = {};
	var bundle_min_selected = new Array();
		
	for(id in bundles)
	{
	  for(rules in bundles[id])
		{
			rule = bundles[id][rules];
			
			if(rule && rule.bundle_id)
			{
				var element = bundle_dependency_target(id);

				if(rule.provides_bundle_id)
				{
					var target = bundle_dependency_target(rule.provides_bundle_id);

					if(target)
					{
						var dep = {};
						dep.value = $(element).val();
						if(!rule.provides_bundle_id_multiplier)
							rule.provides_bundle_id_multiplier = 1;

						dep.set_value = dep.value * rule.provides_bundle_id_multiplier;
					
						if(!bundle_values[rule.provides_bundle_id])
							bundle_values[rule.provides_bundle_id] = 0;	

						bundle_values[rule.provides_bundle_id] = bundle_values[rule.provides_bundle_id] + dep.set_value;

						// IF DEFINED and provided bundle is not enough...?
						if($(target).val() < dep.set_value)
						{
							$(target).val(Math.ceil(dep.set_value));
							$(target).trigger('change');
						}

						// IF DEFINED and provided bundle is already enough...?
						// ??? DO NOTHING???
					}
				}

				if(rule.requires_bundle_id)
				{
					// This will need to update the validation rules
					// IF DEFINED and bundle is not already a proper qty...?
					// IF DEFINED and bundle is not available...?
				}

				if(rule.enables_bundle_id)
				{
					//confirm('Enables bundle:'+rule.enables_bundle_id);
					var source = bundle_dependency_target(rule.bundle_id);
					var target = bundle_dependency_target(rule.enables_bundle_id);

					if(source && source.val() && target)
					{
						if($(source).prop('tagName') == 'OPTION')
						{
							if($(source).not(':selected'))
								continue;
						}
						// Remove hover message
						delete bundle_dependency_hover_messages[rule.bundle_id];

						if($(target).prop('tagName') == 'OPTION')
						{
							//confirm('SHOW OPTION'+rule.enables_bundle_id);
							$(target).showOption();
						}
						else
						{
							$(target).removeAttr('readonly').removeClass('ui-state-disabled').trigger('change');
							
						}
					}
				}

				if(rule.disables_bundle_id)
				{
					// What if there is a value defined for this bundle???
					var source = bundle_dependency_target(rule.bundle_id);
					var target = bundle_dependency_target(rule.disables_bundle_id);
					
					if(source && target)
					{
						if($(source).prop('tagName') == 'OPTION')
						{
							if($(source).not(':selected'))
								continue;
						}

						if($(target).prop('tagName') == 'OPTION')
						{
							// If the target is selected, we need to un-select it
							if($(target).is(':selected'))
							{
								$(target).closest('select').val(''); //.parent().val('');
							}
							$(target).hideOption();	
						}
						else
						{
							$(target).attr('readonly', 'readonly').val('').addClass('ui-state-disabled').trigger('change');
							if($(target).parent().prev().children().length == 0){
								$(target).parent().prev().prepend('<span class="ui-icon ui-icon-info" style="float:left" name="'+$(target).attr("name")+'"></span>');
								$(target).parent().prev().children().on('mouseover', function()
								{
									$(this).tooltip({
											delay: 0,
											track: true,
											showbody: " - ",
											extraClass: "ui-widget ui-widget-content ui-state-highlight normalfont ui-corner-all",
											bodyHandler: function() {
												var msg = '<ul>';
												var arr = bundle_dependency_hover_messages[$(this).attr('name')];
												for(i in arr)
												{
													msg += '<li>'+arr[i]+'</li>';
												}
												msg += '</ul>';
												return msg;
											}
										});
								});
							}
						}


						if(rule.disables_bundle_id_message && $(target).prop('tagName') != 'OPTION')
						{
							if(!bundle_dependency_hover_messages[rule.disables_bundle_id])
								bundle_dependency_hover_messages[rule.disables_bundle_id] = {};
	
							bundle_dependency_hover_messages[rule.disables_bundle_id][rule.bundle_id] = rule.disables_bundle_id_message;

							target.on('mouseover', function()
							{
								$(this).tooltip({
									delay: 0,
									track: true,
									showbody: " - ",
									extraClass: "ui-widget ui-widget-content ui-state-highlight normalfont ui-corner-all",
									bodyHandler: function() {
										var msg = '<ul>';
										var arr = bundle_dependency_hover_messages[$(this).attr('name')];
										for(i in arr)
										{
											msg += '<li>'+arr[i]+'</li>';
										}
										msg += '</ul>';
										return msg;
									}
								});
							});	
							
						}
					}
					// This may need to disable validation rules
				}

				if(rule.sets_max_bundle_id)
				{
					// This will need to modify validation rules
					var source = bundle_dependency_target(rule.bundle_id);
					var target = bundle_dependency_target(rule.sets_max_bundle_id);

					if(source && source.val() && target)
					{
						var dep = {};
						dep.value = $(source).val();
						if(!rule.sets_max_bundle_id_multiplier)
							rule.sets_max_bundle_id_multiplier = 1;

						dep.set_value = dep.value * rule.sets_max_bundle_id_multiplier;
					
						if(!bundle_max[rule.sets_max_bundle_id])
							bundle_max[rule.sets_max_bundle_id] = 0;	

						bundle_max[rule.sets_max_bundle_id] = bundle_max[rule.sets_max_bundle_id] + dep.set_value;

						if(!bundle_max_selected[rule.sets_max_bundle_id])
							bundle_max_selected[rule.sets_max_bundle_id] = new Array();

						bundle_max_selected[rule.sets_max_bundle_id].push(rule.bundle_id);
					}
				}

				if(rule.sets_min_bundle_id)
				{
					/// This will need to modify validation rules
					var source = bundle_dependency_target(rule.bundle_id);
					var target = bundle_dependency_target(rule.sets_min_bundle_id);

					if(source && source.val() && target)
					{
						var dep = {};
						dep.value = $(source).val();
						if(!rule.sets_min_bundle_id_multiplier)
							rule.sets_min_bundle_id_multiplier = 1;

						dep.set_value = dep.value * rule.sets_min_bundle_id_multiplier;
					
						if(!bundle_min[rule.sets_min_bundle_id])
							bundle_min[rule.sets_min_bundle_id] = 0;	

						bundle_min[rule.sets_min_bundle_id] = bundle_min[rule.sets_min_bundle_id] + dep.set_value;

						if(!bundle_min_selected[rule.sets_min_bundle_id])
							bundle_min_selected[rule.sets_min_bundle_id] = new Array();

						bundle_min_selected[rule.sets_min_bundle_id].push(rule.bundle_id);
					}
				}

				if(rule.set_max_category_id)
				{

				}

				if(rule.set_min_category_id)
				{

				}
			}
		}
		
	}

	for (i in bundle_values)
	{
		target = bundle_dependency_target(i);

		if(target)
		{
			if(bundle_values[i] > $(target).val())
			{
				$(target).val(Math.ceil(bundle_values[i]));
			}
		}
	}

	for (i in bundle_max)
	{
		target = bundle_dependency_target(i);

		if(target)
		{
			var selected_options = new Array();

			for(o in bundle_max_selected[i])
			{
				selected_options.push(bundle_dependency_target(bundle_max_selected[i][o]).parent().prevAll('.form_label:first').text());
			}

			var selected_string = '('+selected_options.join(', ')+')';

			if($(target).val() > bundle_max[i])
				$(target).val(bundle_max[i]);

			var label = $(target).parent().prevAll('.form_label:first').text();
			$(target).rules('add', { max: Math.ceil(bundle_max[i]), messages: { max: 'Maximum quantity for "'+label+'" is {0} based on selected options '+selected_string} });
		}
	}

	for (i in bundle_min)
	{
		target = bundle_dependency_target(i);

		if(target)
		{
			var selected_options = new Array();

			for(o in bundle_min_selected[i])
			{
				selected_options.push(bundle_dependency_target(bundle_min_selected[i][o]).parent().prevAll('.form_label:first').text());
			}

			var selected_string = '('+selected_options.join(', ')+')';

			var label = $(target).parent().prevAll('.form_label:first').text();
			$(target).rules('add', { min: Math.floor(bundle_min[i]), messages: { max: 'Minimum quantity for "'+label+'" is {0} based on selected options '+selected_string} });
		}
	}
}

$.fn.hideOption = function() {
    this.each(function() {
        if ($(this).is('option') && (!$(this).parent().is('span'))) {
            $(this).wrap('<span>').hide()
        }
    });
}

$.fn.showOption = function() {

	this.each(function() {
		if (this.nodeName.toLowerCase() === 'option')
		{
			var p = $(this).parent(),
			o = this;
			if($(p).prop('nodeName').toLowerCase() === 'span')
			{
				$(o).show();
				$(p).replaceWith(o)
			}
		}
		else
		{
			var opt = $('option', $(this));
			$(this).replaceWith(opt);
			opt.show();
		}
	});
}

