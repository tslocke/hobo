
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
    uidCounter: 0,
    ipeOldValues: {},

    uid: function() {
        Hobo.uidCounter += 1
        return "uid" + Hobo.uidCounter
    },

    updatesForElement: function(el) {
        el = $(el)
        var updates = el.getAttribute("hobo_update")
        return updates ? updates.split(/\s*,\s*/) : []
    },

    ajaxSetFieldForElement: function(el, val, options) {
        var updates = Hobo.updatesForElement(el)
        var params = Hobo.fieldSetParam(el, val)
        var p = el.getAttribute("hobo_ajax_params")
        if (p) params = params + "&" + p

        var opts = Object.merge(options || {}, { params: params})
        Hobo.ajaxRequest(Hobo.putUrl(el),
                         el.getAttribute("hobo_ajax_message") || "Changing...",
                         updates,
                         opts)
    },

    ajaxUpdateParams: function(updates, resultUpdates) {
        var params = []
        var i = 0
        if (updates.length > 0) {
            updates.each(function(dom_id) {
                params.push("render["+i+"][part]=" + hoboParts[dom_id][0])
                params.push("render["+i+"][id]=" + dom_id)
                params.push("render["+i+"][object]=" + hoboParts[dom_id][1])
                i += 1
            })
            params.push("part_page=" + hoboPartPage)
        }

        if (resultUpdates) {
            resultUpdates.each(function (resultUpdate) {
                params.push("render["+i+"][id]=" + resultUpdate.id)
                params.push("render["+i+"][result]=" + resultUpdate.result)
                if (resultUpdate.func) {
                    params.push("render["+i+"][function]=" + resultUpdate.func)
                }
                i += 1
            })
        }
        return params.join('&')
    },

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
        
        updateParams = Hobo.ajaxUpdateParams(updates, options.resultUpdate)
        if (updateParams != "") { params.push(updateParams) }

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

        if (!options.onFailure) {
            options.onFailure = function(response) {
                alert(response.responseText)
            }
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

    toggle: function() {
        for (i = 0; i < arguments.length; i++) {
            if ($(arguments[i])) {
                if(Element.hasClassName(arguments[i], 'hidden')) {
                    Element.removeClassName(arguments[i], 'hidden')
                } else {
                    Element.addClassName(arguments[i], 'hidden')
                }
            }
        }
        },

    onFieldEditComplete: function(el, newValue) {
        el = $(el)
        var oldValue = Hobo.ipeOldValues[el.id]
        delete Hobo.ipeOldValues[el.id]

        var blank = el.getAttribute("hobo_blank_message")
        if (blank && newValue.strip().length == 0) {
            el.update(blank)
        } else {
            el.update(newValue)
        }

        var modelId = el.getAttribute('hobo_model_id')
        if (oldValue) {
            $$("*[hobo_model_id=" + modelId + "]").each(function(e) {
                if (e != el && e.innerHTML == oldValue) e.update(newValue)
            })
        }
    },

    _makeInPlaceEditor: function(el, options) {
        var old
        var spec = Hobo.parseFieldId(el)
        var updates = Hobo.updatesForElement(el)
        var id = el.id
        if (!id) { id = el.id = Hobo.uid() }
        var updateParams = Hobo.ajaxUpdateParams(updates, [{id: id,
                                                            result: 'new_field_value',
                                                            func: "Hobo.onFieldEditComplete"}])
        opts = {okButton: false,
                cancelLink: false,
                submitOnBlur: true,
                callback: function(form, val) {
                    old = val
                    return (Hobo.fieldSetParam(el, val) + "&" + updateParams)
                },
                highlightcolor: '#ffffff',
                highlightendcolor: Hobo.backgroundColor(el),
                onFailure: function(resp) { alert(resp.responseText); el.innerHTML = old },
                evalScripts: true
               }
        Object.extend(opts, options)
        var ipe = new Ajax.InPlaceEditor(el, Hobo.putUrl(el), opts)
        ipe.onEnterEditMode = function() {
            var blank_message = el.getAttribute("hobo_blank_message")
            if (el.innerHTML.gsub("&nbsp;", " ") == blank_message) {
                el.innerHTML = "" 
            } else {
                Hobo.ipeOldValues[el.id] = el.innerHTML
            }
        }
        return ipe
    },

    applyEvents: function(root) {
        root = $(root)
        function select(p) {
            return new Selector(p).findElements(root)
        }

        select(".in_place_textfield_bhv").each(function (el) {
            Hobo._makeInPlaceEditor(el)
        })

        select(".in_place_textarea_bhv").each(function (el) {
            Hobo._makeInPlaceEditor(el, {rows: 2})
        })

        select(".in_place_html_textarea_bhv").each(function (el) {
            var ipe = Hobo._makeInPlaceEditor(el, {rows: 2, handleLineBreaks: false})
            if (typeof(tinyMCE) != "undefined") {
                ipe.afterEnterEditMode = function() {
                    var id = this.form.id = Hobo.uid()

                    // 'orrible 'ack
                    // What is the correct way to individually configure a tinyMCE instace?
                    var old = tinyMCE.settings.theme_advanced_buttons1
                    tinyMCE.settings.theme_advanced_buttons1 += ", separator, save"
                    tinyMCE.addMCEControl(this.editField, id);
                    tinyMCE.settings.theme_advanced_buttons1 = old

                    this.form.onsubmit = function() {
                        tinyMCE.removeMCEControl(ipe.form.id)
                        setTimeout(ipe.onSubmit.bind(ipe), 10)
                        return false
                    }
                }
            }
        })

        select("select.number_editor_bhv").each(function(el) {
            el.onchange = function() {
                Hobo.ajaxSetFieldForElement(el, el.value)
            }
        })
                                                
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

        
    fieldSetParam: function(el, val) {
        spec = Hobo.parseFieldId(el)
        return spec.name + '[' + spec.field + ']=' + escape(val)
    },

    fadeObjectElement: function(el) {
        new Effect.Fade(Hobo.objectElementFor(el), {duration: 0.5});
    },

    removeButton: function(el, url, updates, fade) {
        if (fade == null) { fade = true; }
        if (confirm("Are you sure?")) {
            objEl = Hobo.objectElementFor(el)
            Hobo.showSpinner('Removing');
            function complete() {
                if (fade) { Hobo.fadeObjectElement(el) }
                Hobo.hideSpinner()
            }
            if (updates && updates.length > 0) {
                new Hobo.ajaxRequest(url, "Removing", updates, { method:'delete',
                                                                 onComplete: complete});
            } else {
                new Ajax.Request(url, {asynchronous:true, evalScripts:true, method:'delete',
                                       onComplete: complete});
            }
        }
    },


    parseFieldId: function(el) {
        id = el.getAttribute("hobo_model_id")
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
            id = el.getAttribute("hobo_model_id");
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

// Fix scriptaculous - don't remove <p> tags please!
Ajax.InPlaceEditor.prototype.convertHTMLLineBreaks = function(string) {
    return string.replace(/<br>/gi, "\n").replace(/<br\/>/gi, "\n");
}


origEnterEditMode = Ajax.InPlaceEditor.prototype.enterEditMode
Ajax.InPlaceEditor.prototype.enterEditMode = function(evt) {
    origEnterEditMode.bind(this)(evt)
    if (this.afterEnterEditMode) this.afterEnterEditMode()
    return false
}

// Silence errors from IE :-(
Field.scrollFreeActivate = function(field) {
  setTimeout(function() {
      try {
          Field.activate(field);
      } catch(e) {}
  }, 1);
}
