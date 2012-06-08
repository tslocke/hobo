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
            var hobo_options = {type: 'GET', attrs: options};
            var roptions = that.hjq('buildRequestData', hobo_options);
            that.hjq("changeLocationAjax", that.attr('href'), roptions, hobo_options);
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
