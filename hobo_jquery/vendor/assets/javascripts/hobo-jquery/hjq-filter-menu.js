/* filter_menu */
jQuery.fn.hjq_filter_menu = function(annotations) {
    this.find('select').on('change', function() {
        jQuery(this).parents('form').submit();
    });
};
