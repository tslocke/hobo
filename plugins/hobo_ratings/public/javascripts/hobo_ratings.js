Hobo.RatingsBase = {

    //onmousedown : function() {
    //    this.down = true
    //},
    // 
    //onmouseup : function() {
    //    this.down = false
    //},
    // 
    //onmousemove : function(e) {
    //    var el = e.target;
    //    Event.stop(e);
    //    if (this.down && el != this.last) {
    //        this.toggle(el);
    //        this.last = el;
    //    }
    //},

    onclick : function(e) {
        var el = Event.element(e);
        Event.stop(e);
        this.toggle(el)
    },

    toggle : function (el) {
        select = el.match('.unselected')

        if (select) {
            this.rating = this.ratingFor(el)
            while (el) {
                this.select(el)
                el = el.previous('span')
            }
        } else {
            var n = el.next('span')
            if (n && n.hasClassName("selected")) { el = n }
            this.rating = this.ratingFor(el) - 1
            while (el) {
                this.unselect(el)
                el = el.next('span')
            }
        }
        this.onchange()
    },

    ratingFor : function(el) {
        return el.className.match(/rating([0-9])+/)[1] * 1
    },


    unselect : function(e) {
        e.removeClassName('selected')
        e.addClassName('unselected')
    },

    select : function(e) {
        e.removeClassName('unselected')
        e.addClassName('selected')
    }

}

var RatingEditor = Behavior.create(Object.extend(Hobo.RatingsBase, { 
    onchange : function() { }
}))

var RatingInput = Behavior.create(Object.extend(Hobo.RatingsBase, { 
    onchange : function() {
        this.element.down('input').value = this.rating
    }
}))

Event.addBehavior({
    'div.hobo_rating.editor' : RatingEditor(),
    'div.hobo_rating.input'  : RatingInput()
});

