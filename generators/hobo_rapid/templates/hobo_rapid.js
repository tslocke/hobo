
Object.extend = function(destination) {
    $A(arguments).slice(1).each(function (src) {
        for (var property in src) {
            destination[property] = src[property];
        }
    })
    return destination
}

Object.merge = function() {
    return Object.extend.apply(this, [{}].concat($A(arguments)))
}

var Hobo = {

    searchRequest: null,

    ajaxRequest: function(url_or_form, message, updates, options) {

        options = Object.merge({ asynchronous:true,
                                 evalScripts:true }, options)
        if (typeof url_or_form == "string") {
            var url = url_or_form
            var form = false
        } else {
            var form = url_or_form
            var url = form.action
        }
        var params = []
        if (updates.length > 0) {
            updates.each(function(dom_id) {
                params.push("render[][part]=" + hoboParts[dom_id][0] +
                            "&render[][id]=" + dom_id +
                            "&render[][object]=" + hoboParts[dom_id][1])
            })
            params.push("part_page=" + hoboPartPage)
        }

        if (options.resultUpdate) {
            options.resultUpdate.each(function (result_update) {
                params.push("render[][id]=" + result_update[0] +
                            "&render[][result]=" + result_update[1])
            })
        }

        if (options.params) {
            params.push(options.params)
            delete options.params
        }

        if (form) {
            params.push(Form.serialize(form))
        }

        Hobo.showSpinner(message)
        var complete = function() {
            if (form) form.reset();
            Hobo.hideSpinner();

            if (options.onComplete)
                options.onComplete.apply(this, arguments)
            if (form) Form.focusFirstElement(form)
        }
        if (options.method && options.method.toLowerCase() == "put") {
            delete options.method
            params.push("_method=PUT")
        }
        new Ajax.Request(url, Object.merge(options, { parameters: params.join("&"), onComplete: complete }))
    },

    hide: function() {
        for (i = 0; i < arguments.length; i++) {
            if ($(arguments[i])) {
                Element.addClassName(arguments[i], 'hidden')
            }
        }
    },

    show: function() {
        for (i = 0; i < arguments.length; i++) {
            if ($(arguments[i])) {
                Element.removeClassName(arguments[i], 'hidden')
            }
        }
    },

    applyEvents: function(root) {
        root = $(root)
        function select(p) {
            return new Selector(p).findElements(root)
        }

        select(".in_place_edit_bhv").each(function (el) {
            var old
            var spec = Hobo.parseFieldId(el)
            options = {okButton: false,
                       cancelLink: false,
                       submitOnBlur: true,
                       callback: function(form, val) {
                           old = val
                           return spec.name + '[' + spec.field + ']=' + val
                       },
                       highlightcolor: '#ffffff',
                       highlightendcolor: Hobo.backgroundColor(el),
                       onFailure: function(t) { alert(t.responseText); el.innerHTML = old }
                      }
            if (el.hasClassName("textarea_editor")) {
                options.rows = 2
            }
            new Ajax.InPlaceEditor(el, Hobo.putUrl(el), options)
        });

        select(".autocomplete_bhv").each(function (el) {
            options = {paramName: "query", minChars: 3, method: 'get' }
            if (el.hasClassName("autosubmit")) {
                options.afterUpdateElement = function(el, item) { el.form.onsubmit(); }
            }
            new Ajax.Autocompleter(el, el.id + "_completions", el.getAttribute("autocomplete_url"),
                                   options);
        });

        select(".search_bhv").each(function(el) {
            new Form.Element.Observer(el, 1.0, function() { Hobo.doSearch(el) })
        });
    },

    doSearch: function(el) {
        el = $(el)
        var spinner = $(el.getAttribute("search_spinner") || "search_spinner")
        var search_results = $(el.getAttribute("search_results") || "search_results")
        var search_results_panel = $(el.getAttribute("search_results_panel") || "search_results_panel")
        var url = el.getAttribute("search_url") || (urlBase + "/search")

        el.focus();
        var value = $F(el)
        if (Hobo.searchRequest) { Hobo.searchRequest.transport.abort() }
        if (value.length >= 3) {
            if (spinner) Hobo.show(spinner);
            Hobo.searchRequest = new Ajax.Updater(search_results,
                                                  url,
                                                  { asynchronous:true,
                                                    evalScripts:true,
                                                    onSuccess:function(request) {
                                                        if (spinner) Hobo.hide(spinner)
                                                        if (search_results_panel) {
                                                            Hobo.show(search_results_panel)
                                                         }
                                                    },
                                                    parameters:"query=" + value });
        } else {
            Hobo.updateElement(search_results, '')
            Hobo.hide(search_results_panel)
        }
    },


    putUrl: function(el) {
        spec = Hobo.parseFieldId(el)
        return urlBase + "/" + controllerNames[spec.name] + "/" + spec.id + "?_method=PUT"
    },

    removeButton: function(el, url) {
        if (confirm("Are you sure?")) {
            objEl = Hobo.objectElementFor(el)
            Hobo.showSpinner('Removing');
            function complete() {
                Hobo.hideSpinner();
                new Effect.Fade(objEl, {duration: 0.5});
            }
            new Ajax.Request(url, {asynchronous:true, evalScripts:true, method:'delete', onComplete: complete});
        }
    },


    parseFieldId: function(el) {
        id = el.getAttribute("model_id")
        if (!id) return
        m = id.match(/^([a-z_]+)_([0-9]+)_([a-z_]+)$/)
        if (m) return { name: m[1], id: m[2], field: m[3] }
    },

    appendRow: function(el, rowSrc) {
        // IE friendly method to add a <tr> (from html source) to a table
        // el should be an element that contains *only* a table
        el = $(el);
        el.innerHTML = el.innerHTML.replace("</table>", "") + rowSrc + "</table>";
        Hobo.applyEvents(el)
    },

    objectElementFor: function(el) {
        var m
        while(el.getAttribute) {
            id = el.getAttribute("model_id") || el.getAttribute("id");
            if (id) m = id.match(/^([a-z_]+)_([0-9]+)(_[a-z0-9_]*)?$/);
            if (m) break;
            el = el.parentNode;
        }
        if (m) return el;
    },


    showSpinner: function(message) {
        if(t = $('ajax_progress_text')) Element.update(t, message);
        if(e = $('ajax_progress')) e.style.display = "block";
    },


    hideSpinner: function() {
        if(e = $('ajax_progress')) e.style.display = "none";
    },


    updateElement: function(id, content) {
        Element.update(id, content)
        Hobo.applyEvents(id)
    },

    rgbColorToHex: function(color) {
        parts = /^rgb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)/.exec(color)
        function hexPart(s) {
            var res = (s * 1).toString(16)
            return res.length == 1 ? '0' + res : res
        }
        if (parts) {
            return '#' + hexPart(parts[1]) + hexPart(parts[2]) + hexPart(parts[3])
        } else {
            return color
        }
    },

    getStyle: function(el, styleProp) {
        if (el.currentStyle)
            var y = el.currentStyle[styleProp];
        else if (window.getComputedStyle)
            var y = document.defaultView.getComputedStyle(el, null).getPropertyValue(styleProp);
        return y;
    },

    backgroundColor: function(el) {
        return Hobo.rgbColorToHex(Hobo.getStyle(el, 'background-color'))
    }

}

Element.findContaining = function(el, tag) {
    el = $(el)
    tag = tag.toLowerCase()
    e = el.parentNode
    while (el) {
        if (el.nodeName.toLowerCase() == tag) {
            return el;
        }
        e = el.parentNode
    }
    return null;
}
