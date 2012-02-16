/* hjq-sortable-collection */
(function($) {
    var methods = {
        init: function(annotations) {
            var options = $.extend({update: methods.update}, this.hjq('getOptions', annotations));
            this.sortable(options);
        },

        update: function() {
            var that=$(this);
            var annotations=that.data('rapid')['sortable-collection'];
            var roptions = that.hjq('buildRequest', {type: 'post',
                                                     attrs: annotations.ajax_attrs
                                                    });
            roptions.data['authenticity_token']=that.hjq('pageData').form_auth_token.value;
            roptions.data=$.param(roptions.data);
            that.children("*[data-rapid-context]").each(function(i) {
                roptions.data = roptions.data+"&"+annotations.reorder_parameter+"[]="+$(this).hjq('contextId');
            });

            $.ajax(annotations.reorder_url, roptions);
            return that;
        }

    };


    $.fn.hjq_sortable_collection = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_sortable_collection' );
        }
    };

})( jQuery );
