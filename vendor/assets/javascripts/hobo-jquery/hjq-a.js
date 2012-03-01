/* a */
(function($) {
    var methods = {
        init: function(annotations) {
            this.on('click', methods.click);
        },

        click: function() {
            var that = $(this);
            var options = that.data('rapid').a.ajax_attrs;
            if(!options.message) options.message="Loading...";
            var roptions = that.hjq('buildRequest', {
                type: 'GET',
                attrs: options
            });
            if(options.push_state) {
                window.History.pushState(null, options.new_title || null, that.attr('href'));
            };
            $.ajax(that.attr('href'), roptions);
            return false;
        }
    };
    $.fn.hjq_a = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_form' );
        }
    };
})( jQuery );
