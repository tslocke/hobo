/* datepicker */
(function($) {
    var methods = {
        init: function(annotations) {
            if(!this.attr('disabled')) {
                this.datepicker(this.hjq('getOptions', annotations));
            }
        }
    };

    $.fn.hjq_datepicker = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_datepicker' );
        }
    };

})( jQuery );
