/* live_search */
(function($) {
    $.fn.hjq_live_search = function(annotations) {
        var form=this.children("form");
        // form.on("rapid:ajax:success.live_search", function() {
        //     $.each(form.hjq("getUpdateIds", form.data('rapid').form.ajax_attrs), function() {
        //         $("#"+this).trigger("rapid:open_search_results");
        //     });
        // });

        // TODO: call form.trigger('submit') on keystroke pause
    }
})( jQuery );
