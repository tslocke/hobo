/* live_editor */
(function($) {
    var methods = {
        init: function(annotations) {
            $(this).on('change', methods.change);
        },

        change: function(event) {
            var formlet = $(this).closest('.in-place-form');
            formlet.hjq_formlet('submit');
        }
    };

    $.fn.hjq_live_editor = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_live_editor' );
        }
    };

})( jQuery );
