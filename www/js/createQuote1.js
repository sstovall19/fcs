/* 
	#################################################################
		Item ( bundle ) name and description holders
	#################################################################
	*/
	var item_description = {};
	var item_name = {};
	var item_price = {};
	var item_mrc = {};
	var price_model = {};
	var volume_discount = {};
	var prepay_discount = {};
	var promo = {};
	var discount_data = {};
	var bundle_dependency_options = {};
	bundle_dependency_options.dependencies = [];
	var term_total = 0.00;
	var term_total_prepay = 0.00;


	var prepay_discount_percentage = 0;
	
	/* 
	#################################################################
		Determines if progress needs to be saved ( i.e. a form element has changed )
	#################################################################
	*/
	var sync_changes = false;

	/* 
	#################################################################
		Progress, Shipping and Contact XHR objects
	#################################################################
	*/
	var progress_xhr;
	var shipping_xhr;
	var shipping_calculator_xhr;
	var contact_xhr;
	var discount_xhr;

	/* 
	#################################################################
		Holders for the above XHR status and error messages
	#################################################################
	*/
	var shipping_saved = false;
	var shipping_status = false;
	var shipping_error = false;
	//
	var contact_saved = false;
	var contact_status = false;
	var contact_error = false;
	//
	var progress_saved = false;
	var progress_status = false;
	var progress_error = false;
	//
	var discount_saved = false;
	var discount_status = false;
	var discount_error = false;
	/* 
	#################################################################
		Tabs / List view vars
	#################################################################
	*/
	var is_single_pane = false;
	var review_scroll;
	var review_left;
	var review_top;
	var container_size = {};
	var components_size = {};
	
	/* 
	#################################################################
		To determine if the currently displayed preview should be updated when hovering over a form_label
	#################################################################
	*/
	var displayed_preview_item;

	/* 
	#################################################################
		Alert the user if they try to navigate away from the page 
		before their progress has completed being saved to session
	#################################################################
	*/
	window.onbeforeunload = function(e)
	{
		if(progress_xhr && progress_xhr.readyState < 4)
		{
			e = e || window.event;

			if(e)
			{
				return 'Your quote information is still being saved to the server.';
			}

			return e;
		}
	};
	
	
	/*
	 *  Create mCustomScrollbar for each right preview div 
	 **/
	function createCustomeScroll(el){
		if($(el).length == 1){
			$(el).mCustomScrollbar({
				scrollButtons: {
					enable: true
				},
				autoDraggerLength: true,
				advanced:{
					 updateOnBrowserResize:true, 
					 updateOnContentResize:false, 
					 autoExpandHorizontalScroll:false, 
					 autoScrollOnFocus:false
				}
			});
		}else{
		  $(el).each(function() {
			$(this).mCustomScrollbar({
				scrollButtons: {
					enable: true
				},
				autoDraggerLength: true,
				advanced:{
					 updateOnBrowserResize:true, 
					 updateOnContentResize:false, 
					 autoExpandHorizontalScroll:false, 
					 autoScrollOnFocus:false
				}
			});
		 });
	  }
   
	}

	 /*
	 ###############################################################
	    process bundle data and populate the javascript object holding it
	 ###############################################################
	 */
     function processBundleData(categories){
    	 //var categories = bundle_data.bundles.categories;
    	//traverse through the categories
 		$.each(categories, function() {
 			var label = this.label;
 			if(Array.isArray(label)){
 			    //traverse through each category labels
				$.each(label, function() {
					var items = this.bundles;
					//traverse through each category labels' bundles
					$.each(items, function() {
						var item = this;
						var priceModels = item.bundle_price_models;
						populateItemNames(item.bundle_id, item.description, item.display_name, item.base_price, item.mrc_price);
						$.each(priceModels, function() {
							var model = this;
							populatePrice_model(item.bundle_id, model.price_model.name);
						});
					});
				});
 		     }else{
 		    	var items = label.bundles;
				//traverse through each category labels' bundles
				$.each(items, function() {
					var item = this;
					var priceModels = item.bundle_price_models;
					populateItemNames(item.bundle_id, item.description, item.display_name, item.base_price, item.mrc_price);
					$.each(priceModels, function() {
						var model = this;
						populatePrice_model(item.bundle_id, model.price_model.name);
					});
				}); 
 		     }	
 		});
 		
     }
     
     /*
	 ###############################################################
	    populate dependencies
	 ###############################################################
	 */
     function populateDependencies(bundle_relations){
    	// var bundle_relations = bundle_data.bundles.bundle_relationships;
    	 var i = 0;
    	//traverse through the bundles_relations and populate the dependencies
         $.each(bundle_relations, function() {
         	var bundle = this;
         	bundle_dependency_options.dependencies[i] = {};
         	for(var key in bundle){
         		if(key != undefined && bundle.hasOwnProperty(key)){
         			bundle_dependency_options.dependencies[i][key] = bundle[key];
         		}
         	}
         	i++;
         }); 
     }
     
     /* 
	 	#################################################################
	 		validate the form entires
	 	#################################################################
	 */
     function callValidate(categories){
	  	 //var categories = bundle_data.bundles.categories;
	  	 var digits = "digits";
	  	 var minlength = "minlength";
	  	 var maxlength = "maxlength";
	  	 var isMin = "min";
	  	 var isMax = "max";
     	//traverse through the categories
  		$.each(categories, function() {
  			var label = this.label;
  			var categoryName = this.name.replace(' ', '_');
			var rules = {};
			var messages = {};
			
		 if(Array.isArray(label)){
  			//traverse through each category labels
 			$.each(label, function() {
 				var items = this.bundles;
 				var labelName = this.name;
			    var validationType = (this.validation_type).toLowerCase(); 
			    var min = this.min;
			    var max = this.max;
			    var isRequired = "required";
			    var required = this.required;
			    if(items.length >= 1){
 				//traverse through each category labels' bundles
			   	$.each(items, function() {
 					var item = this;
 					//populate the rules and messages
					 rules[item.bundle_id] = {};
					 messages[item.bundle_id] = {};
					 if(!validationType || validationType == ""){
						 validationType = "numbers";
					 }
					 
					 if(validationType == "numbers"){
						 rules[item.bundle_id][digits] = true;
						 messages[item.bundle_id][digits] = labelName + ": Please enter only numbers.";
						 if(min){
							 rules[item.bundle_id][isMin] = min;
							 messages[item.bundle_id][isMin] = labelName + ": Minimum allowed number is " + min;
						 }
						 
						 if(max){
							 rules[item.bundle_id][isMax] = max;
							 messages[item.bundle_id][isMax] = labelName + ": Maximum allowed number is " + max;
						 }
					 }else if(validationType == "default" || validationType == "alphanumeric"){
						 if(min){
							 rules[item.bundle_id][minlength] = min;
							 messages[item.bundle_id][minlength] = min;
						 }
						 if(max){
							 rules[item.bundle_id][maxlength] = max;
							 messages[item.bundle_id][maxlength] = max;
						 }
					 }	
					 if(required){
						 rules[item.bundle_id][isRequired] = (required == 'yes') ? true : false;
						 messages[item.bundle_id][isRequired] = (required == 'yes') ? labelName + " is required" : "";
				     }
 				});
			  }	
 			});
		 }else{
			    var items = label.bundles;
				var labelName = label.name;
			    var validationType = label.validation_type.toLowerCase(); 
			    var min = label.min;
			    var max = label.max;
			    var isRequired = "required";
			    var required = label.required;
			    
			    if(items.length >= 1){
				  //traverse through each category labels' bundles
				  $.each(items, function() {
					var item = this;
					//populate the rules and messages
					 rules[item.bundle_id] = {};
					 messages[item.bundle_id] = {};
					 if(!validationType || validationType == ""){
						 validationType = "numbers";
					 }
					 
					 if(validationType == "numbers"){
						 rules[item.bundle_id][digits] = true;
						 messages[item.bundle_id][digits] = labelName + ": Please enter only numbers.";
						 if(min){
							 rules[item.bundle_id][isMin] = min;
							 messages[item.bundle_id][isMin] = labelName + ": Minimum allowed number is " + min;
						 }
						 
						 if(max){
							 rules[item.bundle_id][isMax] = max;
							 messages[item.bundle_id][isMax] = labelName + ": Maximum allowed number is " + max;
						 }
					 }else if(validationType == "default" || validationType == "alphanumeric"){
						 if(min){
							 rules[item.bundle_id][minlength] = min;
							 messages[item.bundle_id][minlength] = min;
						 }
						 if(max){
							 rules[item.bundle_id][maxlength] = max;
							 messages[item.bundle_id][maxlength] = max;
						 }
					 }	
					 if(required){
						 rules[item.bundle_id][isRequired] = (required == 'yes') ? true : false;
						 messages[item.bundle_id][isRequired] = (required == 'yes') ? labelName + " is required" : "";
				     }
				});
			  }	 
		 }	
 			//validate each form category
			$('#form_category_'+categoryName).validate({
				ignore: '',
				errorDiv: 'validation-block-'+categoryName,
				rules: rules,
				messages: messages
			});
  		});
    	 
     }
	/* 
	#################################################################
		Populate item names and descriptions
	#################################################################
	*/ 
	
	function populateItemNames(bundle_id, description, display_name, base_price, mrc_price){
		bundle_list[bundle_id] = 1;
		item_description[bundle_id] = description;
		item_name[bundle_id] = display_name;
		item_price[bundle_id] = base_price;
		item_mrc[bundle_id] = mrc_price;
		price_model[bundle_id] = {};
	}
	
	/*
	 * populate the price_model object 
	 **/
	function populatePrice_model(id, modelName){
		price_model[id][modelName] = true;
	}
	
	/*
	 * populates the pre-paid and discount objects 
	 **/
	function populateBundle(bundle, val, flag){
		if(flag){
			volume_discount[bundle] = val;
		}else{
			prepay_discount[bundle] = val;
		}
	}
	
	/*
     * Retrieve the bundles json and assign it to a local variable 
     **/
	
	 function retrieveBundleData(){
		     $.getJSON('/?m=Sales.Create_Quote&action=bundle_list&deployment_id='+deploymentId).done(function(data) {
		    	//get the bundles' information
		    	processBundleData(data.bundles.categories);
		    	$('.review_results').display_review();
		    	 if(typeof catId != "undefined")bundleSelectorHandler(catId);
		    	 $(document).ready(function(){
		    		 
			    	 rentCheckboxHandler();	 
			    	//populate the bundle dependencies options object
			         populateDependencies(data.bundles.bundle_relationships);
			         bundle_dependencies(bundle_dependency_options);
			         
			         callValidate(data.bundles.categories);
			         var bundle_id = $('.top_preview_form_select_element').val();
			         var e = $('.top_preview_form_element[item_id="'+bundle_id+'"]'); // the item to select
			         top_preview_form_element_hover($(e)); // simulate a hover event
		    	
			   });
		    	 if(!isUserTypeView)$('#status-window').dialog('close'); 
		   });   
	 }	
	 		
	/*
	 * Create status window dialog 
	 **/
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
		
	/*
	 * test - validate the forms 
	 **/
	function validateCategoryForm(){
		$('#form_Shipping').validate({
			errorDiv: 'validation-block-Shipping',
			ignore: '',
			rules: {
					addr1: {
							required: true,
							street: true,
							rangelength: [ 5, 36 ]
						
					},
					addr2: {
							required: false,
							street: true,
							maxlength: 36
					},
					city: {
							required: true,
							city: true,
							rangelength: [ 2, 36 ]
					},
					state_prov: {
						    required: true
					},
					postal: {
						    required: true,
						    minlength : 5,
						    maxlength: 5
					},
					country: {
							required: true
					}
			
			},
			messages: {
				addr1: {
					required: "Street Address is required",
					street: "Invalid street address",
					rangelength: "Invalid street address length"
				},
				addr2: {
					street: "Invalid additional street address info",
					maxlength: "Additional street address info may only be 36 characters"
				},
				state_prov: {
					required: "State is required"
				},
				postal: {
					required: "Zip code is required",
					minlength : "Minimum 5 digits for zip code",
					maxlength: "Maximum 5 digits for zip code"
				},
				city: {
					required: "City is required",
					city: "Invalid city",
					rangelength: "Invalid city length"
				},
				country: {
					required: "Country is required"
				}
			}
		});

		$('#form_Discounts').validate({
			errorDiv: 'validation-block-Discounts',
			ignore: '',
			rules: {
				order_discount: {
					digits: true,
					max: 100
				}
			},
			messages: {
				order_discount: {
					digits: 'Please enter only numbers for the discount percentage.',
					max: 'Enter a percentage less than 100%'
				}
			}
		});

		$('#form_Contact').validate({
			errorDiv: 'validation-block-Contact',
			ignore: '',
			rules: {
					first_name: {
							required: true,
							lettersonly: true,
							rangelength: [ 2, 36 ]
					},
					last_name: {
							required: true,
							lettersonly: true,
							rangelength: [ 2, 36 ]
					},
					email: {
							required: true,
							email: true
					},
					email_confirm: {
							required: true,
							email: true,
							equalTo: '#email'
					},
					company_name: {
							required: true,
							letterswithbasicpunc: true,
							maxlength: 36
					},
					website: {
							required: false,
							url: true,
							maxlength: 64
					}
			},
			messages: {
				first_name: {
					required: "First name is required",
					lettersonly: "Only letters are allowed for your first name",
					rangelength: "Please enter between 2 and 36 characters for your first name"
				},
				last_name: {
					required: "Last name is required",
					lettersonly: "Only letters are allowed for your last name",
					rangelength: "Please enter between 2 and 36 characters for your last name"
				},
				email: {
					required: "Your email address is required",
					email: "Please enter a valid email address"
				},
				email_confirm: {
					required: "Please confirm your email address",
					email: "Please enter a valid confirmation email address",
					equalTo: "Your email and confirmation email addresses to not match"
				},
				company_name: {
					required: "Company name is required",
					letterswithbasicpunc: "Invalid company name",
					maxlength: 'Company name is too long.  Please enter 36 or fewer characters.'
				},
				website: {
					url: "Invalid website URL",
					maxlength: 'Website URL must be 64 or fewer characters.'
				}
			}
		});
		
	}
	
	/*
	 * initialize  
	 **/
	function onPageLoad(){
			    
		    /* Get the width and height of the tab display elements.
			These are for use when switching back to tabs from list display. */
			container_size.width = $('#form_container').width();
			container_size.height = $('#form_container').height();
			components_size.width = $('#form_components').width();
			components_size.height = $('#form_components').height();
		 
	}
	
	/*
	 * Initialize buttons 
	 **/
	function initializeButtons(){
		
		$('.next_button').each(function()
		{
			$(this).button({
				icons: {
					secondary: 'ui-icon-play'
				}
			});
		});

		$('#submit_button').button({
			icons: {
				secondary: 'ui-icon-play'
			}
		});


		$('#review_button').button({
			icons: {
				secondary: 'ui-icon-play'
			}
		});

		$('.nav_next_button:not(.nav_hidden)').last().hide();
		$('.nav_prev_button:not(.nav_hidden)').first().hide();
		$('.nav_review_button:not(.nav_hidden):not(:last)').hide();

		$('.next_button,.nav_next_button').click(function()
		{
			var selectedTab = $("#form_components").tabs('option', 'selected');
			$("#form_components").tabs('option', 'selected', selectedTab + 1);
			//$('.review_results').mCustomScrollbar("scrollTo","top");
			$('.mCSB_container.mCS_no_scrollbar').css('top', '0 !important');
			
		});

		$('.prev_button,.nav_prev_button').click(function()
		{
			var selectedTab = $("#form_components").tabs('option', 'selected');
			$("#form_components").tabs('option', 'selected', selectedTab - 1);
			//$('.review_results').mCustomScrollbar("scrollTo","top");
			$('.mCSB_container.mCS_no_scrollbar').css('top', '0 !important');
			
		});

		$('#close_review_window').button({ icons: { primary: 'ui-icon-circle-close' } });
	}
	
	/*
	 * track status
	 * of validating and saving shipping and contact info,
	 * and progress before actually submitting the quote which
	 * is done via the browser session, not by sending form
	 * data to the server. 
	 **/
	function submitQuote(){
		
		$('#submit-button').click(function()
		{
			$('#review-window').fadeOut();
			
			if(validate_forms() == false)
			{
				return false;
			}

			$('#status-window').dialog('open');

			$('#status-message').text('Preparing..');

			submit_quote();
		});

		$('#restart').click(function() {
			window.location = '/?m=Sales.Create_Quote&action=reset_quote';
		});

		$('#retrieve_quote').click(function() {
			$('#edit-quote-form').fadeIn().css('z-Index', z_index());
			$('#retrieve_quote_id').focus();
			var e = $(this).parent();
			$(e).addClass('ui-state-disabled');

			$('#close-edit-quote-form').click(function()
			{
				$('#edit-quote-form').fadeOut();
				$(e).removeClass('ui-state-disabled');
			});
		});

	}
	
	/* 
	   This is used to select the proper selection in the top_preview_window display type
	   if a selection is stored in the browser session.

	   It's necessary for the session_store code below to call .change() explicitly on the
	   select element since it's hidden.
	*/
	function selectElChange(){

		$('.top_preview_form_select_element').change(function()
		{
			var bundle_id = $(this).val();
			var e = $('.top_preview_form_element[item_id="'+bundle_id+'"]'); // the item to select
			$(e).parent().children().removeClass('ui-state-highlight').addClass('ui-state-disabled'); // fix classes of other selections
			$(e).removeClass('ui-state-disabled').addClass('ui-state-highlight'); // highlight selection
			top_preview_form_element_hover($(e)); // simulate a hover event
			
		});

		$('.bundle_selector').change(function()
		{
			var bundle_id = $(this).val();
			var e = $('.bundle_select_form_element[item_id="'+bundle_id+'"]');
			$(e).parent().children().removeClass('ui-state-highlight').addClass('ui-state-disabled');
			$(e).removeClass('ui-state-disabled').addClass('ui-state-highlight');
			bundle_select_form_element_hover($(e));
		});
	}
	
	/*
	 * Populate variables from session 
	 **/
	function populateFromServer(session_store){
		
		for(i in session_store)
		{
			var e;
			var value;
			var change;

			if($('input[name="'+i+'"]').length > 0)
			{
				e = $('input[name="'+i+'"]');
				value = session_store[i].value;
			}
			else
			{
				e = $('option[value="'+session_store[i].id+'"]').parent();
				value = session_store[i].id;
				change = 1;
			}

			if(e)
			{
				// Check the MRC checkbox
				if(session_store[i].is_rented > 0)
				{
					$('.mrc_'+i).attr('checked', 'checked');
				}

				$(e).val(value).change();
				
			}
		}
	}
	
	/*
	 * Populate shipping info from session
	 **/
	function populateShippingInfo(shipping_store){
		for(i in shipping_store)
		{
			var e;
			var value;

			if($('input[name="'+i+'"]').length > 0)
			{
				e = $('input[name="'+i+'"]');
				value = shipping_store[i];
			}
			else
			{
				e = $('select[name="'+i+'"]');
				value = shipping_store[i];
			}

			if(e)
			{
				$(e).val(value).change();
				
			}
		}
	}
	
	/*
	 * Populate contact info from session
	 **/
	function populateContactInfo(contact_store){
		for(i in contact_store)
		{
			var e;
			var value;

			if($('input[name="'+i+'"]').length > 0)
			{
				e = $('input[name="'+i+'"]');
				value = contact_store[i];
			}
			else
			{
				e = $('select[name="'+i+'"]');
				value = contact_store[i];
			}

			if(e)
			{
				$(e).val(value).change();
				
			}
		}
		
	}
	
	/*
	 * Update the review panel 
	 **/
	function updateReviewPanel(){
		//display_review(); // This should happen on load because we may have a quote stored in session
		$('.review_results').display_review();

		$('input:not(.no_sync),select:not(.no_sync)').change(function()
		{
			var currPos = $('#review_panel .mCSB_dragger').first().position().top;// - $('#review_panel .mCSB_container').first().position().top; 
			
			sync_changes = true;
			$('.review_results').display_review();
			$('.review_results').mCustomScrollbar('scrollTo', currPos)
			
		});
	}
	
	/*
	 * Tabs / List toggle - TODO: Clean this mess up
	 **/
	function toggleTabs(){
		
		$('#tabs_destroy').click(function()
        {
		if(is_single_pane != true)
		{
			$('div.validation-class').remove();
			$('.form_category_div').addClass('single_pane');

			$('#form_components').tabs('destroy')
			$('.ui-tabs-panel,.navtabs_text').hide();
			$('#form_categories').hide();
			$('.next_button').fadeOut();
			$('#submit_button').css('bottom', '-10px').show().position({ my: "right bottom", at: "right top", of: "#Contact"});
			is_single_pane = true;

			$('#tabs_destroy').find('.quote_top_nav_text').first().text('Category view');
			var margin = $('#form_container').height() - $('#form_components').height();
			var h = margin;
			$('.form_category_div').each(function()
			{
				h = h + $(this).parent().outerHeight() + margin;
			});

			$('#form_components').height(h);
			$('#form_container').height(h+margin);
			$('#review_panel').height($(window).height()-50).mCustomScrollbar("update");
			var spos = $('.form_category_div').last();

			var review_width = $('#review_panel').width();

			review_scroll = setInterval(function()
			{
				if(is_single_pane == true)
				{
					if(!review_left)
					{
						p = $('#review_panel').position();
						review_left = p.left;
						review_top  = p.top;
					}

						var t = $(window).scrollTop();
						t = t-review_top;
						if(t < review_top)
							t = review_top;

						$('#review_panel').css('position', 'absolute').css('top', t).css('left',review_left);

				}
			}, 1000);

		}
		else
		{
			clearInterval(review_scroll);
			$('#form_container').width(container_size.width).height(container_size.height);
			$('#review_panel').height(414);
			$('.form_category_div').removeClass('single_pane');
			$('#form_components').css('overflow', 'hide');
			$('.ui-tabs-panel,.navtabs_text').show();
			$('#form_categories').show();

			$('#form_components').tabs({
				select: function(event, ui)
				{

					var curTabPanel = $('#form_components .ui-tabs-panel:not(.ui-tabs-hide)').attr('id');

					if($('#form_'+curTabPanel).valid() != true)
					{
						$('#icon_'+curTabPanel).addClass('category_icon_error');
						return false;
					}
					else
					{
						$('#icon_'+curTabPanel).removeClass('category_icon_error');
					}

					// update the review panel
					$('.review_results').display_review();

					var tab_num = $('#form_components').tabs("length") - 1;

					if(ui.index == tab_num)
					{
						$('.next_button').hide();
						//$('#submit_button').fadeIn().position({ my: "right bottom", at: "right top", of: "#form_categories"});
						$('#review_button').fadeIn().position({ my: "right bottom", at: "right top", of: "#form_categories"});
					}
					else
					{
						$('#review_button').hide();
						$('.next_button').fadeIn().position({ my: "right bottom", at: "right top", of: "#form_categories"});
					}

					if(ui.panel.id == 'Shipping' || ui.panel.id == 'Contact')
					{
						//$('#review_panel').mCustomScrollbar('scrollTo', 'bottom').css('z-Index', z_index());
						//$('#review_panel').mCustomScrollbar('scrollTo', 'top').css('z-Index', z_index());
						$('.mCSB_container.mCS_no_scrollbar').css('top', '0 !important');
					}
					else
					{
						//$('#review_panel').mCustomScrollbar('scrollTo', '#review_'+ui.panel.id);
						//$('#review_panel').mCustomScrollbar('scrollTo', 'top');
						$('.mCSB_container.mCS_no_scrollbar').css('top', '0 !important');
					}

					save_progress();
				}
			});

			$('#form_components').css('overflow', 'hide').width(components_size.width).height(components_size.height);
			$('#tabs_destroy').find('.quote_top_nav_text').first().text('View as list');
			is_single_pane = false;
			$('#review_panel').mCustomScrollbar("update");
		}
	});
}
		
	/*
	 * Create form components tabs 
	 **/
	function createFormComponents(flag){
	$('#form_components').tabs({
		select: function(event, ui)
		{
			var curTabPanel = $('#form_components .ui-tabs-panel:not(.ui-tabs-hide)').attr('id');
	
			if($('#form_'+curTabPanel).valid() != true)
			{
				$('#icon_'+curTabPanel).parent().addClass('category_icon_error');
				return false;
			}
			else
			{
				$('#icon_'+curTabPanel).parent().removeClass('category_icon_error');
			}
	
			// update the review panel
			$('.review_results').display_review();
	
			var tab_num = $('#form_components').tabs("length") - 1;
	
			if(ui.index == tab_num)
			{
				$('.next_button').hide();
				$('#review_button').fadeIn().position({ my: "right bottom", at: "right top", of: "#form_categories"}).css('z-Index', z_index());
			}
			else
			{
				$('#review_button').hide();
				$('.next_button').fadeIn().position({ my: "right bottom", at: "right top", of: "#form_categories"}).css('z-Index', z_index());
			}
	
			if(ui.panel.id == 'Shipping' || ui.panel.id == 'Contact')
			{
				//$('#review_panel').mCustomScrollbar('scrollTo', 'bottom');
			}
			else
			{
				//$('#review_panel').mCustomScrollbar('scrollTo', '#review_'+ui.panel.id);
				//$('#review_panel').mCustomScrollbar('scrollTo', 'top');
				$('.mCSB_container.mCS_no_scrollbar').css('top', '0 !important');
			}
	
			save_progress();
		}
	});
	
	// fix the classes
	$( ".tabs-bottom .ui-tabs-nav, .tabs-bottom .ui-tabs-nav > *" )
	    .removeClass( "ui-corner-all ui-corner-top" )
	    .addClass( "ui-corner-bottom" );
	 
		// move the nav to the bottom
	$( ".tabs-bottom .ui-tabs-nav" ).appendTo( ".tabs-bottom" );
	
	// Position the next and submit buttons initially:
	$('.next_button').fadeIn().position({ my: "right bottom", at: "right top", of: "#form_categories"}).css('z-Index', z_index());
	
	}
	
	/*
	 * add behavior to the deployment selections 
	 **/
	function selectDeployment(){
		$("#deployment_selection").each(function()
		{
			$(this).find('.deployment_radio').map(function(index, element)
			{
				var txt = $(element).text();
				var val = $(element).attr('value');
				var name = $(element).attr('icon');
				//$(element).css('background-image', 'url("/iconify?&icon='+name+'")').css('background-size', 'contain').css('background-repeat', 'no-repeat');
				$(element).html('<img src="/iconify?icon='+name+'">');

				$(element).css('cursor', 'pointer');
				//$(element).addClass('ui-widget').addClass('ui-corner-all');

				$(element).hover(function()
				{
					$('#deployment_description').text($(element).attr('title'));
					$(this).parent().parent().addClass('deployment_icon_hover');
				});

				$(element).click(function()
				{
					$('#deployment_id').val(val);
					$('#status-message').text('Loading available options...');
					$('#status-window').dialog('open');
					$('#deployment_form').submit();
				});
			});

			$(this).find('.deployment_icon').map(function(index, element)
			{
				$(this).hover(function()
				{
					$(this).addClass('deployment_icon_hover');
				});

				$(this).mouseout(function()
				{
					$(this).removeClass('deployment_icon_hover');
				});
			});
		});

	}
	
	/*
	 * Form label hover handler for right preview panels
	 **/
	
	function formLabelHandler(){
		$('.form_label,.form_label_no_clear').hover(function()
				{
					var category_id = $(this).attr('category_id');
					var description = $(this).attr('description');
					
		 			var no_image = false;
					if($(this).hasClass('no_image'))
						no_image = true;

					var item = $(this).text();

					if(displayed_preview_item == item)
						return false;

					displayed_preview_item = item;

					var img_html = '';

					if(no_image == false)
						img_html = '<img src="/iconify?&w=100&h=100&icon='+item+'" align="left" width="100" height="100" style="margin-left: -10px;">';

					$('#preview_panel_'+category_id).fadeOut(200, function() {
						
							$('#preview_panel_'+category_id).html('<h4>'+item+'</h4><p class="review_p">'+img_html+description).fadeIn('slow');
						
					});

				});

				$('.form_element :input').hover(function()
				{
					var label = $(this).parent().prevAll('.form_label:first');
					var category_id = $(label).attr('category_id');
					var description = $(label).attr('description');
					
					var bundle_id = $(this).attr('name');
					var type_buy = false;
					var type_rent = false;
					
					for(var module_name in price_model[bundle_id]){
						if(module_name.toLowerCase() == "monthly" || module_name.toLowerCase() == "rent")type_rent = true;
						if(module_name.toLowerCase() == "buy" || module_name.toLowerCase() == "one time") type_buy = true;
					}
					
					var basic_price = (typeof item_price[bundle_id] != "undefined" && type_buy) ? '<div class="floatLeft" style="clear:both">One Time Price: <span class="bold">$'+
			                item_price[bundle_id]+'</span></div>' : ''; // && item_price[bundle_id] != '0.00'
			        var monthly_price = (typeof item_mrc[bundle_id] != "undefined" && type_rent) ? '<div class="floatRight">Monthly Price: <span class="bold">$'+
			        		item_mrc[bundle_id]+'</span></div>' : ''; //&& item_mrc[bundle_id] != '0.00'      
					
					var prices = basic_price+monthly_price;

					var no_image = false;
					if($(label).hasClass('no_image'))
						no_image = true;

					var item = $(label).text();

					if(displayed_preview_item == item)
						return false;

					displayed_preview_item = item;

					var img_html = '';

					if(no_image == false)
						img_html = '<img src="/iconify?&w=100&h=100&icon='+item+'" align="left" width="100" height="100" style="margin-left: -10px;">';

					$('#preview_panel_'+category_id).fadeOut(200, function() {
						$('#preview_panel_'+category_id).html('<h4>'+item+'</h4><p class="review_p">'+img_html+description+prices).fadeIn('slow');
					});

					if(type_rent){
						
					}
				});

}
	
