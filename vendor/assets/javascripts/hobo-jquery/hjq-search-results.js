/* search_results */
(function($) {
    var first_run = true;
    $.fn.hjq_search_results = function(annotations) {
        // the first run is page load.   Subsequent initializations will happen on ajax update.
        if(first_run) first_run = false;
        else $("#search-results-box").hjq_dialog_box("open");
    }
})( jQuery );
