/* stolen from http://jqueryui.com/demos/autocomplete/#combobox
 *
 * and these options added.
 *
 * - autoFill (default: true):  select first value rather than clearing if there's a match
 *
 * - clearButton (default: true): add a "clear" button
 *
 * - adjustWidth (default: true): if true, will set the autocomplete width the same as
 *    the old select.  (requires jQuery 1.4.4 to work on IE8)
 *
 * - uiStyle (default: false): if true, will add classes so that the autocomplete input
 *    takes a jQuery-UI style
 */
(function( $ ) {
    $.widget( "ui.combobox", {
        options: {
            autoFill: true,
            clearButton: true,
            adjustWidth: true,
            uiStyle: false,
            selected: null
        },
	_create: function() {
	    var self = this,
	      select = this.element.hide(),
	      selected = select.children( ":selected" ),
	      value = selected.val() ? selected.text() : "",
              found = false;
	    var input = this.input = $( "<input>" )
                .attr('title', '' + select.attr("title") + '')
		.insertAfter( select )
		.val( value )
		.autocomplete({
		    delay: 0,
		    minLength: 0,
		    source: function( request, response ) {
		        var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
                        var resp = select.children( "option" ).map(function() {
		            var text = $( this ).text();
		            if ( this.value && ( !request.term || matcher.test(text) ) )
		        	return {
		        	    label: text.replace(
		        		new RegExp(
		        		    "(?![^&;]+;)(?!<[^<>]*)(" +
		        			$.ui.autocomplete.escapeRegex(request.term) +
		        			")(?![^<>]*>)(?![^&;]+;)", "gi"
		        		), "<strong>$1</strong>" ),
		        	    value: text,
		        	    option: this
		        	};
		        });
                        found = resp.length > 0;
		        response( resp );
		    },
		    select: function( event, ui ) {
		        ui.item.option.selected = true;
		        self._trigger( "selected", event, {
		            item: ui.item.option
		        });
		    },
		    change: function( event, ui ) {
		        if ( !ui.item ) {
		            var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( $(this).val() ) + "$", "i" ),
		            valid = false;
		            select.children( "option" ).each(function() {
		        	if ( $( this ).text().match( matcher ) ) {
		        	    this.selected = valid = true;
		        	    return false;
		        	}
		            });
		            if ( !valid || input.data("autocomplete").term=="" ) {
		        	// set to first suggestion, unless blank or autoFill is turned off
                                var suggestion;
                                if(!self.options.autoFill || input.data("autocomplete").term=="") found=false;
                                if(found) {
                                    suggestion = jQuery(input.data("autocomplete").widget()).find("li:first");
                                    var option = select.find("option:contains('"+suggestion.text()+"')").attr('selected', true);
                                    $(this).val(suggestion.text());
		        	    input.data("autocomplete").term = suggestion.text();
		                    self._trigger( "selected", event, { item: option[0] });
                                } else {
                                    select.find("option:selected").removeAttr("selected");
                                    $(this).val('');
		        	    input.data( "autocomplete" ).term = '';
                                    self._trigger( "selected", event, { item: null });
                                }
		        	return found;
		            }
		        }
		    }
		});

            if( self.options.adjustWidth ) { input.width(select.width()); }

            if( self.options.uiStyle ) {
                input.addClass( "ui-widget ui-widget-content ui-corner-left" );
            }


	    input.data( "autocomplete" )._renderItem = function( ul, item ) {
	        return $( "<li></li>" )
	            .data( "item.autocomplete", item )
	            .append( "<a>" + item.label + "</a>" )
	            .appendTo( ul );
	    };

	    this.button = $( "<button type='button'>&nbsp;</button>" )
	        .attr( "tabIndex", -1 )
	        .attr( "title", "Show All Items" )
	        .insertAfter( input )
	        .button({
	            icons: {
	        	primary: "ui-icon-triangle-1-s"
	            },
	            text: false
	        })
	        .removeClass( "ui-corner-all" )
	        .addClass( "ui-corner-right ui-button-icon" )
	        .click(function() {
	            // close if already visible
	            if ( input.autocomplete( "widget" ).is( ":visible" ) ) {
	        	input.autocomplete( "close" );
	        	return;
	            }

	            // work around a bug (likely same cause as #5265)
	            $( this ).blur();

	            // pass empty string as value to search for, displaying all results
	            input.autocomplete( "search", "" );
	            input.focus();
	        });

            if( self.options.clearButton ) {
	        this.clear_button = $( "<button type='button'>&nbsp;</button>" )
	            .attr( "tabIndex", -1 )
	            .attr( "title", "Clear Entry" )
	            .insertAfter( input )
	            .button({
	                icons: {
	        	    primary: "ui-icon-close"
	                },
	                text: false
	            })
	            .removeClass( "ui-corner-all" )
	            .click(function(event, ui) {

                        select.find("option:selected").removeAttr("selected");
                        select.val(null);
                        input.val( "" );
	                input.data( "autocomplete" ).term = "";
                        self._trigger( "selected", event, { item: null });

	                // work around a bug (likely same cause as #5265)
	                $( this ).blur();
	            });
            }

	},

	destroy: function() {
	    this.input.remove();
	    this.button.remove();
	    this.element.show();
	    $.Widget.prototype.destroy.call( this );
	}
    });
})( jQuery );
