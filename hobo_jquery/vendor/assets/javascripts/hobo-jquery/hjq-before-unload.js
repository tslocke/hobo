/* search_results */
(function($) {
    $.fn.hjq_before_unload = function(annotations) {
      var that = this;
      that.find(":input").bind('change', function() {
        window.onbeforeunload = function() {
          return that.find(typeof(annotations.message == 'string') ? annotations.message : "You have unsaved changes.  If you exit this page, your changes will not be saved.");
        }
      });
      that.submit(function() {
        window.onbeforeunload = null;
      });
      return that;
    }
}( jQuery ));