/*
 * Selection hover and click handler for top preview panels
 **/ 
 	function previewHandlers(){
 	  $('.top_preview_form_element').hover(function()
		{
			var category_id = $(this).attr('category_id');
			var item_id = $(this).attr('item_id');

			top_preview_form_hover($(this), category_id, item_id);
		});

		$('.top_preview_form_element').click(function()
		{
			var element = $(this);
			var category_id = $(this).attr('category_id');
			var item_id = $(this).attr('item_id');
			$('#top_preview_form_select_'+category_id).val(item_id).change();

			$('.category_id_'+category_id).each(function()
			{
				$(this).addClass('ui-state-disabled').removeClass('ui-state-highlight');
			});

			element.removeClass('ui-state-disabled').addClass('ui-state-highlight');

			$('.next_button').fadeIn().position({ my: "right bottom", at: "right top", of: "#form_categories"}).css('z-Index', z_index());
		});

		$('.top_preview_form_element').mouseout(function()
		{
			var category_id = $(this).attr('category_id');
			
			var sel = $('.top_preview_form_element.ui-state-highlight.category_id_'+category_id);
			top_preview_form_hover(sel, category_id, sel.attr('item_id'));
		});
 	}
 	
 	/*
 	 * Selection hover and click handler for pre category panels
 	 **/
 	
 	function preCatHandlers(){
 		if(isUserTypeView) $('.bundle_select_form_element:first').removeClass('ui-state-disabled').addClass('ui-state-highlight');	
 	 
 	 $('.bundle_select_form_element').hover(function()
		{
			var category_id = $(this).attr('category_id');
			var item_id = $(this).attr('item_id');

			bundle_select_form_hover($(this), category_id, item_id);
		});

		$('.bundle_select_form_element').click(function()
		{
			var element = $(this);
			var category_id = $(this).attr('category_id');
			var item_id = $(this).attr('item_id');

			$('.bundle_selector.category_id_'+category_id).val(item_id).change();

			$('.category_id_'+category_id).each(function()
			{
				$(this).addClass('ui-state-disabled').removeClass('ui-state-highlight');
			});

			element.removeClass('ui-state-disabled').addClass('ui-state-highlight');
		    //if(!item_name[item_id]){	
		     $('.bundle_selector_label').text($.trim(element.text().replace(/<br\s?\/?>/, '')));
			//}
			//$('.next_button').fadeIn().position({ my: "right bottom", at: "right top", of: "#form_categories"});
			$('#bundle_select_submit').fadeIn();

		});

		$('.bundle_select_form_element').mouseout(function()
		{
			var category_id = $(this).attr('category_id');
			
			var sel = $('.bundle_select_form_element.ui-state-highlight.category_id_'+category_id);
			bundle_select_form_hover(sel, category_id, sel.attr('item_id'));
		});
 	}
 	
 	/**** Handlers *****/
 	/*
 	 * review button handler 
 	 **/
 	function reviewButtonHandler(){
 	    $('.nav_review_button').click(function()
		{
			$('#review-window-panel').display_review();
			$('#review-window').fadeIn().css('z-Index', z_index()+1);
			$('#review-window-panel').mCustomScrollbar("update");
			return;
		});
 	}
 	
 	/*
 	 * close review window 
 	 **/
 	
 	function closeReviewWindowHandler(){
 	  $('#close-review-window').click(function()
		{
			$('#review-window').fadeOut();
		});
 	}
 	
 	/*
 	 * Apply Manger discount 
 	 **/
 	
 	function applyManagerDiscountHandler(){
 	// Apply manager discount
	$('#order_discount_submit').click(function()
	{
		if(!$('#form_Discounts').valid())
			return false;

		var discount = $('#order_discount').val();
		discount = parseFloat(discount);

		
		if(discount)
		{
			$('#status-message').text('Applying discount...');
			$('#status-window').dialog('open');

			var url = '/';
			var data = { mode: 'Sales.Create_Quote', action: 'apply_discount', discount: discount };

			$.ajax({
				url: url,
				data: data,
				dataType: 'JSON',
				type: 'POST',
				success: function(data)
				{
					if(data.success)
					{
						info('Discount of '+discount+'% has been applied.');
					}
					else
					{
						alert('Could not apply discount of '+discount+'% because '+data.error);
					}
				},
				complete: function()
				{
					$('#status-window').dialog('close');
				}
			});
		}
		
	});

 	}
 	
 	/*
 	 * Change country 
 	 **/
 	
 function countrySelectorHandler(){
 	// Country selector
	$('#country').change(function()
	{

		if($(this).val())
		{
			if($(this).find(':selected').hasClass('requires_state_prov'))
			{
				$('#state_prov').rules('add', { required: true, messages: { required: 'State / Province is required' } });
				$('#state_prov').empty().append('<option value="">Loading...</option>');

				var country = $(this).val();

				$.ajax({
					url: '?m=Sales.Create_Quote&action=state_prov_list',
					type: 'GET',
					dataType: 'JSON',
					data: { mode: 'Sales.Create_Quote', action: 'state_prov_list', country: country},
					success: function(data)
					{
						$('#state_prov').empty().append('<option value="">Select</option>');

						//confirm(data.guid);
						if(data && data.state_prov_list)
						{
							$('#state_prov').removeAttr('disabled').removeClass('ui-state-disabled');

							for(i in data.state_prov_list)
							{
								$('#state_prov').append('<option value="'+i+'">'+data.state_prov_list[i]+'</option>');
							}

							$('#state_prov').sort_select_box();
						}
						else
						{
							$('#state_prov').removeAttr('disabled').removeClass('ui-state-disabled');

							if(data && data.results)
							{
								for(i in data.results)
								{
									$('#state_prov').append('<option value="'+i+'">'+data.results[i]+'</option>');
								}
							}

							$('#state_prov').sort_select_box();
						}
					},
					complete: function()
					{
					}
				});
			}
			else
			{
				$('#state_prov').rules('remove', 'required');
				$('#state_prov').empty().attr('disabled', 'disabled').addClass('ui-state-disabled');
			}

			if($(this).find(':selected').hasClass('requires_postal_code'))
			{
				$('#postal').rules('add', { required: true, messages: { required: 'Postal code is required' } });
				$('#postal').removeAttr('disabled');
			}
			else
			{
				$('#postal').rules('remove', 'required');
				$('#postal').val('').attr('disabled', 'disabled');
			}
		}
	});
 }
 	
 	/*
 	 * Prepay amount to percentage handler 
 	 **/
  
    function prepayToPctHandler(){
    	/* Prepay amount to percentage handler */
		$('#pre-pay-amount').keyup(function(e)
		{
			var code = e.keyCode || e.which;
			if(code == 9)
				return false;

			var discount_percentage = Math.round(parseFloat(($(this).val() / term_total) * 100));
			if(discount_percentage != prepay_discount_percentage)
			{
				$('#pre-pay-percentage').val(parseFloat(discount_percentage)).trigger('change');
				prepay_discount_percentage = discount_percentage;
			}
		});
		var prepay_discount_timer;

		$('#pre-pay-percentage').change(function()
		{
			clearTimeout(prepay_discount_timer);

			prepay_discount_timer = setTimeout(function()
			{
				calculate_discounts();
			}, 1000);

		}).keyup(function()
		{
			var code = e.keyCode || e.which;
			if(code == 9)
				return false;

			if($(this).val() > 100)
				$(this).val(100);

			var discount_amount = parseFloat(term_total * ($(this).val() / 100));
			$('#pre-pay-amount').val(parseInt(discount_amount));
		});
    }
    
    /*
     * contact term handler 
     **/
    
      function contractTermHandler(){
    	  $('#contract-term').change(function()
			{
				$('.review_results').display_review();
			}); 
      }
      
      /*
       * rent checkboxes handler 
       **/
      
      function rentCheckboxHandler(){
    	   /* Set rent checkbox state */
			for(bundle_id in bundle_list)
			{
				if(price_model[bundle_id])
				{
					if(price_model[bundle_id]['Rent']){
						
						$('.mrc.mrc_'+bundle_id).show();
					}else					
					{
						$('.mrc.mrc_'+bundle_id).attr('checked', 'checked').hide();
					}
					
				}
			}
      }
      
 	/*** END: handlers ***/
 	/*
 	 * Handle shipping calculation updates 
 	 **/
 	
 	function shippingCalcUpdates(flag){
 		$('#form_Shipping').change(function(e)
		{
			var element = e.originalEvent.srcElement;

			if($(element).attr('name') == 'shipping_method')
			{
				return false;
			}

			calculate_shipping();
		});
 		if(flag)$('.next_button').fadeIn().position({ my: "right bottom", at: "right top", of: "#form_categories"});
 		//add the handlers
 		reviewButtonHandler();
 		closeReviewWindowHandler();
 		applyManagerDiscountHandler();
 		countrySelectorHandler();	
 		prepayToPctHandler();
 		contractTermHandler();
 		rentCheckboxHandler();
 	}
 	
 	/*
 	 * handles selection change for the bundle
 	 **/
 	
 	function bundleSelectorHandler(id){
 		$('.bundle_selector.category_id_'+ id).change(function()
		{
			var bundle = $(this).val();
			$('.bundle_selector_input').attr('name', bundle);
			$('.bundle_selector_price').text('$'+item_price[bundle]);
			$('.bundle_selector_label').text(decodeURIComponent(item_name[bundle]));
			 
		});
		/*$('.bundle_select_form_element.category_id_'+ id).first().each(function()
		{
			$(this).removeClass('ui-state-disabled').addClass('ui-state-highlight');
			bundle_select_form_element_hover($(this));
		});*/
 	}
 	
 	/*
 	 * Update the review panel by selector 
 	 **/
 	
 	$.fn.display_review = function(settings)
 		{
 			var e = $(this);
 			var total_price = 0;
 			var total_price_discount = 0;

 			var total_mrc = 0;
 			var total_mrc_discount = 0;

 			// We need to store what the monthly total is with volume discount only for calculating pre-pay amounts
 			var term_price = 0.00;
 			var term_total_price = 0.00;

 			if($.type(settings) != 'object' || !$.isEmptyObject(settings))
 			{
 				settings = {};
 			}
 			
 			$(e).html('<div class="review_title">Summary</div>');
 			var review_table = $('<table id="review_table" cellspacing="0"></table>');
 			 					
 			$('.form_category_div').each(function(idx)
 			{
 				var label = $(this).attr('category_title'); // expando attr
 				var label_id = 'review_category_'+label.replace(/[^a-zA-Z0-9_\-]/g, '_');

 				var data = $(this).review_data();
 				var t = '';

 				if(label != 'Shipping Information' && label != 'Contact Information' && label != 'Service Terms')  // Don't put shipping and contact info into the review 
 				{
 					//header
 					if(data && Object.keys(data).length > 1){
	 					t += '<tr class="review_column"><td class="first"><h5 id="'+label_id+'" style="background-image: url(/iconify?w=8&h=8&icon='+encodeURIComponent(label)+');" class="review_icon">'+label+'</h5></td>';
 					}	
	 					if(idx == 0){
	 						t += '<td><h5>One-Time</h5></td><td class="last"><h5>Monthly</h5></td>';
	 					}else{
	 						t += '<td>&nbsp;</td><td class="last">&nbsp;</td>';
	 					}
	 					t += '</tr>';
 						
 					
 					//get the data
 					if(data)
 					{
 						var cnt = 0;

 						for(i in data)
 						{
 						  if(typeof i != "undefined" && data.hasOwnProperty(i)){	
 							t += '<tr class="review_column data">';	  
 							cnt++;
 							var buy = { price: 0.00, qty: 0, base: 0.00 };
 							var mrc = { price: 0.00, qty: 0, base: 0.00 };
 							
 							if(data[i].is_rented > 0)
 							{
 								mrc.price = data[i].is_rented * item_mrc[i];
 								mrc.qty = data[i].is_rented;
 								buy.price = ( data[i].value - data[i].is_rented ) * item_price[i];
 								buy.qty = data[i].value - data[i].is_rented;
 							}
 							else
 							{
 								buy.price = data[i].value * item_price[i];
 								buy.qty = data[i].value;
 							}

 							// Pre discount prices
 							buy.base = buy.price;
 							mrc.base = mrc.price;

 							if(volume_discount[i])
 							{
 								if(buy.price)
 									buy.price = buy.price * (1-volume_discount[i]);

 								if(mrc.price)
 									mrc.price = mrc.price * (1-volume_discount[i]);
 							}

 							// Set term pricing now
 							if(mrc.qty)
 								term_price = term_price + mrc.price;

 							if(prepay_discount[i])
 							{
 								if(buy.price > 0)
 									buy.price = buy.price * (1-prepay_discount[i]);

 								if(mrc.price > 0)
 									mrc.price = mrc.price * (1-prepay_discount[i]);
 							}
 							
 							if(isNaN(buy.price))buy.price = 0;
 							if(isNaN(mrc.price))mrc.price = 0;
 							if(isNaN(buy.base))buy.base = 0;

 							if(buy.qty)
 							{
 								//total_price = total_price + buy.base;
 								total_price += buy.price;
 								
 								total_price_discount += (buy.base - buy.price);
 								buy.price = buy.price;
 							}	
 								

 							if(mrc.qty)
 							{
 								total_mrc = total_mrc + mrc.price;
 								total_mrc_discount = total_mrc_discount + (mrc.base - mrc.price);
 								//total_price = total_price + mrc.price;
 								//if(isNaN(total_price))total_price = 0;
 								if(isNaN(total_mrc))total_mrc = 0;
 								if(isNaN(total_mrc_discount))total_mrc_discount = 0;
 							}
 							var item_amt = data[i].value;
 							
 							if(mrc.qty > 0) item_amt = data[i].is_rented;
 							t += '<td class="first">';
 							if(buy.qty > 0 || mrc.qty > 0){
 							   t += '<div class="review_label" category_id="Review" description="'+item_name[i]+'">'+item_amt+' - '+data[i].label+'</div>';
 							}   
 							t += '</td><td>';
 							if(buy.qty > 0)
 							{
 								
 								if(isNaN(buy.price))buy.price = 0;
 								t += '<div class="review_amount">$'+Math.ceil(buy.price)+'</div>';
 							}

 							t += '</td><td class="last">';
 							if(mrc.qty > 0)
 							{
 								if(isNaN(mrc.price))mrc.price = 0; 
 								t += '<div class="review_amount">$'+Math.ceil(mrc.price)+'</div>';
 							}
 							t += '</td></tr>';
 						  }	
 						}

 						if(cnt == 0)
 						{
 							
 							t += '<tr><td colspan="3"><div class="review_element" category_id="Review" description="No items selected in this category">No items selected</div></td></tr>';
 						}
 						
 					}else{
 						t += '<tr><td colspan="3"><div class="review_element" category_id="Review" description="No Data Available">No Data Available</div></td></tr>';
 					}
                    
 					$(review_table).append(t);
 				}
 			});
 			
 			var term_months;
 			var prepay_amount = $('#pre-pay-percentage').val();
 			if(!prepay_amount)
 				prepay_amount = 0.00;

 			if(total_mrc > 0)
 			{
 				term_months = $('#contract-term').val();

 				if(!term_months)
 				{
 					term_months = 12;
 				}

 				term_total = (term_months - 1) * term_price;
 				term_total_prepay = (term_months - 1) * total_mrc;
 				if(isNaN(term_total))term_total = 0;
 				if(isNaN(term_total_prepay))term_total_prepay = 0;
 			}

 			// Discount section
 			var discounts = '<tr class="review_column"><td class="first"><h5 id="total_discounts" class="review_icon">Discounts</h5></td><td>';
 			//remove the bellow hard code data when we get the data from the BE and move the above line into the 'if' statment
 			discounts += '&nbsp;</td><td class="last">&nbsp;</td></tr>';
 			discounts += '<tr class="review_column data"><td class="first"><div class="review_label" category_id="Review" description="50% off 331">50% off 331</div></td><td>&nbsp</td><td class="last">';
 			discounts += '<div class="review_amount green">($25)</div></td></tr>';
 			discounts += '<tr class="review_column data"><td class="first"><div class="review_label" category_id="Review" description="Manager (5%)">Manager (5%)</div></td><td>&nbsp</td><td class="last">';
 			discounts += '<div class="review_amount green">($9.25)</div></td></tr>';
 			//END remove the bellow hard code data when we get the data from the BE
 			
 			if(total_price_discount > 0 || total_mrc_discount > 0)
 			{
 				 
 				if(total_price_discount > 0){
 					discounts += '<div class="review_amount">($'+Math.ceil(total_price_discount)+')</div></td><td class="last">';
 			    }else{
 			    	discounts += '&nbsp;</td><td class="last">';
 			    }
 				if(total_mrc_discount > 0){
 					 discounts +='<div class="review_amount">($'+Math.ceil(total_mrc_discount)+')</div></td>';
 				}else{
 					 discounts += '&nbsp;</td>';
 				}
 				 discounts += '</tr>';
 				
 			}
 			 $(review_table).append(discounts); //move this line into the 'if' statement when we change the hard coded lines to dynamic
 			// End Discount Section
 			
 			//taxes & fees section
 			var taxes_and_fees = '<tr class="review_column"><td class="first"><h5 id="total_discounts" class="review_icon">Taxes/Fees</h5></td><td>';
 			taxes_and_fees += '<div class="review_amount">$3.82</div></td><td class="last"><div class="review_amount">$19.82*</div></td>';
 			taxes_and_fees += '</tr>';
 			$(review_table).append(taxes_and_fees);
 			//End taxes & fees section

 			// Display totals
 			var totals = '<tr class="review_column">';
 			totals += '<td class="first"><h5 id="total_price" class="review_icon">Totals</h5></td>';
 			totals += '<td><div class="review_amount total">$'+Math.ceil(total_price)+'</div></td>';
 			totals += '<td class="last"><div class="review_amount total">$'+Math.ceil(total_mrc)+'</div></td>';
 			totals += '</tr>';
 			$(review_table).append(totals);
 			$(e).append(review_table);
 			//$(e).append('<div class="review_label" category_id="Review" description="Term Price">Total over '+term_months+' months: </div><div class="review_amount">$'+Math.ceil(term_total)+'</div>');
 			//$(e).append('<div class="review_label" category_id="Review" description="Term Price">Pre-pay '+prepay_amount+'% over '+term_months+' months: </div><div class="review_amount">$'+Math.ceil(term_total_prepay)+'</div></div>');
 						
 			$(e).append('<div><div class="review_label" category_id="Review" description="Total Cost Of Ownership" style="width: 210px;">Total Cost Of Ownership</div><div class="review_amount total">$' + (Math.ceil(total_price) + Math.ceil(total_mrc) ) + '</div>');
 			$(e).append('<div id="review_note">* Based on estimated usage - amounts may vary.</div></div>');
 			
 			
 			createCustomeScroll(e);
 			
 			 			 			 			
 		}

 	
 	/*
 	 * Retrieve all quote data from the page and return an object 
 	 **/
 	
 	 $.fn.review_data = function(form_input_only)
 		{
 	        	var form_data = {};

 			//$(this).find('input:not(.mrc,:button,:submit, :reset),select:not(.mrc)').map(function(index, element)
 	        	$(this).find('input:not(.mrc),select:not(.mrc)').map(function(index, element)
 			{
 				var label;
 				var name;
 				var desc;
 				var rent;

 				var category = $(element).closest('.form_category_div').attr('id');
 				var category_id = $(element).closest('.form_category_div').attr('category_id');
 				

 				if(category == 'Shipping' || category == 'Contact' || category == 'Discounts' || category == 'Terms')
 				{
 					return true; // equal to continue for find
 				}

 				if(element.type == 'select' || element.type == 'select-one')
 				{
 					label = item_name[$(element).val()];
 					name = $(element).val();
 					desc = item_description[$(element).val()];
 				}
 				else
 				{	
 					
	 					label = item_name[$(element).attr('name')];
	 					name = $(element).attr('name');
	 					desc = item_description[name];
 						
 				}

 				form_data[name] = {};

 				if(!label || label == undefined)
 					label = '';//'Invalid item';

 				if(!form_input_only)
 					form_data[name].label = decodeURIComponent(label);

 				if(element.type == 'checkbox')
 				{
 					if($(element).is(':checked'))
 					{
 						form_data[name].value = 1;
 					}
 				}
 				else
 				{
 					if(element.type == 'select' || element.type == 'select-one')
 					{
 							if($(element).attr('value'))
 							{
 								form_data[name].value = 1;
 							}
 					}
 					else
 					{
 						if(element.type != 'submit' && element.type != 'button' && element.type != 'reset')
 						{
 							form_data[name].value = $(element).val();
 						}
 					}
 				}

 					
 				if(!form_data[name].value)
 				{
 					delete form_data[name];
 				}

 				if(form_data[name])
 				{
 					form_data[name].id = name;
 					if(!form_input_only)
 					{
 						form_data[name].desc = desc;
 						form_data[name].category_id = category_id;
 						form_data[name].category_name = category;
 						form_data[name].label = label;
 					}

 					if($('.mrc_'+name+':checked').length > 0)
 						form_data[name].is_rented = form_data[name].value;
 				}

 			});

 			//confirm(jsDump.parse(form_data));
 			return form_data;
 		} 
 	
 	/*
 	Submit a quote to the server.

	Before calling this, make sure that:

		1. Shipping info is saved to session
		2. Contact info is saved to session
		3. Progress is saved to session

        #################################################################
     **/
