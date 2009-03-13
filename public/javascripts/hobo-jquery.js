
var hjq = (function() {
    return {
        log: function(s) {
            if(console && console.log) console.log(s);
        },

        input_many: {
            init: function () {
                var me = jQuery(this).next();

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
                var template = top.find("li.input-many-template:first");
                var clone = template.clone(true).removeClass("input-many-template");
                var name_updater = hjq.input_many.getNameUpdater.call(top, top.children().length-1);

                // enable previously marked elements, and rename
                clone.find(".input_many_template_input").each(function() {
                    this.disabled = false;
                    jQuery(this).removeClass("input_many_template_input");
                    name_updater.call(this);
                });

                clone.insertAfter(me);

                me.children("div.buttons").children("button.add-item").remove();

                return false; // prevent bubbling
            },

            removeOne: function() {
                var me = jQuery(this).parent().parent();
                var top = me.parent();
            },

            // given this==the input-many, returns a lambda that updates the name & id for an element
            getNameUpdater: function(new_index) {
                var name_prefix = Hobo.getClassData(this.get(0), 'input-many-prefix');
                var id_prefix = name_prefix.replace(/\[/g, "_").replace(/\]/g, "");
                var name_re = RegExp("^" + RegExp.escape(name_prefix)+ "\[\-?[0-9]+\]");
                var name_sub = name_prefix + '[' + new_index.toString() + ']';
                var id_re = RegExp("^" + RegExp.escape(id_prefix)+ "\[\-?[0-9]+\]");
                var id_sub = id_prefix + '_' + new_index.toString();

                return function() {
                    if(this.name) {
                        this.name = this.name.sub(name_re, name_sub);
                    }
                    if (id_prefix==this.id.slice(0, id_prefix.length)) {
                        this.id = this.id.sub(id_re, id_sub);
                    } else {
                        hjq.log("hjq.input_many.update_id: id_prefix "+id_prefix+" didn't match input "+this.id);
                    }
                };
            }

        }
    };
})();

