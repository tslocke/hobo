/* hjq-sortable-input-many */
(function($) {
    var methods = {
        init: function(annotations) {
            var options = $.extend({update: methods.update}, this.hjq('getOptions', annotations));
            this.sortable(options);
            this.on('rapid:change', methods.countChanged);
        },

        countChanged: function() {
            // added or removed a field
            var that = $(this);
            return that.hjq_sortable_input_many('updatePositions');
        },

        update: function() {
            // fields are reordered
            var that = $(this);
            that.hjq_input_many('updateNames');
            that.hjq_input_many('updateVisibility');
            return that.hjq_sortable_input_many('updatePositions');
        },

        updatePositions: function() {
            var that=$(this);
            var annotations=that.data('rapid')['sortable-input-many'];
            that.find("li:visible input.sortable-position").each(function(index) {
                $(this).val(index+1);
            });
            return that;
        }

    };


    $.fn.hjq_sortable_input_many = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_sortable_input_many' );
        }
    };

})( jQuery );