function submit_quote()
{
	//$('#submit_button').addClass('ui-state-disabled').attr('disabled', 'true');

	$('#status-message').text('Submitting Quote Information...');
	
	//get shipping info
	var shipping_json = get_shipping_info();
	
	//get contact data
	var contact_json = get_contact_info();
	//get bundles
	var bundles_json = $('#form_components').review_data(1);
	
	$.ajax({
		dataType: 'json',
		url: '/',
		type: 'POST',
		data: { 
			action: 'submit_quote', 
			mode: 'Sales.Create_Quote',
			shipping: JSON.stringify(shipping_json),
			contact: JSON.stringify(contact_json),
			bundles: JSON.stringify(bundles_json),
			term_in_months: $('#contract-term').val(),
		    prepay_amount: $('#pre-pay-percentage').val()
			},
		success: function(data)
		{
			

			if(data && data.success)
			{
				$('#status-message').text('Your quote has been submitted.  Loading confirmation page');
				window.location = '/?m=Sales.Create_Quote&action=complete&guid='+data.success;
			}
			else
			{
				alert("There was an error processing your quote. The server said:<br> "+data.error_msg+"<br>Please try again.");
				$('#submit_button').removeClass('ui-state-disabled').removeAttr('disabled');
				$('#status-window').dialog('close');
			}
		},
		errorCallback: function(j, err)
		{
			$('#status-window').dialog('close');
		}
	});
}	
/* 
#################################################################
	Call this when hovering over an option in the
	top preview form.  
	This is a helper for top_preview_form_hover.
#################################################################
*/ 
function top_preview_form_element_hover(e)
{
	var category_id = $(e).attr('category_id');
	var item_id = $(e).attr('item_id');

	top_preview_form_hover($(e), category_id, item_id);
}

