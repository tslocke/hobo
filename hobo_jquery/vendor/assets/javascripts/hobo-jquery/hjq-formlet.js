/* formlet */
(function($) {
    var methods = {
        init: function(annotations) {
            this.find('input[type=submit]').on('click', methods.submit);
        },

        // you should be able to call this externally:
        // $(foo).hjq('submit');   It can be called on the formlet or any
        // child of the formlet
        submit: function(extra_callbacks, extra_options) {
            var formlet = $(this).closest(".formlet");
            if(formlet.length==0) return false;
            var annotations = formlet.data('rapid').formlet;

            // make sure we don't serialize any nested forms
            var data = formlet.find(":input").
                not(formlet.find("form :input")).
                not(formlet.find(".formlet :input")).
                serialize();

            var roptions = formlet.hjq('buildRequest',
                                       {type: annotations.form_attrs.method,
                                        attrs: annotations.ajax_attrs,
                                        extra_options: extra_options,
                                        extra_callbacks: extra_callbacks
                                       });
            if(!roptions) return false;

            roptions.data = $.param(roptions.data) + "&" + data;

            $.ajax(annotations.form_attrs.action, roptions);

            return false;
        }
    };

    $.fn.hjq_formlet = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_formlet' );
        }
    };

})( jQuery );
