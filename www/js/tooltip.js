function tooltip(){
	// Auto tool tip handling.  Use span / div class help-tip and put text in the "title" attribute
	$(".help-tip").each(function() {
		var tooltext = $(this).attr('title');
		$(this).tooltip({
			delay: 0,
			track: true,
			showbody: " - ",
			extraClass: "ui-widget ui-widget-content ui-state-highlight normalfont ui-corner-all",
			bodyHandler: function() {
				return tooltext;
			}
		})
	});
}