function bundle_select_form_element_hover(e)
{
	var category_id = $(e).attr('category_id');
	var item_id = $(e).attr('item_id');
	bundle_select_form_hover($(e), category_id, item_id);
}
/* 
#################################################################
	This actually handles the top preview form hovering
#################################################################
*/ 
function top_preview_form_hover(element, category_id, item_id)
{
	if(!element || !category_id || !item_id)
		return false;

	description = item_description[item_id];
	if(!description)
		description = 'No description available';

	var item = element.text();

	$('#top_preview_image_panel_'+category_id).html('<h4>'+item+'</h4><p><img src="/iconify?&w=100&h=100&icon='+item+'" align="left" width="100" height="100">'+description).fadeIn('slow');
	
}

function bundle_select_form_hover(element, category_id, item_id)
{
	if(!element || !category_id || !item_id)
		return false;

	//description = item_description[item_id];
	description = $(element).attr('description');
	var item = element.text();
	
	$('#preview_panel_'+category_id).html('<h4>'+item+'</h4><p><img src="/iconify?&w=100&h=100&icon='+$.trim($(element).attr('display_name').replace(/<br\s?\/?>/, ''))+'" align="left" width="100" height="100">'+description).fadeIn('slow');
	
}

	function get_shipping_info()
{
	var form_data = {};

	$('#Shipping').find('input,select').map(function(index, element)
	{
		form_data[$(element).attr('name')] = $(element).val();
	});

	return form_data;
}

