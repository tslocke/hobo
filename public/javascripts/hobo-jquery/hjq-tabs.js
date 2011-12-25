/* tabs */
(function($) {
   $.fn.hjq_tabs = function(annotations) {
       this.tabs(this.hjq('getOptions', annotations));
       if(annotations.sortable) {
           this.find(".ui-tabs-nav").sortable();
       }
   };
})( jQuery );
