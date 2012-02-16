/* select_many */
(function($) {
    var methods = {
        init: function(annotations) {
            this.children('select').on('change', methods.addOne);
            this.on('click', 'input.remove-item', methods.removeOne);
        },

        addOne: function() {
            var that=$(this);
            var top=that.parents(".select-many");
            var annotations = top.data('rapid')['select-many'];
            var selected=that.find("option:selected");
            if(selected.val()) {
                var clone=top.find(".item-proto .item").clone().removeClass("proto-item");
                clone.find("span").text(selected.text());
                clone.find("input[type=hidden]").val(selected.val()).removeClass("proto-hidden");
                clone.css('display', 'none');
                top.find(".items").append(clone);

                var optgroup = $("<optgroup/>").
                    attr('alt', selected.val()).
                    attr('label', selected.text()).
                    addClass("disabled-option");
                selected.replaceWith(optgroup);
                selected.parent().val("");

                clone.hjq('show', annotations.show, function() {
                    clone.trigger("rapid:add", clone);
                    clone.trigger("rapid:change", clone);
                });
            }
        },


        removeOne: function() {
            var that=$(this);
            var element = that.parent();
            var top = element.parents('.select-many');
            var annotations = top.data('rapid')['select-many'];
            var label = element.children("span").text();
            var optgroup = top.find("optgroup").filter(function() {return this.label==label;});
            optgroup.replaceWith($("<option/>").text(label).val(optgroup.attr('alt')));
            element.hjq('hideAndRemove', annotations.hide, function() {
                element.trigger("rapid:remove", element);
                element.trigger("rapid:change", element);
            });
        }
    };

    $.fn.hjq_select_many = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_select_many' );
        }
    };

})( jQuery );
