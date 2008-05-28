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
    spinnerMinTime: 1000, // milliseconds 

    uid: function() {
        Hobo.uidCounter += 1
        return "uid" + Hobo.uidCounter
    },

    updatesForElement: function(el) {
        el = $(el)
        var updates = el.getAttribute("hobo-update")
        return updates ? updates.split(/\s*,\s*/) : []
    },

    ajaxSetFieldForElement: function(el, val, options) {
        var updates = Hobo.updatesForElement(el)
        var params = Hobo.fieldSetParam(el, val)
        var p = el.getAttribute("hobo-ajax-params")
        if (p) params = params + "&" + p

        var opts = Object.merge(options || {}, { params: params, message: el.getAttribute("hobo-ajax-message")})
        Hobo.ajaxRequest(Hobo.putUrl(el), updates, opts)
    },

    ajaxUpdateParams: function(updates, resultUpdates) {
        var params = []
        var i = 0
        if (updates.length > 0) {
            updates.each(function(id_or_el) {
                var el = $(id_or_el)
                if (el) { // ignore update of parts that do not exist
                    var partDomId = el.id
                    if (!hoboParts[partDomId]) { throw "Update of dom-id that is not a part: " + partDomId }
                    params.push("render["+i+"][part_context]=" + encodeURIComponent(hoboParts[partDomId]))
                    params.push("render["+i+"][id]=" + partDomId)
                    i += 1
                }
            })
            params.push("page_path=" + hoboPagePath)
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

    ajaxRequest: function(url_or_form, updates, options) {
        options = Object.merge({ asynchronous:true,
                                 evalScripts:true,
                                 resetForm: false,
                                 refocusForm: false,
                                 message: "Saving..."
                               }, options)
        if (typeof url_or_form == "string") {
            var url = url_or_form
            var form = false
        } else {
            var form = url_or_form
            var url = form.action
        }
        var params = []

        if (typeof(formAuthToken) != "undefined") {
            params.push(formAuthToken.name + "=" + formAuthToken.value)
        }
        
        updateParams = Hobo.ajaxUpdateParams(updates, options.resultUpdate)
        if (updateParams != "") { params.push(updateParams) }

        if (options.params) {
            params.push(options.params)
            delete options.params
        }

        if (form) {
            params.push(Form.serialize(form))
        }

        Hobo.showSpinner(options.message, options.spinnerNextTo)
        var complete = function() {
            if (form && options.resetForm) form.reset();
            Hobo.hideSpinner();

            if (options.onComplete)
                options.onComplete.apply(this, arguments)
            if (form && options.refocusForm) Form.focusFirstElement(form)
            Event.addBehavior.reload()
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

        var blank = el.getAttribute("hobo-blank-message")
        if (blank && newValue.strip().length == 0) {
            el.update(blank)
        } else {
            el.update(newValue)
        }

        var modelId = el.getAttribute('hobo-model-id')
        if (oldValue) {
            $$("*[hobo-model-id=" + modelId + "]").each(function(e) {
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
        var opts = {okButton: false,
                    cancelLink: false,
                    submitOnBlur: true,
                    evalScripts: true,
                    htmlResponse: false,
                    ajaxOptions: { method: "put" },
                    onEnterHover: null,
                    onLeaveHover: null,
                    callback: function(form, val) {
                        old = val
                        return (Hobo.fieldSetParam(el, val) + "&" + updateParams)
                    },
                    onFailure: function(resp) { 
                        alert(resp.responseText); el.innerHTML = old
                    },
                    onEnterEditMode: function() {
                        var blank_message = el.getAttribute("hobo-blank-message")
                        if (el.innerHTML.gsub("&nbsp;", " ") == blank_message) {
                            el.innerHTML = "" 
                        } else {
                            Hobo.ipeOldValues[el.id] = el.innerHTML
                        }
                    }
                   }
        Object.extend(opts, options)
        return new Ajax.InPlaceEditor(el, Hobo.putUrl(el), opts)
    },

    nicEditorOptions: { buttonList : ['bold','italic',
                                      'left','center','right',
                                      'ul',
                                      'fontFormat',
                                      'indent','outdent',
                                      'link','unlink',
                                      'image', 'removeLink']},

    makeNicEditor: function(element) {
        if (!Hobo.nicEditorOptions.iconsPath) { Hobo.nicEditorOptions.iconsPath = urlBase + '/images/nicEditorIcons.gif' }
        var nic = new nicEditor(Hobo.nicEditorOptions)
        nic.panelInstance(element, {hasPanel : true})
        return nic.instanceById(element)
    },

    applyEvents: function(root) {
        root = $(root)
        function select(p) {
            return new Selector(p).findElements(root)
        }

        select(".in-place-textfield-bhv").each(function (el) {
            var ipe = Hobo._makeInPlaceEditor(el)
            ipe.getText = function() {
                return this.element.innerHTML.gsub(/<br\s*\/?>/, "\n").unescapeHTML()
            }
        })

        select(".in-place-textarea-bhv").each(function (el) {
            var ipe = Hobo._makeInPlaceEditor(el, {rows: 2})
            ipe.getText = function() {
                return this.element.innerHTML.gsub(/<br\s*\/?>/, "\n").unescapeHTML()
            }
        })

        select(".in-place-html-textarea-bhv").each(function (el) {
            var nicEditPresent = typeof(nicEditor) != "undefined"
            var options = { rows: 2, handleLineBreaks: false, okButton: true, cancelLink: true, okText: "Save" }
            if (nicEditPresent) options["submitOnBlur"] = false
            var ipe = Hobo._makeInPlaceEditor(el, options) 
            if (nicEditPresent) {
                ipe.afterEnterEditMode = function() {
                    var editor = this._controls.editor
                    var id = editor.id = Hobo.uid()
                    var nicInstance = Hobo.makeNicEditor(editor)
                    var panel = this._form.down(".nicEdit-panel")
                    panel.appendChild(this._controls.cancel)
                    panel.appendChild(this._controls.ok)
                    bkLib.addEvent(this._controls.ok,'click', function () {
                        nicInstance.saveContent()
                        setTimeout(function() {nicInstance.remove()}, 1)
                    })
                }
            }
        })

        select("select.number-editor-bhv").each(function(el) {
            el.onchange = function() {
                Hobo.ajaxSetFieldForElement(el, $F(el))
            }
        })
                                                
        select(".search-bhv").each(function(el) {
            new Form.Element.Observer(el, 1.0, function() { Hobo.doSearch(el) })
        });
    },


    doSearch: function(el) {
        el = $(el)
        var spinner = $(el.getAttribute("search-spinner") || "search-spinner")
        var search_results = $(el.getAttribute("search-results") || "search-results")
        var search_results_panel = $(el.getAttribute("search-results-panel") || "search-results-panel")
        var url = el.getAttribute("search-url") || (urlBase + "/search")

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
                                                        setTimeout(function() {Hobo.applyEvents(search_results)}, 1)
                                                    },
                                                    method: "get",
                                                    parameters:"query=" + value });
        } else {
            Hobo.updateElement(search_results, '')
            Hobo.hide(search_results_panel)
        }
    },


    putUrl: function(el) {
        var spec = Hobo.parseFieldId(el)
        return urlBase + "/" + Hobo.pluralise(spec.name) + "/" + spec.id + "?_method=PUT"
    },

    
    urlForId: function(id) {
        var spec = Hobo.parseId(id)
        var url = urlBase + "/" + Hobo.pluralise(spec.name)
        if (spec.id) { url += "/" + spec.id }
        return url
    },

        
    fieldSetParam: function(el, val) {
        var spec = Hobo.parseFieldId(el)
        var res = spec.name + '[' + spec.field + ']=' + encodeURIComponent(val)
        if (typeof(formAuthToken) != "undefined") {
            res = res + "&" + formAuthToken.name + "=" + formAuthToken.value
        }
        return res
    },


    fadeObjectElement: function(el) {
        var fadeEl = Hobo.objectElementFor(el)
        new Effect.Fade(fadeEl, { duration: 0.5, afterFinish: function (ef) { 
            ef.element.remove() 
        } });
        Hobo.showEmptyMessageAfterLastRemove(fadeEl)
    },


    removeButton: function(el, url, updates, options) {
        if (options.fade == null) { options.fade = true; }
        if (options.confirm == null) { options.fade = "Are you sure?"; }

        if (options.confirm == false || confirm(options.confirm)) {
            var objEl = Hobo.objectElementFor(el)
            Hobo.showSpinner('Removing');
            function complete() {
                if (options.fade) { Hobo.fadeObjectElement(el) }
                Hobo.hideSpinner()
            }
            if (updates && updates.length > 0) {
                new Hobo.ajaxRequest(url, updates, { method:'delete', message: "Removing...", onComplete: complete});
            } else {
                var ajaxOptions = {asynchronous:true, evalScripts:true, method:'delete', onComplete: complete}
                if (typeof(formAuthToken) != "undefined") {
                    ajaxOptions.parameters = formAuthToken.name + "=" + formAuthToken.value
                }
                new Ajax.Request(url, ajaxOptions);
            }
        }
    },


    ajaxUpdateField: function(element, field, value, updates) {
        var objectElement = Hobo.objectElementFor(element)
        var url = Hobo.putUrl(objectElement)
        var spec = Hobo.parseFieldId(objectElement)
        var params = spec.name + '[' + field + ']=' + encodeURIComponent(value)
        new Hobo.ajaxRequest(url, updates, { method:'put', message: "Saving...", params: params });
    },


    showEmptyMessageAfterLastRemove: function(el) {
        var empty
        var container = $(el.parentNode)
        if (container.getElementsByTagName(el.nodeName).length == 1 &&
            (empty = container.next('.empty-collection-message'))) {
            new Effect.Appear(empty, {delay:0.3})
        }
    },


    parseFieldId: function(el) {
        id = el.getAttribute("hobo-model-id")
        return id && Hobo.parseId(id)
    },


    parseId: function(id) {
        m = id.match(/^([a-z_]+)_([0-9]+)(?:_([a-z_]+))?$/)
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
            id = el.getAttribute("hobo-model-id");
            if (id) m = id.match(/^([a-z_]+)_([0-9]+)(_[a-z0-9_]*)?$/);
            if (m) break;
            el = el.parentNode;
        }
        if (m) return el;
    },

    modelIdFor: function(el) {
        var e = Hobo.objectElementFor(el)
        return e && e.getAttribute("hobo-model-id");
    },


    showSpinner: function(message, nextTo) {
        clearTimeout(Hobo.spinnerTimer)
        Hobo.spinnerHideAt = new Date().getTime() + Hobo.spinnerMinTime;
        if(t = $('ajax-progress-text')) Element.update(t, message);
        if(e = $('ajax-progress')) {
            if (nextTo) {
                var pos = $(nextTo).cumulativeOffset()
                e.style.top = pos.top + "px"
                e.style.left = (pos.left + nextTo.offsetWidth) + "px"
            }
            e.style.display = "block";
        }
    },


    hideSpinner: function() {
        if (e = $('ajax-progress')) {
            var remainingTime = Hobo.spinnerHideAt - new Date().getTime()
            if (remainingTime <= 0) {
                e.visualEffect('Fade')
            } else {
                Hobo.spinnerTimer = setTimeout(function () { e.visualEffect('Fade') }, remainingTime)
            }
        }
    },


    updateElement: function(id, content) {
        Element.update(id, content)
        Hobo.applyEvents(id)
    },

    getStyle: function(el, styleProp) {
        if (el.currentStyle)
            var y = el.currentStyle[styleProp];
        else if (window.getComputedStyle)
            var y = document.defaultView.getComputedStyle(el, null).getPropertyValue(styleProp);
        return y;
    },

    partFor: function(el) {
        while (el) {
            if (el.id && hoboParts[el.id]) { return el }
            el = el.parentNode
        }
        return null
    },

    pluralise: function(s) {
        return pluralisations[s] || s + "s"
    },

    addUrlParams: function(params, options) {
        params = $H(window.location.search.toQueryParams()).merge(params)

        if (options.remove) {
            var remove = (options.remove instanceof Array) ? options.remove : [options.remove]
            remove.each(function(k) { params.unset(k) })
        }

        return window.location.href.sub(/(\?.*|$)/, "?" + params.toQueryString())
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

// Add an afterEnterEditMode hook to in-place-editor
origEnterEditMode = Ajax.InPlaceEditor.prototype.enterEditMode
Ajax.InPlaceEditor.prototype.enterEditMode = function(evt) {
    origEnterEditMode.bind(this)(evt)
    if (this.afterEnterEditMode) this.afterEnterEditMode()
    return false
}

// Fix Safari in-place-editor bug
Ajax.InPlaceEditor.prototype.removeForm = function() {
    if (!this._form) return;
    
    if (this._form.parentNode) { try { Element.remove(this._form); } catch (e) {}}    
    this._form = null;
    this._controls = { };
}

// Silence errors from IE :-(
Field.scrollFreeActivate = function(field) {
  setTimeout(function() {
      try {
          Field.activate(field);
      } catch(e) {}
  }, 1);
}


Element.Methods.$$ = function(e, css) {
    return new Selector(css).findElements(e)
}

// --- has_many_through_input --- //

SelectManyInput = Behavior.create({

    initialize : function() {
        // onchange doesn't bubble in IE6 so...
        Event.observe(this.element.down('select'), 'change', this.addOne.bind(this))
    },

    addOne : function() {
        var select = this.element.down('select') 
        var selected = select.options[select.selectedIndex]
        if (selected.value != "") {
            var newItem = $(DOM.Builder.fromHTML(this.element.down('.item-proto').innerHTML.strip()))
            this.element.down('.items').appendChild(newItem);
            newItem.down('span').innerHTML = selected.innerHTML
            this.itemAdded(newItem, selected)
            selected.disabled = true
            select.value = ""
            Event.addBehavior.reload()
        }
    },

    onclick : function(e) {
        var el = Event.element(e);
        Event.stop(e);
        if (el.match(".remove-item")) { this.removeOne(el.parentNode) }
    },

    removeOne : function(el) {
        new Effect.BlindUp(el, 
                           { duration: 0.3,
                             afterFinish: function (ef) { ef.element.remove() } } ) 
        var label = el.down('span').innerHTML
        var option = $A(this.element.getElementsByTagName('option')).find(function(o) { return o.innerHTML == label })
	option.disabled = false
    },

    itemAdded: function(item, option) {
        this.hiddenField(item).value = option.innerHTML
    },

    hiddenField: function(item) {
        return item.down('input[type=hidden]') 
        //return item.getElementsByClassName("hidden-field")[0]
    }


})

NameManyInput = Object.extend(SelectManyInput, {
    addOne : function() {
        var select = this.element.down('select') 
        var selected = select.options[select.selectedIndex]
        if (selected.value != "") {
            var newItem = $(DOM.Builder.fromHTML(this.element.down('.item-proto').innerHTML.strip()))
            this.element.down('.items').appendChild(newItem);
            newItem.down('span').innerHTML = selected.innerHTML
            this.itemAdded(newItem, selected)
            selected.disabled = true
            select.value = ""
            Event.addBehavior.reload()
        }
    }
})

                              
AutocompleteBehavior = Behavior.create({
    initialize : function() {
        var target    = this.element.className.match(/complete-on:([\S]+)/)[1].split(':')
        var model     = target[0]
        var completer = target[1]

        var spec = Hobo.parseId(model)
        var url = urlBase + "/" + Hobo.pluralise(spec.name) +  "/complete_" + completer
        var parameters = spec.id ? "id=" + spec.id : ""
        new Ajax.Autocompleter(this.element, 
                               this.element.next('.completions-popup'), 
                               url, 
                               {paramName:'query', method:'get', parameters: parameters});
    }
})



Event.addBehavior({

    'textarea.html' : function(e) {
        if (typeof(nicEditors) != "undefined") {
            Hobo.makeNicEditor(this)
        }
    },

    'div.select-many.input' : SelectManyInput(),

    '.association-count:click' : function(e) {
	new Effect.ScrollTo('primary-collection', {duration: 1.0, offset: -20, transition: Effect.Transitions.sinoidal});
	Event.stop(e);
    },

    'form.filter-menu select:change': function(event) {
        var paramName = this.up('form').down('input[type=hidden]').value.gsub("-", "_")
        var params = {}
        var remove = [ 'page' ]
	if ($F(this) == '') { 
            remove.push(paramName)
        } else {
            params[paramName] = $F(this)
	}
	location.href = Hobo.addUrlParams(params, {remove: remove})
    },

    '.autocompleter' : AutocompleteBehavior()


});