function get_contact_info()
{
	var form_data = {};

	$('#Contact').find('input,select').map(function(index, element)
	{
		form_data[$(element).attr('name')] = $(element).val();
	});

	return form_data;
}

function save_contact()
{
	contact_saved = false;
	contact_error = false;

	$('#status-message').text('Validating Contact Information...');

	var form_data = get_contact_info();

	var data = { action: 'save_contact', mode: 'Sales.Create_Quote', form_data: JSON.stringify(form_data) };

	if(contact_xhr && contact_xhr.readyState != 4)
	{
		contact_xhr.abort();
	}

	contact_xhr = $.ajax({
		url: '/',
		dataType: 'JSON',
		type: 'POST',
		data: data,
		success: function(data) 
		{
			if(!data.success) 
			{
				contact_error = data.error_msg;
				alert('Could not validate contact information.');
			} 

			contact_saved = true;
			$('#status-message').text('Contact Information Validated.');
		},
		errorCallback: function(j, error)
		{
			// Ready state 0 probably means we aborted a request, which isn't an error
			if(contact_xhr.readyState > 0)
				contact_error = error;
		}
	});
}

function save_shipping()
{
	shipping_saved = false;
	shipping_error = false;

	$('#status-message').text('Validating Shipping Information...');

	var form_data = get_shipping_info();

	var data = { action: 'save_shipping', mode: 'Sales.Create_Quote', form_data: JSON.stringify(form_data) };

	if(shipping_xhr && shipping_xhr.readyState != 4)
	{
		shipping_xhr.abort();
	}

	shipping_saved = false;

	shipping_xhr = $.ajax({
		url: '/',
		dataType: 'JSON',
		type: 'POST',
		data: data,
		success: function(data) 
		{
			if(!data.success) 
			{
				shipping_error = data.error_msg;
			} 
			shipping_saved = true;
			$('#status-message').text('Shipping Information Validated.');
		},
		errorCallback: function(j, error)
		{
			// Ready state 0 probably means that we aborted the request, which is not an error
			if(shipping_xhr.readyState > 0)
				shipping_error = error;
		}
	});
}

