// custom js for projects/nested_has_many_test.dryml

var last_added;
var last_removed;
var nested_has_many_js = function() {
        $('.stories').on('rapid:add', function(ev) {
          last_added = ev.target;
        });
        $('.stories').on('rapid:remove', function(ev) {
          /* .tasks:rapid:remove events bubble up here, so ignore them */
          if(ev.target.id.search(/tasks/)>0) return;
          last_removed = ev.target;
          if(!confirm("really?")) return false;
        });
      };

jQuery(document).ready(function() {
  nested_has_many_js();
});
jQuery(window).bind('page:change', function() {
  nested_has_many_js();
})

