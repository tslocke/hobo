//= require_tree .

jQuery(document).ready(function() {
    jQuery(document).hjq();
});
jQuery(window).bind('page:change', function() {
    jQuery(document).hjq();
})