// Save current progress to session 
function save_progress()
{
	progress_saved = false;
	progress_error = false;

	$('#status-message').text('Saving Quote Information...');

	if(sync_changes == false)
	{
		progress_saved = true;
		$('#status-message').text('Quote Information Saved.');
		return true;
	}

	var form_data = $('#form_components').review_data(1);
	var data = {};
	data.action = 'save_progress';
	data.mode = 'Sales.Create_Quote';
	data.form_data = JSON.stringify(form_data);
	data.term_in_months = $('#contract-term').val();
	data.prepay_amount = $('#pre-pay-percentage').val();

	if(progress_xhr && progress_xhr.readyState != 4)
	{
		progress_xhr.abort();
	}

	progress_xhr = $.ajax({
		url: '/',
		dataType: 'JSON',
		type: 'POST',
		data: data,
		success: function(data) { 
			sync_changes = false;
			if(!data.success) { 
				progress_error = data.error_msg;
			}
			$('#status-message').text('Quote Information Saved.'); 
			progress_saved = true;
		},
		errorCallback: function(j, err)
		{
			if(progress_xhr.readyState > 0)
				progress_error = err;
		}
	});
}

// Save pre category form data
function save_pre_form_category(category, category_name)
{
	$('#bundle_select_submit').fadeOut();
	var form_data = $('#form_category_'+category_name).review_data(1);

	if($.isEmptyObject(form_data))
	{
		$('#bundle_select_submit').fadeIn();
		alert('Please enter a value');
		return false;
	}

	$('#status-message').text('Saving your selection...');

	$('#status-window').dialog('open');

	var data = { action: 'save_pre_form_category', mode: 'Sales.Create_Quote', form_data: JSON.stringify(form_data), category: category };

	$.ajax({
		url: '/',
		dataType: 'JSON',
		type: 'POST',
		data: data,
		success: function(data)
		{
			$('#status-message').text('Selection saved. Please wait...');

			if(data.success)
			{
				window.location = '/?m=Sales.Create_Quote';
			}
			else
			{
				$('#status-window').dialog('close');
				$('#bundle_select_submit').fadeIn();
			}
		}
	});
}

