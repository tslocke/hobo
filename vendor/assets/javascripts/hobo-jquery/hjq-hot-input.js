/* hot-input */
(function($) {
    $.fn.hjq_hot_input = function(annotations) {
        this.on(annotations.events, annotations.selector, function (event) {
            var that=$(this);
            var form=that.parents('form');
            var roptions=that.hjq('buildRequest', {type: annotations.method, attrs: annotations.ajax_attrs});
            var data = form.find(":input").not(form.find(".formlet :input")).serialize();
            roptions.data = $.param(roptions.data) + "&" + data;
            $.ajax(annotations.path, roptions);

            return false;
        });
    }
})( jQuery );
