

// we add our own hide and show to jQuery so that we get consistent behaviour and so we can plug our tests in.
jQuery.fn.hjq_hide = function(options, callback) {
    var settings = jQuery.extend({
        effect: 'blind', speed: 500
    }, options);
    var cb = callback;
    if(callback && hjq.hideComplete) {
        cb = (function() {
            callback.apply(this, arguments); 
            hjq.hideComplete.apply(this, arguments); 
        });
    } else if (hjq.hideComplete) {
        cb = hjq.hideComplete;
    }        
    return this.hide(settings.effect, settings, settings.speed, cb);
};

jQuery.fn.hjq_show = function(options, callback) {
    var settings = jQuery.extend({
        effect: 'blind', speed: 500, callback: undefined,
    }, options);
    var cb = callback;
    if(callback && hjq.showComplete) {
        cb = (function() {
            settings.callback.apply(this, arguments); 
            hjq.showComplete.apply(this, arguments); 
        });
    } else if (hjq.showComplete) {
        cb = hjq.showComplete;
    }
    return this.show(settings.effect, settings, settings.speed, cb);
};
    

var hjq = (function() {
    return {

        /* calls all "init" functions with their this and their annotations */
        initialize: function() {
            jQuery(this).find('.hjq-annotated').each(function() {
                var annotations = hjq.getAnnotations.call(this);
                if(annotations.init) {
                    hjq.functionByName(annotations.init).call(this, annotations);
                };
            });
        },

        /* returns JSON annotations for *this* */
        getAnnotations: function() {
            // Unforunately, jQuery does not traverse comment nodes, so we're using the DOM methods directly
            
            // previous is probably a textNode containing whitespace
            var comment = this.previousSibling;
            if(comment.nodeType!=Node.COMMENT_NODE) { comment = comment.previousSibling; }
            if(comment.nodeType!=Node.COMMENT_NODE) { return ({}); }
            
            var json = RegExp(/^\s*json_annotation\s*(\(\{.*\}\)\;)\s*$/).exec(comment.nodeValue)[1];
            return eval(json);
        },

        /* given annotations, turns the values in the _events_ object into functions, merges them into _options_ and returns _options_ */
        getOptions: function(annotations) {
            for(var key in annotations.events) {
                annotations.options[key] = hjq.functionByName(annotations.events[key]);
            }
            return annotations.options;
        },
            
        /* given a global function name, find the function */
        functionByName: function(name) {
            var descend = window;  // find function by name on the root object
            jQuery.each(name.split("."), function() {
                if(descend) descend = descend[this];
            });
            return descend;
        },

        /* Given a function name or javascript fragment, return a function.
           the arguments will be passed through, but "this" will be set to "context"  */
        wrapCallback: function(script, context) {
            if(!script) return null;
            var f=hjq.functionByName(script);
            if(f) return (function() { return f.apply(context, arguments); });
            return (function() { 
                return (function() { return eval(script) }).apply(context, arguments); 
            });
        },

        /* Given a function name or javascript fragment, run it */
        applyCallback: function(script, context /* arguments... */) {
            if(!script) return null;
            return hjq.wrapCallback(script, context).apply(null, Array.prototype.slice.call(arguments, 2));
        },

        /* log to console, if available */
        log: function(s) {
            if(console && console.log) console.log(s);
        },

        hideComplete: undefined,

        bindHideCallback: function(f) {
            /* FIXME: I suppose we should properly chain here....*/
            hjq.hideComplete = f;
        },

        showComplete: undefined,

        bindShowCallback: function(f) {
            /* FIXME:chain */
            hjq.showComplete = f;
        },

        input_many: {
            init: function (annotations) {
                var me = jQuery(this);

                // disable all elements inside our template, and mark them so we can find them later.
                me.find(".input-many-template :input[disabled=false]").each(function() {
                    this.disabled = true;
                    jQuery(this).addClass("input_many_template_input");
                });
              
                // bind event handlers
                me.find(".remove-item").click(hjq.input_many.removeOne);
                me.find(".add-item").click(hjq.input_many.addOne);
            },

            addOne: function () {
                var me = jQuery(this).parent().parent();
                var top = me.parent();
                var template = top.children("li.input-many-template");
                var clone = template.clone(true).removeClass("input-many-template");
                // length-2 because ignore the template li and the empty li
                var name_updater = hjq.input_many.getNameUpdater.call(top, top.children().length-2);
                var params = hjq.getAnnotations.call(top.get(0));

                // enable previously marked elements
                clone.find(".input_many_template_input").each(function() {
                    this.disabled = false;
                    jQuery(this).removeClass("input_many_template_input");
                });

                // update id & name
                clone.find("*").each(function() {
                    name_updater.call(this);
                });
                name_updater.call(clone.get(0));

                // do the add with anim
                clone.css("display", "none").insertAfter(me).hjq_show();

                // initialize subelements
                hjq.initialize.call(me.next().get(0));

                // visibility
                if(me.hasClass("empty")) {
                    me.addClass("hidden");
                    me.find("input.empty-input").attr("disabled", true);
                } else {
                    // now that we've added an element after us, we should only have a '-' button
                    me.children("div.buttons").children("button.remove-item").removeClass("hidden");
                    me.children("div.buttons").children("button.add-item").addClass("hidden");
                }
                
                hjq.applyCallback(params.add_hook, me.get(0));

                return false; // prevent bubbling
            },

            removeOne: function() {
                var me = jQuery(this).parent().parent();
                var top = me.parent();
                var params = hjq.getAnnotations.call(top.get(0));

                if(params.remove_hook) {
                    if(!hjq.applyCallback(params.remove_hook, me.get(0))) {
                        return false;
                    }
                }

                // rename everybody from me onwards
                var i=hjq.input_many.getIndex.call(me.get(0))
                var n=me.next();
                for(; n.length>0; i+=1, n=n.next()) {
                    var name_updater = hjq.input_many.getNameUpdater.call(top, i);
                    n.find("*").each(function() {
                        name_updater.call(this);
                    });
                    name_updater.call(n.get(0));
                }                

                // adjust +/- buttons on the button element as appropriate
                var last=top.children("li:last");
                if(last.get(0)==me.get(0)) {
                    last = last.prev();
                }

                if(last.hasClass("empty")) {
                    last.removeClass("hidden");
                    last.find("input.empty-input").removeAttr("disabled");
                } else {
                    // if we've reached the minimum, we don't want to add the '-' button
                    if(top.children().length-3 <= (params['minimum']||0)) {
                        last.children("div.buttons").children("button.remove-item").addClass("hidden");
                    } else {
                        last.children("div.buttons").children("button.remove-item").removeClass("hidden");
                    }
                    last.children("div.buttons").children("button.add-item").removeClass("hidden");
                }

                // remove with animation
                me.hjq_hide({}, function() { jQuery(this).remove(); });

                return false; //prevent bubbling
            },

            // given this==the input-many, returns a lambda that updates the name & id for an element
            getNameUpdater: function(new_index) {
                var name_prefix = Hobo.getClassData(this.get(0), 'input-many-prefix');
                var id_prefix = name_prefix.replace(/\[/g, "_").replace(/\]/g, "");
                var name_re = RegExp("^" + RegExp.escape(name_prefix)+ "\[\-?[0-9]+\]");
                var name_sub = name_prefix + '[' + new_index.toString() + ']';
                var id_re = RegExp("^" + RegExp.escape(id_prefix)+ "_\-?[0-9]+");
                var id_sub = id_prefix + '_' + new_index.toString();
                var class_re = RegExp(RegExp.escape(name_prefix)+ "\[\-?[0-9]+\]");
                var class_sub = name_sub;

                return function() {
                    if(this.name) {
                        this.name = this.name.replace(name_re, name_sub);
                    }
                    if (id_prefix==this.id.slice(0, id_prefix.length)) {
                        this.id = this.id.replace(id_re, id_sub);
                    } else {
                        // silly rails.  text_area_tag and text_field_tag use different conventions for the id.
                        if(name_prefix==this.id.slice(0, name_prefix.length)) {
                            this.id = this.id.replace(name_re, name_sub);
                        } /* else {
                            hjq.log("hjq.input_many.update_id: id_prefix "+id_prefix+" didn't match input "+this.id);
                        } */
                    }
                    if (class_re.test(this.className)) {
                        this.className = this.className.replace(class_re, class_sub);
                    }
                    return this;
                };
            },

            // given this==an input-many item, get the submit index
            getIndex: function() {
                return Number(this.id.match(/\[([0-9])+\]$/)[1]);
            }

        },

        formlet: {
            // call with this==the submit button to submit the formlet
            submit: function() {
                var formlet = jQuery(jQuery(this).parents(".formlet").get(0));
                var annotations = hjq.getAnnotations.call(formlet.get(0));

                var options = annotations.ajax_options;
                var attrs = annotations.ajax_attrs;

                if(attrs.before) {
                    if(!hjq.applyCallback(attrs.before, formlet.get(0))) {
                        return false;
                    }
                }

                if(attrs.confirm) {
                    if(!confirm(attrs.confirm)) {
                        return false;
                    }
                }

                options.data = formlet.find(":input").fieldSerialize();
                options.dataType = 'script';

                // we tell our controller which parts to return by sending it a "render" array.
                for(i=0; i<attrs.update.length; i++) {
                    var id = attrs.update[i];
                    if(id=="self") {
                        for(var el=jQuery(this); el.length && !hoboParts[el.attr("id")]; el=el.parent());
                        id = ( el.length ? el.attr("id") : undefined) ; 
                    }                    
                    if(id) {
                        options.data += "&" + encodeURIComponent("render["+i+"][part_context]") + "=" + encodeURIComponent(hoboParts[id]);
                        options.data += "&" + encodeURIComponent("render["+i+"][id]") + "=" + id;
                    }
                }

                Hobo.showSpinner(attrs.message || "Saving...", attrs.spinner_next_to);

                options.success = hjq.wrapCallback(attrs.success, formlet.get(0));
                options.error = hjq.wrapCallback(attrs.error, formlet.get(0));
                options.complete = function() {
                    Hobo.hideSpinner();
                    hjq.applyCallback(attrs.complete, formlet.get(0), arguments);
                };
                
                jQuery.ajax(options);

                //prevent bubbling
                return false;
            }
        },
                
        datepicker: {
            init: function (annotations) {
                if(!this.disabled) {
                    jQuery(this).datepicker(hjq.getOptions(annotations));
                }
            },
        }
    };
})();

