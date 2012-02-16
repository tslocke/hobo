/* delete-button */
(function($) {
    var methods = {
        init: function(annotations) {
            var that=this;
            this.on('rapid:ajax:success.hjq_delete_button', function (ev, el) {
                methods.remove.call(that, annotations, ev, el);
            });
        },

        /* removes the element from the DOM, etc.  Does not actually
         * do the ajax delete call -- form.submit does that. */
        remove: function(annotations, ev, el) {
            if(!annotations) annotations=this.data('rapid')['delete_button'];
            // select only top most elements
            var selector = '[data-rapid-context="'+this.data('rapid-context')+'"]';
            $(selector).not(selector+" "+selector).each(function() {
                var that=$(this);
                if(that.siblings().length==0) {
                    that.parents().each(function() {
                        var done=$(this).siblings(".empty-collection-message").hjq('show', annotations.show).length;
                        return !done;
                    })
                }
                that.hjq('hideAndRemove', annotations.hide);
            });
            return this;
        }
    };


    $.fn.hjq_delete_button = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_delete_button' );
        }
    };

})( jQuery );
