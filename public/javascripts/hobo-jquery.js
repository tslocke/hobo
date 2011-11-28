// our monkey patches to Function

/* bind the context and return a lambda */
Function.prototype.hjq_bind = function(context) {
    var that=this;
    return function() {
        return that.apply(context, arguments);
    }
};

/* return a lambda that calls "this" and then calls "f".  Depending on the return value of the lambda is probably a bad idea. */
Function.prototype.hjq_chain = function(f) {
    var that=this;
    return function() {
        var r=that.apply(this, arguments);
        if(f) {
            r=f.apply(this, arguments);
        }
        return r;
    }
};

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
    var cb = callback;
    var settings = jQuery.extend({
        effect: 'blind', speed: 500, callback: undefined
    }, options);
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

// Our monkey patches to Prototype

// // the Hobo part mechanism uses Element.update to do it's work
// Element.addMethods({update: Element.Methods.update.hjq_chain(function(id, content) {
//     if(!id.nodeType) id="#"+id;  // assume it's a string
//     hjq.initialize.apply(jQuery(id));
// })});

var hjq = (function() {
    return {

        /* calls all "init" functions with their this and their annotations */
        initialize: function() {
            jQuery(this).find('.rapid-data').each(function() {
                hjq.data = hjq.getAnnotations.call(this);
            });
            jQuery(this).find('.rapid-annotated').each(function() {
                var annotations = hjq.getAnnotations.call(this);
                if(annotations.tag) {
                    annotations.tag = annotations.tag.replace('-', '_');
                    if(hjq[annotations.tag] && hjq[annotations.tag].init) {
                        hjq[annotations.tag].init.call(this, annotations);
                    }
                }
            });
            jQuery(this).find("*[data-rapid]").each(function() {
                var that = this;
                jQuery.each(jQuery(this).data('rapid'), function(tag, annotations) {
                    tag = tag.replace('-', '_');
                    if(hjq[tag] && hjq[tag].init) {
                        hjq[tag].init.call(that, annotations);
                    }
                });
            });
        },

        /* returns JSON annotations for *this* */
        getAnnotations: function() {
            // Unforunately, jQuery does not traverse comment nodes, so we're using the DOM methods directly

            // previous is probably a textNode containing whitespace
            var comment = this.previousSibling;
            if(!comment) { return ({}); }
            if(comment.nodeType!=Node.COMMENT_NODE) { comment = comment.previousSibling; }
            if(!comment) { return ({}); }
            if(comment.nodeType!=Node.COMMENT_NODE) { return ({}); }

            var json = RegExp(/^\s*json_annotation\s*(\(\{.*\}\)\;)\s*$/).exec(comment.nodeValue)[1];
            return eval(json);
        },

        /* given annotations, turns the values in the _events_ object into functions, merges them into _options_ and returns _options_ */
        getOptions: function(annotations) {
            for(var key in annotations.events) {
                annotations.options[key] = hjq.util.createFunction(annotations.events[key]);
            }
            return annotations.options;
        },


        /* hooks for debugging & testing */

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

        /* these are functions I shouldn't be writing myself -- should be in a library somewhere! */
        util: {
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
                var f=hjq.util.functionByName(script);
                if(f) return f;
	        return function() { return eval(script); };
	    },

            /* Iterates through this and arguments until either a jQuery or an element is found, and returns it, jQuerified */
            jQuerifyFirstElement: function() {
                if(this.nodeType==1) return jQuery(this);
                if(this.jquery) return this;
                for(var i=0; i<arguments.length; i++) {
                    if(arguments[i].nodeType==1) return jQuery(arguments[i]);
                    if(arguments[i].jquery) return arguments[i];
                }
                return [];
            },

            /* log to console, if available */
            log: function(s) {
                if(console && console.log) console.log(s);
            }
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

                // and reinitialize low-pro too
                Event.addBehavior.reload();

                // visibility
                if(me.hasClass("empty")) {
                    me.addClass("hidden");
                    me.find("input.empty-input").attr("disabled", true);
                } else {
                    // now that we've added an element after us, we should only have a '-' button
                    me.children("div.buttons").children("button.remove-item").removeClass("hidden");
                    me.children("div.buttons").children("button.add-item").addClass("hidden");
                }
                
                hjq.util.createFunction(params.add_hook).call(me.get(0));

                return false; // prevent bubbling
            },

            removeOne: function() {
                var me = jQuery(this).parent().parent();
                var top = me.parent();
                var params = hjq.getAnnotations.call(top.get(0));

                if(params.remove_hook) {
                    if(!hjq.util.createFunction(params.remove_hook).call(me.get(0))) {
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
                            hjq.util.log("hjq.input_many.update_id: id_prefix "+id_prefix+" didn't match input "+this.id);
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

        form: {
            init: function (annotations) {
                jQuery(this).on('submit', hjq.form.submit);
            },

            // call with this==the form or a child of the form to submit the form
            submit: function () {
                var form = jQuery(this).closest("form");
                var annotations = form.data('rapid').form;

                var options = {type: form[0].method,
                               attrs: annotations.ajax_attrs,
                              };

                if(form.attr('enctype') == 'multipart/form-data') {
                    if(form.ajaxSubmit) {
                        var roptions= hjq.ajax.buildRequest.call(form[0], jQuery.extend(options, {preamble: '<textarea>', postamble: '</textarea>', content_type: 'text/html'}));

                        if(!roptions) return false;
                        roptions.iframe = true;
                        form.ajaxSubmit(roptions);
                    } else {
                        alert("malsup's jquery form plugin required to do ajax submissions of multipart forms");
                    }

                } else {
                    var roptions= hjq.ajax.buildRequest.call(form[0], options);
                    if(!roptions) return false;

                    // make sure we don't serialize any nested formlets
                    var data = form.find(":input").
                        not(form.find(".formlet :input")).
                        serialize();

                    roptions.data = jQuery.param(roptions.data) + "&" + data;

                    jQuery.ajax(form[0].action, roptions);
                }


                // prevent bubbling
                return false;
            }
        },


        formlet: {
            init: function (annotations) {
                jQuery(this).find('input[type=submit]').on('click', hjq.formlet.submit);
            },

            // call with this==the formlet or a child of the formlet to submit the formlet
            submit: function(extra_callbacks, extra_options) {
                var formlet = jQuery(this).closest(".formlet");
                var annotations = formlet.data('rapid').formlet;

                // make sure we don't serialize any nested forms
                var data = formlet.find(":input").
                    not(formlet.find("form :input")).
                    not(formlet.find(".formlet :input")).
                    serialize();

                var roptions = hjq.ajax.buildRequest.call(
                    formlet[0],
                    {type: annotations.form_attrs.method,
                     attrs: annotations.ajax_attrs,
                     extra_options: extra_options,
                     extra_callbacks: extra_callbacks
                    });
                if(!roptions) return false;

                roptions.data = jQuery.param(roptions.data) + "&" + data;

                jQuery.ajax(annotations.form_attrs.action, roptions);

                return false;

            }
        },

        datepicker: {
            init: function(annotations) {
                if(!this.disabled) {
                    jQuery(this).datepicker(hjq.getOptions(annotations));
                }
            }
        },

        sortable_collection: {
            init: function(annotations) {
                var options = jQuery.extend({update: hjq.sortable_collection.update}, hjq.getOptions(annotations));
                jQuery(this).sortable(options);
            },

            update: function() {
                var annotations = jQuery(this).data('rapid')['sortable-collection'];
                var roptions = hjq.ajax.buildRequest({type: 'post',
                                                      attrs: annotations.ajax_attrs
                                                     });
                roptions.data['authenticity_token']=hjq.data.form_auth_token.value;
                roptions.data=jQuery.param(roptions.data);
                jQuery(this).children("li[data-model-id]").each(function(i) {
                    roptions.data = roptions.data+"&"+annotations.reorder_parameter+"[]="+jQuery(this).data('model-id').toString();
                });

                jQuery.ajax(annotations.reorder_url, roptions);
            }
        },

        select_many: {
            init: function(annotations) {
                jQuery(this).children('select').on('change', hjq.select_many.addOne);
                jQuery(this).on('click', 'input.remove-item', hjq.select_many.removeOne);
            },

            addOne: function() {
                var top=$(this).parents(".select-many");
                var selected=$(this).find("option:selected");
                if(selected.val()) {
                    var clone=top.find(".item-proto .item").clone().removeClass("proto-item");
                    clone.find("span").text(selected.text());
                    clone.find("input[type=hidden]").val(selected.val()).removeClass("proto-hidden");
                    clone.css('display', 'none');
                    top.find(".items").append(clone);
                    clone.slideDown('fast');

                    var optgroup = jQuery("<optgroup/>").
                        attr('alt', selected.val()).
                        attr('label', selected.text()).
                        addClass("disabled-option");
                    selected.replaceWith(optgroup);
                    selected.parent().val("");

                    clone.trigger("rapid:add", clone);
                    clone.trigger("rapid:change", clone);
                }
            },

            removeOne: function() {
                var element = jQuery(this).parent();
                var top = element.parents('.select-many');
                var label = element.children("span").text();
                var optgroup = top.find("optgroup").filter(function() {return this.label==label;});
                optgroup.replaceWith(jQuery("<option/>").text(label).val(optgroup.attr('alt')));
                element.slideUp(function() {
                    element.trigger("rapid:remove", element);
                    element.trigger("rapid:change", element);
                    element.remove();
                });
            }
        },

        autocomplete: {
            init: function(annotations) {
                if(!this.disabled) {
                    jQuery(this).autocomplete(hjq.getOptions(annotations));
                }
            }
        },

        combobox: {
            init: function(annotations) {
                var select = jQuery(this).find('select');
                if(!select.attr('disabled')) {
                    var options = hjq.getOptions(annotations);
                    options.selected = options.selected || function(event, ui) {
                        // fire the prototype.js event on the <select/> for backwards compatibility
                        $(this).simulate('change');
                    }
                    select.combobox(options);
                }
            }
        },

        dialog: {
            init: function(annotations) {
                var options=hjq.getOptions(annotations);
                if(!options.position) {
                    var pos = jQuery(this).prev().position();
                    options.position = [pos.left, pos.top];
                }
		if(annotations.buttons) {
                    options.buttons = {};
		    for(var i=0; i<annotations.buttons.length; i++) {
			options.buttons[annotations.buttons[i][0]] = hjq.util.createFunction(annotations.buttons[i][1])
		    }
		}
                jQuery(this).dialog(options);
            },

            /* useful in the "buttons" option.  Dialog is an optional parameter -- if not set, 'this' is closed instead. */
            close: function() {
                var jq=hjq.util.jQuerifyFirstElement.apply(this, arguments);
                if(!jq.hasClass("hjq-dialog")) jq=jq.parents(".hjq-dialog");
                jq.dialog('close');
            },

            /* useful in the "buttons" option.  Will submit any enclosed formlets. */
            submitFormlet: function(extra_options, extra_attrs) {
                jQuery(this).find(".formlet").each(function() {
                    hjq.formlet.submit.call(this, extra_options, extra_attrs);
                });
            },

            /* useful in the "buttons" option.  Will submit all enclosed forms, whether AJAX or not */
            submitForm: function() {
                jQuery(this).find("form").each(function() {
                    if(jQuery(this).attr("onsubmit")) {
                        eval("onsubmit_func = function() {\n"+jQuery(this).attr("onsubmit")+"\n}");
                        onsubmit_func.apply(this);
                    } else {
                        this.submit();
                    }
                });
            },

            /* calls submit_form, and then closes the dialog box.   */

            /* useful in the "buttons" option.  Submits any enclosed formlets, and closes them */
            submitFormletAndClose: function() {
                var dialog = jQuery(this);
                hjq.dialog.submitFormlet.call(this, {success: function() {hjq.dialog.close.call(dialog);}});
            },

            /* oops, I broke convention in previous releases, so for
               backwards compatibility... */
            submit_form: function () { hjq.dialog.submitForm.apply(this, arguments);},
            submit_formlet: function () { hjq.dialog.submitFormlet.apply(this, arguments);},
            submit_formlet_and_close: function () { hjq.dialog.submitFormletAndClose.apply(this, arguments);}
        },

        dialog_opener: {
            click: function(button, selector) {
                var dialog = jQuery(selector);
                if(dialog.dialog('isOpen')) {
                    dialog.dialog('close');
                } else {
                    dialog.dialog('open');
                }
            }
        },

        spinner: {
            min_time: 500, // milliseconds

            // Hobo.showSpinner takes a DOM id in nextTo.   This
            // function will take either a jQuery selector or the
            // actual element object.
            show: function (message, nextTo) {
                clearTimeout (hjq.spinner.timer);
                hjq.spinner.hide_at = new Date().getTime() + hjq.spinner.min_time;
                if (t = jQuery('#ajax-progress-text')) {
                    if (!message || message.length == 0) {
                        t.hide();
                    } else {
                        t.text(message).show();
                    }
                }
                if (e = jQuery('#ajax-progress')) {
                    if (nextTo) {
                        e.position({
                            my: "left center",
                            at: "right center",
                            of: nextTo,
                            offset: "5 0"
                        })
                    }
                    e.show();
                }
            },

            hide: function() {
                if (e = jQuery('#ajax-progress')) {
                    var remainingTime = hjq.spinner.hide_at - new Date().getTime();
                    if (remainingTime <= 0) {
                        e.hide('fast');
                    } else {
                        hjq.spinner.timer = setTimeout(function () { e.hide('fast') },
                                                       remainingTime);
                    }
                }
            },

        },

        toggle_edit: {
            init: function(annotations) {
                if(!(jQuery(this).find(':input:first').attr('disabled'))) {
                    jQuery(this).toggleEdit(jQuery.extend({types: hjq.toggle_edit.customTypes},
                                                          hjq.getOptions(annotations)));
                }
            }
        },

        click_editor: {
            init: function(annotations) {
                jQuery(this).removeClass('hidden').click(hjq.click_editor.click);
                jQuery(this).next('.in-place-form').addClass('hidden').find(":input").on('blur', hjq.click_editor.blur).on('change', hjq.click_editor.change);
            },

            click: function(event) {
                jQuery(this).addClass('hidden').
                    next('.in-place-form').removeClass('hidden').
                    find('textarea,input[type=text]').focus();
            },

            blur: function(event) {
                var formlet = jQuery(this).closest('.in-place-form');
                formlet.addClass('hidden');
                formlet.prev('.in-place-edit').removeClass('hidden');
            },

            change: function(event) {
                var formlet = jQuery(this).closest('.in-place-form');
                formlet.prev('.in-place-edit').text('saving...');
                hjq.formlet.submit.call(formlet.get(0));
            }

        },

        live_editor: {
            init: function(annotations) {
                jQuery(this).on('change', hjq.live_editor.change);
            },

            change: function(event) {
                var formlet = jQuery(this).closest('.in-place-form');
                hjq.formlet.submit.call(formlet.get(0));
            }

        },

        ajax: {
            // a reimplementation of Hobo.updateElement
            update: function (dom_id, innerHtml) {
                hjq.initialize.apply(jQuery("#"+dom_id).html(innerHtml));
            },

            /* Build an options object suitable for sending to
             * jQuery.ajax.  (Note that the before & confirm callbacks
             * are called from this function, and the spinner is shown)
             *
             * The returned object will include a 'data' value
             * populated with a hash.
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
             * Note: "this" is passed to all callbacks and events,
             * so make sure you pass it to this function
            */
            buildRequest: function(o) {
                if (!o.attrs) o.attrs = {};
                if (!o.extra_callbacks) o.extra_callbacks = {};
                var options = {};

                if(o.attrs.before) {
                    if(!hjq.util.createFunction(o.attrs.before).call(this)) {
                        return false;
                    }
                }

                var before_evt=jQuery.Event("rapid:ajax:before");
                jQuery(this).trigger(before_evt, [this]);
                if(before_evt.isPropagationStopped()) {
                    return false;
                }

                if(o.attrs.confirm) {
                    if(!confirm(o.attrs.confirm)) {
                        return false;
                    }
                }

                options.context = this;
                options.type = o.type || 'GET';
                options.data = {"render_options[preamble]": o.preamble || '',
                                "render_options[contexts_function]": 'hjq.ajax.updatePartContexts'
                               };
                if(o.postamble) options.data["render_options[postamble]"] = o.postamble;
                if(o.content_type) options.data["render_options[content_type]"] = o.content_type;
                if(o.attrs.errors_ok) options.data["render_options[errors_ok]"] = 1;
                options.dataType = 'script';
                o.spec = jQuery.extend({'function': 'hjq.ajax.update', preamble: ''}, o.spec);

                // we tell our controller which parts to return by sending it a "render" array.
                var ids=hjq.ajax.getUpdateIds.call(this, o.attrs);
                for(var i=0; i<ids.length; i++) {
                    options.data["render["+i+"][part_context]"] = hjq.data.hobo_parts[ids[i]];
                    options.data["render["+i+"][id]"] = ids[i];
                    options.data["render["+i+"][function]"] = o.function || 'hjq.ajax.update';
                }

                hjq.spinner.show(o.attrs.message || "Saving...", o.attrs.spinner_next_to);

                var success_dfd = jQuery.Deferred();
                if(o.attrs.success) success_dfd.done(hjq.util.createFunction(o.attrs.success));
                if(o.extra_callbacks.success) success_dfd.done(hjq.util.createFunction(o.extra_callbacks.success));
                success_dfd.done(function() { $(document).trigger('rapid:ajax:success', [this]); });
                options.success = success_dfd.resolve;

                var error_dfd = jQuery.Deferred();
                if(o.attrs.error) error_dfd.done(hjq.util.createFunction(o.attrs.error));
                if(o.extra_callbacks.error) error_dfd.done(hjq.util.createFunction(o.extra_callbacks.error));
                error_dfd.done(function() { $(this).trigger('rapid:ajax:error', [this]); });
                options.error = error_dfd.resolve;

                var complete_dfd = jQuery.Deferred();
                if(o.attrs.complete) complete_dfd.done(hjq.util.createFunction(o.attrs.complete));
                if(o.extra_callbacks.complete) complete_dfd.done(hjq.util.createFunction(o.extra_callbacks.complete));
                complete_dfd.done(function() {
                    $(document).trigger('rapid:ajax:complete', [this]);
                    hjq.spinner.hide.call(this);
                });
                options.complete = complete_dfd.resolve;

                jQuery.extend(options, o.extra_options);

                return options;
            },

            // given ajax_attrs (update, updates and/or ajax), return DOM id's.   context (this) must be set to an element or jquery set.
            getUpdateIds: function(attrs) {
                var ids = attrs.update || [];
                if (typeof ids=='string') ids=ids.split(',');

                jQuery(attrs.updates).each(function () {
                    ids.push(jQuery(this).attr('id'));
                });

                if(attrs.ajax) {
                    for(var el=jQuery(this); el.length && !hjq.data.hobo_parts[el.attr("id")]; el=el.parent());
                    if(el.length) ids.push(el.attr('id'));
                }

                // validate
                for (var i=0; i<ids.length; i++) {
                    if(!hjq.data.hobo_parts[ids[i]]) {
                        ids.splice(i, 1);
                        i -= 1;
                    }
                }

                return ids;
            },

            // the function Hobo uses to update our part contexts
            // after Ajax
            updatePartContexts: function(contexts) {
                jQuery.extend(hjq.data.hobo_parts, contexts);
            }
        }
    }
})();


/* stolen from http://jqueryui.com/demos/autocomplete/#combobox
 *
 * and these options added.
 *
 * - autoFill (default: true):  select first value rather than clearing if there's a match
 *
 * - clearButton (default: true): add a "clear" button
 *
 * - adjustWidth (default: true): if true, will set the autocomplete width the same as
 *    the old select.  (requires jQuery 1.4.4 to work on IE8)
 *
 * - uiStyle (default: false): if true, will add classes so that the autocomplete input
 *    takes a jQuery-UI style
 */
(function( $ ) {
    $.widget( "ui.combobox", {
        options: {
            autoFill: true,
            clearButton: true,
            adjustWidth: true,
            uiStyle: false,
            selected: null,
        },
	_create: function() {
	    var self = this,
	      select = this.element.hide(),
	      selected = select.children( ":selected" ),
	      value = selected.val() ? selected.text() : "",
              found = false;
	    var input = this.input = $( "<input>" )
                .attr('title', '' + select.attr("title") + '')
		.insertAfter( select )
		.val( value )
		.autocomplete({
		    delay: 0,
		    minLength: 0,
		    source: function( request, response ) {
		        var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
                        var resp = select.children( "option" ).map(function() {
		            var text = $( this ).text();
		            if ( this.value && ( !request.term || matcher.test(text) ) )
		        	return {
		        	    label: text.replace(
		        		new RegExp(
		        		    "(?![^&;]+;)(?!<[^<>]*)(" +
		        			$.ui.autocomplete.escapeRegex(request.term) +
		        			")(?![^<>]*>)(?![^&;]+;)", "gi"
		        		), "<strong>$1</strong>" ),
		        	    value: text,
		        	    option: this
		        	};
		        });
                        found = resp.length > 0;
		        response( resp );
		    },
		    select: function( event, ui ) {
		        ui.item.option.selected = true;
		        self._trigger( "selected", event, {
		            item: ui.item.option
		        });
		    },
		    change: function( event, ui ) {
		        if ( !ui.item ) {
		            var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( $(this).val() ) + "$", "i" ),
		            valid = false;
		            select.children( "option" ).each(function() {
		        	if ( $( this ).text().match( matcher ) ) {
		        	    this.selected = valid = true;
		        	    return false;
		        	}
		            });
		            if ( !valid || input.data("autocomplete").term=="" ) {
		        	// set to first suggestion, unless blank or autoFill is turned off
                                var suggestion;
                                if(!self.options.autoFill || input.data("autocomplete").term=="") found=false;
                                if(found) {
                                    suggestion = jQuery(input.data("autocomplete").widget()).find("li:first");
                                    var option = select.find("option:contains('"+suggestion.text()+"')").attr('selected', true);
                                    $(this).val(suggestion.text());
		        	    input.data("autocomplete").term = suggestion.text();
		                    self._trigger( "selected", event, { item: option[0] });
                                } else {
                                    select.find("option:selected").removeAttr("selected");
                                    $(this).val('');
		        	    input.data( "autocomplete" ).term = '';
                                    self._trigger( "selected", event, { item: null });
                                }
		        	return found;
		            }
		        }
		    }
		});

            if( self.options.adjustWidth ) { input.width(select.width()); }

            if( self.options.uiStyle ) {
                input.addClass( "ui-widget ui-widget-content ui-corner-left" );
            }


	    input.data( "autocomplete" )._renderItem = function( ul, item ) {
	        return $( "<li></li>" )
	            .data( "item.autocomplete", item )
	            .append( "<a>" + item.label + "</a>" )
	            .appendTo( ul );
	    };

	    this.button = $( "<button type='button'>&nbsp;</button>" )
	        .attr( "tabIndex", -1 )
	        .attr( "title", "Show All Items" )
	        .insertAfter( input )
	        .button({
	            icons: {
	        	primary: "ui-icon-triangle-1-s"
	            },
	            text: false
	        })
	        .removeClass( "ui-corner-all" )
	        .addClass( "ui-corner-right ui-button-icon" )
	        .click(function() {
	            // close if already visible
	            if ( input.autocomplete( "widget" ).is( ":visible" ) ) {
	        	input.autocomplete( "close" );
	        	return;
	            }

	            // work around a bug (likely same cause as #5265)
	            $( this ).blur();

	            // pass empty string as value to search for, displaying all results
	            input.autocomplete( "search", "" );
	            input.focus();
	        });

            if( self.options.clearButton ) {
	        this.clear_button = $( "<button type='button'>&nbsp;</button>" )
	            .attr( "tabIndex", -1 )
	            .attr( "title", "Clear Entry" )
	            .insertAfter( input )
	            .button({
	                icons: {
	        	    primary: "ui-icon-close"
	                },
	                text: false
	            })
	            .removeClass( "ui-corner-all" )
	            .click(function(event, ui) {

                        select.find("option:selected").removeAttr("selected");
                        input.val( "" );
	                input.data( "autocomplete" ).term = "";
                        self._trigger( "selected", event, { item: null });

	                // work around a bug (likely same cause as #5265)
	                $( this ).blur();
	            });
            }

	},

	destroy: function() {
	    this.input.remove();
	    this.button.remove();
	    this.element.show();
	    $.Widget.prototype.destroy.call( this );
	}
    });
})( jQuery );
