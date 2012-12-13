// custom js for projects/show2.dryml

var show2_js = function() {
        setTimeout(function() {
        var f=function(ev, el) {
            $(".events").html($(".events").text()+" "+ev.type);
            return true;
         };
         cf=function(cb) {
            $(".callbacks").html($(".callbacks").text()+" "+cb);
            return true;
         };
         $(document).on({"rapid:ajax:success": f, "rapid:ajax:before":f, "rapid:ajax:error":f, "rapid:ajax:complete":f});
        }, 2);
      };

jQuery(document).ready(function() {
  show2_js();
});
jQuery(window).bind('page:change', function() {
  show2_js();
})

