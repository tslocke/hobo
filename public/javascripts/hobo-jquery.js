
var hjq = (function() {
    return {

        /* calls all "init" functions with their this and their annotations */
        initialize: function() {
            jQuery(this).find('.hjq-annotated').each(function() {
                var annotations = hjq.get_annotations.call(this);
                if(annotations.init) {
                    hjq.function_by_name(annotations.init).call(this, annotations);
                };
            });
        },

        /* returns JSON annotations for *this* */
        get_annotations: function() {
            // Unforunately, jQuery does not traverse comment nodes, so we're using the DOM methods directly
            
            // previous is probably a textNode containing whitespace
            var comment = this.previousSibling;
            if(comment.nodeType!=Node.COMMENT_NODE) { comment = comment.previousSibling; }
            if(comment.nodeType!=Node.COMMENT_NODE) { return ({}); }
            
            var json = RegExp(/^\s*json_annotation\s*(\(\{.*\}\)\;)\s*$/).exec(comment.nodeValue)[1];
            return eval(json);
        },

        /* given annotations, turns the values in the _events_ object into functions, merges them into _options_ and returns _options_ */
        get_options: function(annotations) {
            for(var key in annotations.events) {
                annotations.options[key] = hjq.function_by_name(annotations.events[key]);
            }
            return annotations.options;
        },
            
        /* given a global function name, find the function */
        function_by_name: function(name) {
            var descend = window;  // find function by name on the root object
            jQuery.each(name.split("."), function() {
                if(descend) descend = descend[this];
            });
            return descend;
        },
            

        log: function(s) {
            if(console && console.log) console.log(s);
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

                // enable previously marked elements, and rename
                clone.find(".input_many_template_input").each(function() {
                    this.disabled = false;
                    jQuery(this).removeClass("input_many_template_input");
                    name_updater.call(this);
                });

                clone.insertAfter(me);

                // initialize subelements
                hjq.initialize.call(me.next().get(0));

                if(me.hasClass("empty")) {
                    me.addClass("hidden");
                } else {
                    // now that we've added an element after us, we should only have a '-' button
                    var buttons = clone.children("div.buttons").clone(true);
                    buttons.children("button.add-item").remove();
                    me.children("div.buttons").replaceWith(buttons);
                }

                return false; // prevent bubbling
            },

            removeOne: function() {
                var me = jQuery(this).parent().parent();
                var top = me.parent();
                var buttons = top.children("li.input-many-template").children("div.buttons").clone(true);
                var params = hjq.get_annotations.call(top);

                // reenable the buttons
                buttons.find(".input_many_template_input").each(function() {
                    this.disabled = false;
                    jQuery(this).removeClass("input_many_template_input");
                });                

                me.remove();

                var last=top.children("li:last");
                if(last.hasClass("empty")) {
                    last.removeClass("hidden");
                } else {
                    // if we've reached the minimum, we don't want to add the '-' button
                    if(top.children().length-2 <= (params['minimum']||0)) {
                        buttons.children("button.remove-item").remove();
                    }
                    // put + and - buttons on the last element, since they may have been removed
                    last.children("div.buttons").replaceWith(buttons);
                }

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
                        } else {
                            hjq.log("hjq.input_many.update_id: id_prefix "+id_prefix+" didn't match input "+this.id);
                        }
                    }
                    return this;
                };
            }
        },


        datepicker: {
            init: function (annotations) {
                if(!this.disabled) {
                    jQuery(this).datepicker(hjq.get_options(annotations));
                }
            },
        }
    };
})();

