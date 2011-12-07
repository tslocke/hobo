/* combobox */
(function($) {
    $.fn.hjq_combobox = function(annotations) {
        var select = this.find('select');
        if(!select.attr('disabled')) {
            var options = this.hjq('getOptions', annotations);
            options.selected = options.selected || function(event, ui) {
                $(this).trigger('change');
            }
            select.combobox(options);
        }
    }
})( jQuery );
