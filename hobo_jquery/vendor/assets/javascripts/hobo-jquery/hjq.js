/* hobo-jQuery initialization & utility functions */

(function($) {
    var page_data = {};

    //used for javascript testing.
    var num_updates = 0;

    var methods = {

        /* call only once per document. */
        initOnce: function() {
          if(typeof History === 'object') {  // History.js installed
            $(window).on("statechange", function() {
              var state = History.getState();
              if(state.data.length==3) {
                var form = $(state.data[0]);
                var roptions = form.hjq('buildRequestCallbacks', state.data[1], state.data[2]);
                $.ajax(state.url, roptions);
              }
            })
          }
          return true;
        },

        /* call for every new fragment */
        init: function() {
            var top = this;
            this.find("[data-rapid-page-data]").each(function() {
                page_data = $(this).data('rapid-page-data');
            });
            this.find("[data-rapid]").each(function() {
                var that = jQuery(this);
                jQuery.each(jQuery(this).data('rapid'), function(tag, annotations) {
                    tag = "hjq_"+tag.replace(/-/g, '_');
                    if(that[tag]) {
                        that[tag](annotations);
                    }
                });
            });
            return top;
        },

        /* return the ID from the typed-id in the data-rapid-context attribute */
        contextId: function() {
            return this.data('rapid-context').split(":")[1];
        },

        /* given annotations, turns the values in the _events_ object into functions, merges them into _options_ and returns _options_ */
        getOptions: function(annotations) {
            for(var key in annotations.events) {
                if(annotations.events.hasOwnProperty(key)) {
                    annotations.options[key] = methods.createFunction.call(this, annotations.events[key]);
                }
            }
            return annotations.options;
        },

        /* return the global page_data:  hobo_parts, form_auth_token, etc. */
        pageData: function() { return page_data; },

        /* return the number of current updates.   Useful for
           javascript/integration testing */
        numUpdates: function() { return num_updates; },

        /* this function is called on an update of a part via Ajax. */
        update: function(innerHtml) {
            num_updates += 1;
            var that=this;
            var replacement=this.clone().html(innerHtml).hide();
            var hide_o, show_o;
            if(this.data('hjq-ajax')) {
                hide_o = this.data('hjq-ajax')['hide'];
                show_o = this.data('hjq-ajax')['show'];
            }
            methods.hideAndRemove.call(this, hide_o,  function () {
                that.before(replacement);
                methods.show.call(replacement, show_o, function() {num_updates -= 1;});
            });
            methods.init.call(replacement);
            return replacement;
        },

        /* this function is called on ajax update to update part
        context information */
        updatePartContexts: function(contexts) {
            $.extend(page_data.hobo_parts, contexts);
        },

        /* hide and removes the element.  options is an array or
         * comma-separated string corresponding to the jQuery-UI hide
         * arguments: effect, options, speed & callback.  The callback
         * argument is an additional callback called after the one in
         * the options hash.  Removal is done after both callbacks. */
        hideAndRemove: function(o, callback) {
            methods.hide.call(this, o, callback, true);
        },

        /* hides the element.  options is an array or
         * comma-separated string corresponding to the jQuery-UI hide
         * arguments: effect, options, speed & callback.  The callback
         * argument is an additional callback called after the one in
         * the options hash.  Removal is done after both callbacks. */
        hide: function(o, callback, andRemove) {
            var that=this;
            var args = o;
            if(args===undefined) args=page_data.hide;
            if(args===undefined) args=[];
            if (typeof args=='string') args=args.split(',');
            else if($.isArray(args)) args=args.slice(0); //shallow clone
            else args=[];
            o_cb = args[3];
            args[3] = function() {
                if(o_cb) methods.createFunction.call(that, o_cb).apply(this, arguments);
                if(callback) callback.apply(this, arguments);
                if(andRemove) that.remove();
            };
            if(args[0]) {
                that.hide.apply(that, args);
            } else {
                that.hide();
                args[3].call(that);
            }
            return this;
        },
        /* show the element.  options is an array or
         * comma-separated string corresponding to the jQuery-UI show
         * arguments: effect, options, speed & callback.  The callback
         * argument is an additional callback called after the one in
         * the options hash.  */
        show: function(o, callback) {
            var that=this;
            var args = o;
            if(args===undefined) args=page_data.show;
            if(args===undefined) args=[];
            if (typeof args=='string') args=args.split(',');
            else if($.isArray(args)) args=args.slice(0); //shallow clone
            else args=[];
            o_cb = args[3];
            args[3] = function() {
                if(o_cb) methods.createFunction.call(that, o_cb).apply(this, arguments);
                if(callback) callback.apply(this, arguments);
            };
            if(args[0]) {
                that.show.apply(that, args);
            } else {
                that.show();
                args[3].call(that);
            }
            return this;
        },

        /* given a global function name, find the function */
        functionByName: function(name) {
            var descend = window;  // find function by name on the root object
            jQuery.each(name.split("."), function() {
                if(descend) descend = descend[this];
            });
            return descend;
        },

	/* Given a function name or javascript fragment, return a function */
	createFunction: function(script) {
            if(!script) return function() {};
            if($.isFunction(script)) return script;
            var f=methods.functionByName.call(this, script);
            if(f) return f;
	    return function() { return eval(script); };
	},


        /* returns a jQuery selector for an element. One option would
           be to use something like
           http://stackoverflow.com/questions/2206958/best-way-to-reference-an-element-with-jquery
           However, if the DOM changes due to Ajax this isn't
           necessarily stable. So instead we give the element a unique
           ID if it doesn't already have one.
        */

        getPath: function() {
          if(!this.attr("id")) {
            this.attr("id", Math.random().toString().replace("0.", "id"))
          }
          return "#"+this.attr("id");
        },


            /* Build an options object suitable for sending to
             * jQuery.ajax.  (Note that the before & confirm callbacks
             * are called from this function, and the spinner is shown)
             *
             * The returned object will include a 'data' value
             * populated with a hash.
             *
             * This function has now been split into two parts to
             * better support push_state.  buildRequestData is the
             * first part, which builds everything except the
             * callbacks (but it does execute the before callbacks).
             * buildRequestCallbacks builds the remaining callbacks.
             *
             * Options:
             *  type: POST, GET
             *  attrs: a hash containing the standard Hobo ajax attributes & callbacks
             *  extra_options: merged into the hash sent to jQuery.ajax
             *  extra_callbacks: the callbacks in attrs are generally specified by the DRYML; this allows the framework to add their own
             *  function: passed to Hobo's ajax_update_response
             *  preamble: passed to Hobo's ajax_update_response
             *  postamble: passed to Hobo's ajax_update_response
             *  content_type: passed to Hobo's ajax_update_response
             *
            */
        buildRequest: function(o) {
          return methods.buildRequestCallbacks.call(this, methods.buildRequestData.call(this, o), o);
        },

        buildRequestData: function(o) {
            var that = this;
            if (!o.attrs) o.attrs = {};
            var result = {};

            if(o.attrs.before) {
                if(!methods.createFunction.call(that, o.attrs.before).call(this)) {
                    return false;
                }
            }

            var before_evt=jQuery.Event("rapid:ajax:before");
            that.trigger(before_evt, [that]);
            if(before_evt.isPropagationStopped()) {
                return false;
            }

            if(o.attrs.confirm) {
                if(!confirm(o.attrs.confirm)) {
                    return false;
                }
            }

            result.type = o.type || 'GET';
            result.data = {};
            /* These are now the defaults, so we don't need to send
            them over the wire.
              result.data = {"render_options[preamble]": o.preamble || '',
                             "render_options[contexts_function]": 'hjq.ajax.updatePartContexts'
                             }; */
            if(o.preamble) result.data["render_options[preamble]"] = o.preamble;
            if(o.postamble) result.data["render_options[postamble]"] = o.postamble;
            if(o.fix_quotes) result.data["render_options[fix_quotes]"] = o.fix_quotes;
            if(o.content_type) result.data["render_options[content_type]"] = o.content_type;
            if(o.attrs['errors-ok']) result.data["render_options[errors_ok]"] = 1;
            result.dataType = 'script';
            o.spec = jQuery.extend({'function': 'hjq.ajax.update', preamble: ''}, o.spec);

            var part_data = {};
            if(o.attrs.hide!==undefined) part_data.hide = o.attrs.hide;
            if(o.attrs.show!==undefined) part_data.show = o.attrs.show;
            if($.isEmptyObject(part_data)) part_data = undefined;

            // we tell our controller which parts to return by sending it a "render" array.
            var ids=methods.getUpdateIds.call(this, o.attrs);
            for(var i=0; i<ids.length; i++) {
                if(part_data) $("#"+ids[i]).data('hjq-ajax', part_data);
                result.data["render["+i+"][part_context]"] = page_data.hobo_parts[ids[i]];
                result.data["render["+i+"][id]"] = ids[i];
                // default for render[i][function] is hjq.ajax.update
                if(o['function']) result.data["render["+i+"][function]"] = o['function'];
            }

            if(ids.length==0) {
              result.data.render = 'none'
            }

            return result;
        },

        buildRequestCallbacks: function(result, o) {
            var that = this;
            if (!o.attrs) o.attrs = {};
            if (!o.extra_callbacks) o.extra_callbacks = {};

            var spinner = this.hjq_spinner(o.attrs, "Saving...");

            var success_dfd = jQuery.Deferred();
            if(o.attrs.success) success_dfd.done(methods.createFunction.call(that, o.attrs.success));
            if(o.extra_callbacks.success) success_dfd.done(methods.createFunction.call(that, o.extra_callbacks.success));
            success_dfd.done(function() {
                if(o.attrs['reset-form']) that[0].reset();
                // if we've been removed, all event handlers on us
                // have already been removed and we don't bubble
                // up, so triggering on that won't do any good
                if(that.parents("body").length==0) $(document).trigger('rapid:ajax:success', [that]);
                else  that.trigger('rapid:ajax:success', [that]);
            });
            result.success = success_dfd.resolve;

            var error_dfd = jQuery.Deferred();
            if(o.attrs.error) error_dfd.done(methods.createFunction.call(that, o.attrs.error));
            if(o.extra_callbacks.error) error_dfd.done(methods.createFunction.call(that, o.extra_callbacks.error));
            error_dfd.done(function() {
                if(window.console&&window.console.log){window.console.log('ajax failed');}
                if(that.parents("body").length==0) $(document).trigger('rapid:ajax:error', [that]);
                else  that.trigger('rapid:ajax:error', [that]);
            });
            result.error = error_dfd.resolve;

            var complete_dfd = jQuery.Deferred();
            if(o.attrs.complete) complete_dfd.done(methods.createFunction.call(that, o.attrs.complete));
            if(o.extra_callbacks.complete) complete_dfd.done(methods.createFunction.call(that, o.extra_callbacks.complete));
            complete_dfd.done(function() {
                if(that.parents("body").length==0) $(document).trigger('rapid:ajax:complete', [that]);
                else  that.trigger('rapid:ajax:complete', [that]);
                spinner.hjq_spinner('remove');
                if(o.attrs['refocus-form']) that.find(":input[type!=hidden]:first").focus();
            });
            result.complete = complete_dfd.resolve;

            jQuery.extend(result, o.extra_options);

            return result;
        },

        /*
           this: element to receive callbacks
           url: new location
           ajax_options: output from buildRequestData
           hobo_options: input to buildRequestData, buildRequestCallbacks
           */
        changeLocationAjax: function (url, ajax_options, hobo_options) {
          if (hobo_options.attrs.push_state && typeof History==='object') {
            // if the history plugin is installed, it will fire the
            // changestate event immediately, which is where we
            // actually execute the ajax
            window.History.pushState([this.getPath(), ajax_options, hobo_options], hobo_options.attrs.new_title || null, url);
          } else {
            ajax_options = this.hjq('buildRequestCallbacks', ajax_options, hobo_options);
            $.ajax(url, ajax_options);
          }
        },

        // given ajax_attrs (update, updates and/or ajax), return DOM id's.
        getUpdateIds: function(attrs) {
            var ids = attrs.update || [];
            if (typeof ids=='string') ids=ids.split(',');

            jQuery(attrs.updates).each(function () {
                ids.push(jQuery(this).attr('id'));
            });

            if(attrs.ajax) {
                for(var el=this; el.length && !page_data.hobo_parts[el.attr("id")]; el=el.parent());
                if(el.length) ids.push(el.attr('id'));
            }

            // validate
            for (var i=0; i<ids.length; i++) {
                if(!page_data.hobo_parts[ids[i]]) {
                    ids.splice(i, 1);
                    i -= 1;
                }
            }

            return ids;
        }


    };


    $.fn.hjq = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.initOnce.apply( this, arguments ) && methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq' );
        }
    };

})( jQuery );


// to make the Ajax interface cleaner, these provide direct access to
// a couple of plugin functions.
var hjq=(function($) {
    return {
        ajax: {
            update: function (dom_id, innerHtml) {
                $("#"+dom_id).hjq('update',innerHtml);
            },

            updatePartContexts: function(contexts) {
                $(document).hjq('updatePartContexts', contexts);
            }
        }
    };
})(jQuery);
