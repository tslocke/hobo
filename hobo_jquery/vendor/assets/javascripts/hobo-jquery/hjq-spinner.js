/* spinner */
(function($) {
    var default_options = undefined;

    // old min_time functionality removed -- using an effect on the
    // removal ensures it stays on screen long enough to be visible.

    var methods = {
        /* without any options, $(foo).hjq_spinner() places a spinner
           to the left of foo until you remove it via
           $(foo).hjq_spinner('remove');

           options:
           - spinner-next-to: DOM id of the element to place the spinner next to.
           - spinner-at: selector for the element to place the spinner next to.
           - no-spinner: if set, the spinner is not displayed.
           - spinner-options: passed to [jQuery-UI's position](http://jqueryui.com/demos/position/).   Defaults are `{my: 'left center', at: 'right center', offset: '5 0'}`
           - message: the message to display inside the spinner

           If options.message is false-ish, default_message is displayed.
        */
        init: function(options, default_message) {
            var original=$("#ajax-progress");
            if (original.length==0) return this;

            options = $.extend({}, defaultOptions.call(this), options);
            if(options['no-spinner']) return this;

            var clone=original.clone();
            var spinner_list = this.data('hjq-spinner') || [];
            spinner_list.push(clone);

            this.data('hjq-spinner', spinner_list);
            clone.data('source', this);

            clone.find("span").text(options.message || default_message || "");

            var pos_options = $.extend({}, defaultOptions()['spinner-options'], options['spinner-options']);

            pos_options.of = this;
            if(options['spinner-at']) pos_options.of=$(options['spinner-at']);
            else if(options['spinner-next-to']) pos_options.of=$("#"+options['spinner-next-to']);

            clone.insertBefore(original).show().position(pos_options);
            return this;
        },

        remove: function() {
            var spinner_list = this.data('hjq-spinner');
            var clone = spinner_list.pop();
            var that=this;
            if(!clone) {
                $(".ajax-progress").each(function() {
                    if($(this).data('source')[0]==that[0]) {
                        clone=$(this);
                        return false;
                    }
                });
            }
            if(!clone) return this;
            clone.remove();
            return this;
        }
    };

    var defaultOptions = function() {
        if(default_options) return default_options;
        var page_options = this.hjq('pageData');
        default_options = {};
        default_options['spinner-next-to'] = page_options['spinner-next-to'];
        default_options['spinner-at'] = page_options['spinner-at'];
        default_options['no-spinner'] = page_options['no-spinner'];
        default_options['spinner-options'] = page_options['spinner-options'] || {
            my: "right bottom",
            at: "left top"
        };
        default_options['message'] = page_options['message'];
        return default_options;
    };

    $.fn.hjq_spinner = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_spinner' );
        }
    };

})( jQuery );