function validate_forms()
{
	var change_index;
	var change_to = 0;

	$('.form_category_div').each(function()
	{
		var category = $(this).attr('id');

		if($('#form_'+category).valid())
		{
			$('#icon_'+category).parent().removeClass('category_icon_error');
		}
		else
		{
			$('#icon_'+category).parent().addClass('category_icon_error');
			//$('#icon_'+category).addClass('ui-state-error');
			if(!change_index)
				change_index = change_to;
		}
		change_to++;
	});

	if(change_index)
	{
		$('#form_components').tabs("select", change_index);
		return false;
	}

	$(".display_right_preview_form").mCustomScrollbar("update");

	return true;
}

function init_shipping()
{
	return true;
	if($('#shipping_method').children().length <= 1)
	{
		calculate_shipping();
	}
}

function calculate_discounts()
{
	// Clear holders for discounts ( sorry ie6, upgrade )
	prepay_discount = {};
	volume_discount = {};

	// Form data holder
	var form_data = {};


	// Display loading text
	$('#pre-pay-discount-status').html('&nbsp;&nbsp;% Calculating..');

	form_data.quote_json = $('#form_components').review_data(1);
	form_data.prepay_amount = parseFloat($('#pre-pay-percentage').val());
	form_data.term_in_months = parseInt($('#contract-term').val());

	var data = { action: 'calculate_discounts', mode: 'Sales.Create_Quote', prepay_amount: form_data.prepay_amount, term_in_months: form_data.term_in_months };

	// Cancel any pending AJAX request for discount calculation
	if(discount_xhr && discount_xhr.ready_state != 4)
		discount_xhr.abort();

	discount_xhr = $.ajax({
		url: '/',
		dataType: 'json',
		type: 'POST',
		data: data,
		success: function(data)
		{
			if(data && data.status == 1)
			{
				if(data.results && data.results.total_discount && data.results.total_discount > 0)
				{
					for(i in data.results.apply_to)
					{
						volume_discount[i] = data.results.volume_discount;
						prepay_discount[i] = data.results.prepay_discount;
					}

					// Update review panel
					$('.review_results').display_review();
				}
			}
			else
			{
				alert('Could not retrieve discount calculation from server!');
			}
		},
		complete: function()
		{
			$('#pre-pay-discount-status').html('&nbsp;&nbsp;%');
		}
	});
}

