/* click_editor */
(function($) {
    var methods = {
        init: function(annotations) {
            this.removeClass('hidden').click(methods.click);
            this.next('.in-place-form').hide().on('blur', ':input', methods.blur).on('change', methods.change);
        },

        click: function(event) {
            var that=$(this);
            var annotations=that.data('rapid')['click-editor'];
            that.hjq('hide', annotations.hide, function() {
                that.next('.in-place-form').hjq('show', annotations.show, function() {
                    $(this).find('textarea,input[type=text]').focus();

                });
            });
        },

        blur: function(event) {
            var $formlet = $(this).closest('.in-place-form');
            var $span = $formlet.siblings('.in-place-edit')
            var annotations = $span.data('rapid')['click-editor'];
            $formlet.hjq('hide', annotations.hide);
            $span.hjq('show', annotations.show);
        },

        change: function(event) {
            var formlet = $(this).closest('.in-place-form');
            formlet.prev('.in-place-edit').text('saving...');
            formlet.hjq_formlet('submit');
        }
    };

    $.fn.hjq_click_editor = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_click_editor' );
        }
    };

})( jQuery );
