// our monkey patches to Function, properly namespaced.

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

// the Hobo part mechanism uses Element.update to do it's work
Element.addMethods({update: Element.Methods.update.hjq_chain(function(id, content) {
    if(!id.nodeType) id="#"+id;  // assume it's a string
    hjq.initialize.apply(jQuery(id));
})});

var hjq = (function() {
    return {

        /* calls all "init" functions with their this and their annotations */
        initialize: function() {
            jQuery(this).find('.hjq-annotated').each(function() {
                var annotations = hjq.getAnnotations.call(this);
                if(annotations.init) {
                    hjq.util.createFunction(annotations.init).call(this, annotations);
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
            /* this function uses the jquery form plugin to submit the
            form via jquery form plugin ajax, rather than using the
            standard HTTP or Hobo form submission mechanisms.  The
            main advantage this has is that the jquery form plugin
            supports ajax submission of attachments.

            You must have the jquery form plugin installed.   It is
            not installed automatically by hobo-jquery.

            FIXME:  this function HARD CODES it's ajax options, in
            particular update="attachments-div".  It does not (yet)
            get the parameters from the form, nor does it get them
            through the standard hobo-jquery mechanism.
            */
          submit: function() {
            var attrs = {
              update: ['attachments-div']
            };
            var options = {
              complete: Hobo.hideSpinner,
              data: {},
              dataType: 'script',
              beforeSend: function(xhr) { xhr.setRequestHeader("Accept", "text/javascript"); }
            };
            var form = jQuery(this).closest("form");

            for(i=0; i<attrs.update.length; i++) {
              var id = attrs.update[i];
              if(id=="self") {
                for(var el=jQuery(this); el.length && !hoboParts[el.attr("id")]; el=el.parent());
                id = ( el.length ? el.attr("id") : undefined) ;
              }
              if(id) {
                options.data["render["+i+"][part_context]"] = hoboParts[id];
                options.data["render["+i+"][id]"] = id;
              }
            }

            Hobo.showSpinner(attrs.message || "Saving...", attrs.spinner_next_to);
            form.ajaxSubmit(options);

            //prevent bubbling
            return false;
          }
        },

        formlet: {
            // call with this==the formlet or a child of the formlet to submit the formlet
            submit: function(extra_callbacks, extra_options) {
                var formlet = jQuery(jQuery(this).closest(".formlet").get(0));
                var annotations = hjq.getAnnotations.call(formlet.get(0));

                var options = annotations.ajax_options;
                var attrs = annotations.ajax_attrs;
                jQuery.extend(options, extra_options);

                if(!extra_callbacks) extra_callbacks = {};

                if(attrs.before) {
                    if(!hjq.util.createFunction(attrs.before).call(formlet.get(0))) {
                        return false;
                    }
                }

                if(attrs.confirm) {
                    if(!confirm(attrs.confirm)) {
                        return false;
                    }
                }

                // make sure we don't serialize any nested forms
                options.data = formlet.find(":input").
                    not(formlet.find("form :input")).
                    not(formlet.find(".formlet :input")).
                    serialize();
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

                options.success = hjq.util.createFunction(attrs.success).hjq_chain(extra_callbacks.success).hjq_bind(formlet.get(0));
                options.error = hjq.util.createFunction(attrs.error).hjq_chain(extra_callbacks.error).hjq_bind(formlet.get(0));
                options.complete = Hobo.hideSpinner.hjq_chain(hjq.util.createFunction(attrs.complete)).hjq_chain(extra_callbacks.complete).hjq_bind(formlet.get(0));

                jQuery.ajax(options);

                //prevent bubbling
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
            submit_formlet: function(extra_options, extra_attrs) {
                jQuery(this).find(".formlet").each(function() {
                    hjq.formlet.submit.call(this, extra_options, extra_attrs);
                });
            },

            /* useful in the "buttons" option.  Will submit all enclosed forms, whether AJAX or not */
            submit_form: function() {
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
            submit_formlet_and_close: function() {
                var dialog = jQuery(this);
                hjq.dialog.submit_formlet.call(this, {success: function() {hjq.dialog.close.call(dialog);}});
            }
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
        }
    };
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