function calculate_shipping()
{
	var shipping_fields = new Array('addr1', 'city', 'state_prov', 'postal', 'country');

	var shipping_data = {};

	for(i in shipping_fields)
	{
		shipping_data[shipping_fields[i]] = $('#'+shipping_fields[i]).val();
	}

	if(!shipping_data.country)
	{
		return true;
	}

	if(shipping_data.country == 'US' || shipping_data.country == 'CA')
	{
		//$('#postal').parent().parent().parent().fadeIn();
		//$('#state_prov').parent().parent().parent().fadeIn();

		if(!shipping_data.addr1 || !shipping_data.city || !shipping_data.state_prov || !shipping_data.postal)
		{
			return true;
		}
	}
	else
	{
		//$('#state_prov').parent().parent().parent().fadeOut();

		if(!shipping_fields.addr1 || !$shipping_fields.city)
			return;
	}

	$('#shipping_method').children().remove();
	$('#shipping_method').addClass('ui-state-disabled').append($('<option>', { value: '' }).text('Calculating..'));

	shipping_saved = false;
	progress_saved = false;
	
	save_shipping();

	shipping_status = setInterval(function()
	{
		if(shipping_saved == true)
		{
			shipping_saved = false;

			clearInterval(shipping_status);

			if(shipping_error && shipping_error != "")
			{
				alert(shipping_error);
			}
			else
			{
				save_progress();

				progress_status = setInterval(function()
				{
					if(progress_saved == true)
					{
						progress_saved = false;

						clearInterval(progress_status);

						if(progress_error)
						{
							alert(progress_error);
						}
						else
						{
							if(shipping_calculator_xhr && shipping_calculator_xhr.ready_state != 4)
								shipping_calculator_xhr.abort();

							var shipping_calculator_xhr = $.ajax({
								url: '/',
								data: { mode: 'Sales.Create_Quote', action: 'calculate_shipping' },
								type: 'POST',
								dataType: 'JSON',
								success: function(data)
								{
									if(data && data.services)
									{
										for(i in data.services)
										{
											$('#shipping_method').append($('<option>', { value: data.services[i].service }).text(data.services[i].carrier + ' ' + data.services[i].service + ' ($'+data.services[i].rate+')'));
										}

										$('#shipping_method').children().first().text('Select shipping service');
										$('#shipping_method').removeAttr('disabled').removeClass('ui-state-disabled');
									}
								},
								complete: function()
								{

								}
							});
						}
					}
				}, 100);
			}
		}
	}, 100);

}


function init(){
	//Create status window dialog
    createDialog();
    
	if(isSelectedDeployment){
	  if(!isUserTypeView){	
		$('#status-message').text('Assembling your order. Please wait...');
	    $('#status-window').dialog('open');
	  }  
	     retrieveBundleData(isSelectedDeployment) ;
	} 

	$(document).ready(function(){
		    	onPageLoad();
				//check for dependencies
		       // bundle_dependencies(bundle_dependency_options);
				validateCategoryForm();
				// Make sure all forms have their validation rules already defined
				bundle_dependencies(bundle_dependency_options);
	            //Initialize buttons
		       	initializeButtons();
		     
		        /* 
		            Submit quote - crazy setInterval loop to track status
		            of validating and saving shipping info, contact info
		            and progress before actually submitting the quote which
		            is done via the browser session, not by sending form
		            data to the server.
		         */ 
				submitQuote();
				//select the proper selection in the top_preview_window display type
			    selectElChange();
		        //SESSION HANDLER - Populate variables from session
				populateFromServer(quoteServer);
            	//SESSION HANDLER - Populate shipping info from session
				populateShippingInfo(shippingServer);
            	//SESSION HANDLER - Populate contact info from session
				populateContactInfo(contact);
				//initialize shipping
				init_shipping();
                //Update the review panel
				updateReviewPanel();
		    	//Tabs / List toggle - TODO: Clean this mess up
				toggleTabs();
				//Create mCustomScrollbar for each right preview div
				createCustomeScroll($(".display_right_preview_form"));
            	//Create form components tabs
				if(fadeNext == true) createFormComponents(fadeNext);
				//add handlers to the deployment selections
		        selectDeployment();	
            	//Form label hover handler for right preview panels
				formLabelHandler();
				//Selection hover and click handler for top preview panels
				previewHandlers();
				//Selection hover and click handler for pre category panels
				preCatHandlers();
				//Handle shipping calculation updates
				shippingCalcUpdates(fadeNext);
				calculate_discounts();
		    });
		     // END on document ready
}