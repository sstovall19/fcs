$(function() {
	
		$( "#dialog-message" ).dialog({
			modal: true,
			buttons: {
				Ok: function() {
					$( this ).dialog( "close" );
				}
			},
			autoOpen: false
		});

		$( "#dialog-open" ).click(function()
		{
			$('#dialog-message').dialog('open');
		});
	});