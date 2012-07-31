/* dialog */
(function($) {
    var methods = {
        init: function(annotations) {
            var options=this.hjq('getOptions', annotations);
            if(!options.position) { options.position = {}; }
            if($.isPlainObject(options.position)) {
                this.data('hjq-dialog-position', $.extend({}, {my: 'center', at: 'center center', of: this.prev('.dialog-position')}, options.position));
                delete options.position;
            }
	    if(annotations.buttons) {
                options.buttons = {};
		for(var i=0; i<annotations.buttons.length; i++) {
		    options.buttons[annotations.buttons[i][0]] = this.hjq('createFunction',annotations.buttons[i][1])
		}
	    }
            this.dialog(options);
        },

        open: function() {
            this.dialog('open');
            if(this.data('hjq-dialog-position')) {
                this.parent().position(this.data('hjq-dialog-position'));
            }
        },

        close: function() {
            if(!this.hasClass("dialog-box")) this.parents(".dialog-box").dialog('close');
            else this.dialog('close');
        },

        /* open if closed, close if open */
        toggle: function() {
            var dialog=this;
            if(!this.hasClass("dialog-box")) dialog=this.parents(".dialog_box");
            if(dialog.dialog('isOpen')) {
                methods.close.call(dialog);
            } else {
                methods.open.call(dialog);
            }
        },

        /* useful in the "buttons" option.  Will submit any enclosed
        forms or formlets. */
        submit: function(extra_options, extra_attrs) {
            var dialog=this;
            if(!this.hasClass("dialog-box")) dialog=this.parents(".dialog-box");
            dialog.find("form").trigger('submit');
            dialog.find(".formlet").hjq_formlet('submit', extra_options, extra_attrs);
        },

        /* calls submit, and then closes the dialog box.   */
        /* useful in the "buttons" option.  */
        submitAndClose: function() {
            var that=this;
            methods.submit.call(this, {success: function() {methods.close.call(that);}});
        }
    };

    $.fn.hjq_dialog_box = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_dialog' );
        }
    };

    $.fn.hjq_dialog_open_button = function(annotations) {
        this.on('click', function() {
            $(annotations.selector).hjq_dialog_box('toggle');
            return false;
        });
    };

})( jQuery );


// to make the DRYML interface cleaner, these provide direct access to
// a couple of plugin functions.
var hjq_dialog_box=(function($) {
    return {
        close: function() {
            $(this).hjq_dialog_box('close');
        },

        submit: function() {
            $(this).hjq_dialog_box('submit');
        },

        submitAndClose: function() {
            $(this).hjq_dialog_box('submitAndClose');
        }
    }
})(jQuery);
