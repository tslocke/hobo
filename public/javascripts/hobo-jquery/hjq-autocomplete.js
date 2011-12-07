/* autocomplete */
(function($) {
   $.fn.hjq_autocomplete = function(annotations) {
       this.autocomplete(this.hjq('getOptions', annotations)).on("focus", function() {
           if($(this).hasClass("nil-value")) {
               this.value='';
               $(this).removeClass("nil-value");
           }
       });
   };
})( jQuery );

