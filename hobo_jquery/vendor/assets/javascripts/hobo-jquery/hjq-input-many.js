
if(!RegExp.escape) {
    RegExp.escape = function(text) {
        return text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
    };
}

/* input-many */
(function($) {
    var methods = {
        init: function (annotations) {
            // disable all elements inside our template, and mark them so we can find them later.
            this.find(".input-many-template :input:not([disabled])").each(function() {
                this.disabled = true;
                $(this).addClass("input_many_template_input");
            });

            // bind event handlers
            this.find(".remove-item:not([disabled])").not(this.find(".input-many .remove-item")).click(methods.removeOne);
            this.find(".add-item:not([disabled])").not(this.find(".input-many .add-item")).click(methods.addOne);
        },

        addOne: function () {
            var me = $(this).parent().parent();
            var top = me.parent();
            var template = top.children("li.input-many-template");
            var clone = template.clone(true).removeClass("input-many-template");
            var attrs = top.data('rapid')['input-many'];

            // length-2 because ignore the template li and the empty li
            var name_updater = methods.getNameUpdater.call(top, top.children().length-2, attrs['prefix']);

            // enable previously marked elements
            clone.find(".input_many_template_input").each(function() {
                this.disabled = false;
                $(this).removeClass("input_many_template_input");
            });
            clone.find(".remove-item:not([disabled])").not(clone.find(".input-many .remove-item")).click(methods.removeOne);
            clone.find(".add-item:not([disabled])").not(clone.find(".input-many .add-item")).click(methods.addOne);

            // do the add with anim
            clone.css("display", "none").insertAfter(me).hjq('show', attrs['show']);

            top.hjq_input_many('updateNames');
            top.hjq_input_many('updateVisibility');

            // initialize subelements
            me.next().hjq();

            me.hjq('createFunction', attrs.add_hook).call(me.get(0));
            clone.trigger('rapid:add');
            clone.trigger('rapid:change');

            return false; // prevent bubbling
        },

        removeOne: function() {
            var me = $(this).parent().parent();
            var top = me.parent();
            var attrs = top.data('rapid')['input-many'];

            if(attrs.remove_hook) {
                if(!me.hjq('createFunction', attrs.remove_hook).call(me.get(0))) {
                    return false;
                };
            }

            var remove_evt=$.Event("rapid:remove");
            me.trigger(remove_evt, [me]);
            if(remove_evt.isPropagationStopped()) {
                return false;
            }

            // remove with animation
            me.hjq('hideAndRemove', attrs['hide']);

            top.hjq_input_many('updateNames');
            top.hjq_input_many('updateVisibility');

            top.trigger('rapid:change');

            return false; //prevent bubbling
        },

        updateNames: function() {
            var top = $(this);
            var attrs = top.data('rapid')['input-many'];

            var n = top.children("li:not(.input-many-template):not(.empty):first");
            for(var i = 0; n.length > 0; i++, n = n.next()) {
                var name_updater = methods.getNameUpdater.call(top, i, attrs['prefix']);
                n.find("*").each(function() {
                    name_updater.call(this);
                });
                name_updater.call(n.get(0));
            }
        },

        // show/hide +/- buttons and empty
        updateVisibility: function() {
            var top = $(this);
            var attrs = top.data('rapid')['input-many'];

            var buttonsDivs = top.children("li:not(.input-many-template):not(.empty)").children("div.buttons");
            for (var i = 0; i < buttonsDivs.length; i++) {
                if (i < (attrs['minimum'] || 0))
                    $(buttonsDivs[i]).children("button.remove-item").addClass("hidden");
                else
                    $(buttonsDivs[i]).children("button.remove-item").removeClass("hidden");
                if (i < buttonsDivs.length - 1)
                    $(buttonsDivs[i]).children("button.add-item").addClass("hidden");
                else
                    $(buttonsDivs[i]).children("button.add-item").removeClass("hidden");
            }

            var empty = top.children("li.empty");
            if (buttonsDivs.length == 0) {
                empty.removeClass("hidden");
                empty.find("input.empty-input").removeAttr("disabled");
            } else {
                empty.addClass("hidden");
                empty.find("input.empty-input").attr("disabled", true);
            }

            return top;
        },

        // given this==the input-many, returns a lambda that updates the name, for & id for an element
        getNameUpdater: function(new_index, name_prefix) {
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
                if ($(this).attr('for')) {
                    var new_for = $(this).attr('for').replace(id_re, id_sub);
                    $(this).attr('for', new_for);
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
                if(($(this).data('rapid') || {})['input-many']) {
                    var annos=$(this).data('rapid');
                    annos['input-many']['prefix'] = annos['input-many']['prefix'].replace(name_re, name_sub);
                    $(this).data('rapid', annos);
                }
                return this;
            };
        },

        // given this==an input-many item, get the submit index
        getIndex: function() {
            return Number(this.id.match(/_([-0-9]+)$/)[1]);
        }
    };

    $.fn.hjq_input_many = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_input_many' );
        }
    };

})( jQuery );
