/* toggle */
(function($) {
  $.fn.hjq_toggle = function(annotations) {
    this.on("click", "div.toggle > h3", function(event) {
      $this = $(this)
      $this.toggleClass('ui-state-active ui-corner-top ui-corner-all');
      $this.next().toggleClass('hidden ui-accordion-content-active');
      $this.children("span.ui-icon").toggleClass('ui-icon-triangle-1-s ui-icon-triangle-1-e')
    });
  }
})( jQuery );
