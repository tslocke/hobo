/* accordion & accordion-collection */
(function($) {
   $.fn.hjq_accordion = function(annotations) {
       var stop = false;
       if(annotations.sortable) {
           this.on("click", "div.hjq-accordion-element > h3", function(event) {
               if(stop) {
                   event.stopImmediatePropagation();
                   event.preventDefault();
                   stop = false;
               }
           });
       }
       var that=this.accordion($.extend({header: "> div.hjq-accordion-element > h3"}, this.hjq('getOptions', annotations)));
       if (annotations.sortable) {
           that.sortable({axis: "y",
                          handle: "h3",
                          stop: function() {
                              stop = true;
                          }
                         });
       }
   };
})( jQuery );
