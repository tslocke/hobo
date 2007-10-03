var RatingEditor = Behavior.create({

    onmousedown : function() {
        console.log(1)
        this.down = true
    },

    onmouseup : function() {
        this.down = false
    },

    onmousemove : function(e) {
        var el = Event.element(e);
        Event.stop(e);
        if (this.down && el != this.last) {
            this.toggle(el);
            this.last = el;
        }
    },

    onclick : function(e) {
        var el = Event.element(e);
        Event.stop(e);
        this.toggle(el)
    },

    toggle : function (el) {
        select = el.hasClassName('unselected')

        if (select) {
            while (el) {
                this.select(el)
                el = el.previous('span')
            }
        } else {
            var n = el.next('span')
            if (n && n.hasClassName("selected")) { el = n }
            while (el) {
                this.unselect(el)
                el = el.next('span')
            }
        }
    },

    unselect : function(e) {
        e.removeClassName('selected')
        e.addClassName('unselected')
    },

    select : function(e) {
        e.removeClassName('unselected')
        e.addClassName('selected')
    },


});

Event.addBehavior({
    'div.hobo_ratings_editor': RatingEditor()
});

