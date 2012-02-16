/* form */
(function($) {
    var methods = {
        init: function(annotations) {
            $(this).on('submit', methods.submit);
        },

        // you should be able to call this externally:
        // $(foo).hjq('submit');   It can be called on the form or any
        // child of the form
        submit: function () {
            var form = $(this).closest("form");
            if(form.length==0) return false;
            var annotations = form.data('rapid').form;

            var options = {type: form[0].method,
                           attrs: annotations.ajax_attrs,
                          };

            if(form.attr('enctype') == 'multipart/form-data') {
                if(form.ajaxSubmit) {
                    var roptions= form.hjq('buildRequest', $.extend(options, {preamble: '<textarea>', postamble: '</textarea>', content_type: 'text/html'}));

                    if(!roptions) return false;
                    roptions.iframe = true;
                    form.ajaxSubmit(roptions);
                } else {
                    alert("malsup's jquery form plugin required to do ajax submissions of multipart forms");
                }

            } else {
                var roptions= form.hjq('buildRequest', options);
                if(!roptions) return false;

                // make sure we don't serialize any nested formlets
                var data = form.find(":input").
                    not(form.find(".formlet :input")).
                    serialize();

                roptions.data = $.param(roptions.data) + "&" + data;

                $.ajax(form[0].action, roptions);
            }

            // prevent bubbling
            return false;
        }
    };

    $.fn.hjq_form = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_form' );
        }
    };

})( jQuery );
