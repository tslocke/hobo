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
    spinnerMinTime: 500, // milliseconds 

    uid: function() {
        Hobo.uidCounter += 1
        return "uid" + Hobo.uidCounter
    },

    updatesForElement: function(el) {
        el = $(el)
        var updates = Hobo.getClassData(el, 'update')
        return updates ? updates.split(':') : []
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

        if (options.message != false) Hobo.showSpinner(options.message, options.spinnerNextTo)
        
        var complete = function() {
            if (options.message != false) Hobo.hideSpinner();
            if (options.onComplete) options.onComplete.apply(this, arguments)
            if (form && options.refocusForm) Form.focusFirstElement(form)
            Event.addBehavior.reload()
        }
        var success = function() {
            if (options.onSuccess) options.onSuccess.apply(this, arguments)
            if (form && options.resetForm) form.reset();            
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

        new Ajax.Request(url, Object.merge(options, { parameters: params.join("&"), onComplete: complete, onSuccess: success }))
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

        var modelId = Hobo.getModelId(el)
        if (oldValue) {
            $$(".model:" + modelId).each(function(e) {
                if (e != el && e.innerHTML == oldValue) e.update(newValue)
            })
        }
    },

    _makeInPlaceEditor: function(el, options) {
        var old
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
                    onFailure: function(_, resp) {
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


    doSearch: function(el) {
        el = $(el)
        var spinner = $(el.getAttribute("search-spinner") || "search-spinner")
        var search_results = $(el.getAttribute("search-results") || "search-results")
        var search_results_panel = $(el.getAttribute("search-results-panel") || "search-results-panel")
        var url = el.getAttribute("search-url") || (urlBase + "/search")

        var clear = function() { Hobo.hide(search_results_panel); el.clear() }

        // Close window on [Escape]
        Event.observe(el, 'keypress', function(ev) { 
            if (ev.keyCode == 27) clear()
        });

        Event.observe(search_results_panel.down('.close-button'), 'click', clear)

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
                                                    method: "get",
                                                    parameters:"query=" + value });
        } else {
            Hobo.updateElement(search_results, '')
            Hobo.hide(search_results_panel)
        }
    },


    putUrl: function(el) {
        var spec = Hobo.modelSpecForElement(el)
        return urlBase + "/" + Hobo.pluralise(spec.name) + "/" + spec.id + "?_method=PUT"
    },

    
    urlForId: function(id) {
        var spec = Hobo.parseModelSpec(id)
        var url = urlBase + "/" + Hobo.pluralise(spec.name)
        if (spec.id) { url += "/" + spec.id }
        return url
    },

        
    fieldSetParam: function(el, val) {
        var spec = Hobo.modelSpecForElement(el)
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
                if (options.fade) { Hobo.fadeObjectElement(objEl) }
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
        var spec = Hobo.modelSpecForElement(objectElement)
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
    

    getClassData: function(el, name) {
        var match = el.className.match(new RegExp("(^| )" + name + "::(\\S+)($| )"))
        return match && match[2]
    },
    

    getModelId: function(el) {
        return Hobo.getClassData(el, 'model')
    },


    modelSpecForElement: function(el) {
        var id = Hobo.getModelId(el)
        return id && Hobo.parseModelSpec(id)
    },


    parseModelSpec: function(id) {
        m = id.gsub('-', '_').match(/^([^:]+)(?::([^:]+)(?::([^:]+))?)?$/)
        if (m) return { name: m[1], id: m[2], field: m[3] }
    },


    objectElementFor: function(el) {
        var m
        while(el.getAttribute) {
            id = Hobo.getModelId(el)
            if (id) m = id.match(/^[^:]+:[^:]+$/);
            if (m) break;
            el = el.parentNode;
        }
        if (m) return el;
    },

    modelIdFor: function(el) {
        var e = Hobo.objectElementFor(el)
        return e && Hobo.getModelId(e)
    },


    showSpinner: function(message, nextTo) {
        clearTimeout(Hobo.spinnerTimer)
        Hobo.spinnerHideAt = new Date().getTime() + Hobo.spinnerMinTime;
        if (t = $('ajax-progress-text')) {
            if (!message || message.length == 0) {
                t.hide()
            } else {
                Element.update(t, message);
                t.show()
            }
        }
        if (e = $('ajax-progress')) {
            if (nextTo) {
                var e_nextTo = $(nextTo);
                var pos = e_nextTo.cumulativeOffset()
                e.style.top = pos.top - e_nextTo.offsetHeight + "px"
                e.style.left = (pos.left + e_nextTo.offsetWidth + 5) + "px"
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
        // TODO: Do we need this method?
        Element.update(id, content)
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
    },
    
    
    fixSectionGroup: function(e) {
	    rows = e.childElements().map(function(e, i) {
    	    cells = e.childElements().map(function(e, i) {
        	    return e.outerHTML.sub("<DIV", "<td  valign='top'").sub(/<\/DIV>$/i, "</td>")
            }).join('')

            var attrs = e.outerHTML.match(/<DIV([^>]+)/)[1]
            return "<tr" + attrs + ">" + cells + "</tr>"
	    }).join("\n")

        var attrs = e.outerHTML.match(/<DIV([^>]+)/)[1]

	    var table= "<table cellpadding='0' cellspacing='0' border='0' style='border-collapse: collapse; border-spacing: 0'" + attrs + ">" + 
	               rows + "</table>"
	    e.outerHTML = table
    },

    makeHtmlEditor: function(textarea) {
        // do nothing - plugins can overwrite this method
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


HoboBehavior = Class.create({
    
    initialize: function(mainSelector, features) {
        this.mainSelector = mainSelector
        this.features = features
        this.addEvents(mainSelector, features.events)
    },
    
    addEvents: function(parentSelector, events) {
        var self = this
        
        for (selector in events) {
            fullSelector = parentSelector + ' ' + selector
            var rhs = events[selector]
            if (Object.isString(rhs)) {
                this.addBehavior(fullSelector, this.features[rhs])
            } else {
                this.addEvents(fullSelector, rhs)
            }
        }
        
    },
    
    addBehavior: function(selector, handler) {
        var self = this
        behavior = {}
        behavior[selector] = function(ev) {
            self.features.element = this.up(self.mainSelector)
            handler.call(self.features, ev, this)
        }
        Event.addBehavior(behavior)
    }
    
})


new HoboBehavior("ul.input-many", {
  
  events: {
      "> li > div.buttons": {
          ".add-item:click":    'addOne',
          ".remove-item:click": 'removeOne'
      }
  },
  
  addOne: function(ev, el) {
      Event.stop(ev)
      var ul = el.up('ul'), li = el.up('li')
      
      var thisItem = li.down('div.input-many-item')
      var newItem = "<li style='display:none'><div class='input-many-item'>" + 
                    thisItem.innerHTML + 
                    "</div>" + 
                    "<div class='buttons' />" +
                    "</div></li>"
      var newItem = DOM.Builder.fromHTML(newItem)
      ul.appendChild(newItem);
      this.clearInputs(newItem);
      
      this.updateButtons()
      this.updateInputNames()
      
      ul.fire("rapid:add", { element: newItem })
      ul.fire("rapid:change", { element: newItem })
      
      new Effect.BlindDown(newItem, {duration: 0.3})
  },
  
  removeOne: function(ev, el) {
      Event.stop(ev)
      var self = this;
      var ul = el.up('ul'), li = el.up('li')
      if (li.parentNode.childElements().length == 1) {
          // It's the last one - don't remove it, just clear it
          this.clearInputs(li)
      } else {      
          new Effect.BlindUp(li, { duration: 0.3, afterFinish: function (ef) {
              li.remove() 
              self.updateButtons()
              self.updateInputNames()
          } });
      }
      ul.fire("rapid:remove")
      ul.fire("rapid:change")
  },

  
  clearInputs: function(item) {
      $(item).select('input,select,textarea').each(function(input){
          t = input.getAttribute('type')
          if (t && t.match(/hidden/i)) {
              input.remove()
          } else {
              input.value = ""
          }
      })
  },
   
  updateButtons: function() {
      var removeButton = "<button class='remove-item'>-</button>"
      var addButton    = "<button class='add-item'>+</button>"

      var ul = this.element
      var children = ul.childElements();
      // assumption: only get here after add or remove, so only second last button needs the "+" removed
      if(children.length > 1) {
          // cannot use .down() because that's a depth-first search.  Did I mention that I hate Prototype?
          children[children.length-2].childElements().last().innerHTML = removeButton;
      }
      if(children.length > 0) {
          children[children.length-1].childElements().last().innerHTML = removeButton + ' ' + addButton;
      }
      Event.addBehavior.reload()
  },
  
  updateInputNames: function() {
      var prefix = Hobo.getClassData(this.element, 'input-many-prefix')
      
      this.element.selectChildren('li').each(function(li, index) {
          li.select('*[name]').each(function(control) {
              if(control.name) {
                  var changeId = control.id == control.name;
                  control.name   = control.name.sub(new RegExp("^" + RegExp.escape(prefix) + "\[[0-9]+\]"), prefix + '[' + index +']');
                  if (changeId) control.id = control.name;
              }
          })
      })
  }
  
})


SelectManyInput = Behavior.create({

    initialize : function() {
        // onchange doesn't bubble in IE6 so...
        Event.observe(this.element.down('select'), 'change', this.addOne.bind(this))
    },

    addOne : function() {
        var select = this.element.down('select') 
        var selected = select.options[select.selectedIndex]
        if ($F(select) != "") {
            var newItem = $(DOM.Builder.fromHTML(this.element.down('.item-proto').innerHTML.strip()))
            this.element.down('.items').appendChild(newItem);
            newItem.down('span').innerHTML = selected.innerHTML
            this.itemAdded(newItem, selected)
            var optgroup = new Element("optgroup", {alt:selected.value, label:selected.text})
            optgroup.addClassName("disabled-option")
            selected.replace(optgroup)
            select.value = ""
            Event.addBehavior.reload()
            this.element.fire("rapid:add", { element: newItem })
            this.element.fire("rapid:change", { element: newItem })
        }
    },

    onclick : function(ev) {
        var el = Event.element(ev);
        if (el.match(".remove-item")) { this.removeOne(el.parentNode) }
    },

    removeOne : function(el) {
        var element = this.element
        new Effect.BlindUp(el, 
                           { duration: 0.3,
                             afterFinish: function (ef) { 
                                 ef.element.remove() 
                                 element.fire("rapid:remove", { element: el })
                                 element.fire("rapid:change", { element: el })
                                 } } ) 
        var label = el.down('span').innerHTML
        var optgroup = element.down("optgroup[label="+label+"]")
        var option = new Element("option", {value:optgroup.readAttribute("alt")})
        option.innerHTML = optgroup.readAttribute("label")
        optgroup.replace(option)
    },

    itemAdded: function(item, option) {
        this.hiddenField(item).value = option.value
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
        var match     = this.element.className.match(/complete-on::([\S]+)/)
        var target    = match[1].split('::')
        var typedId   = target[0]
        var completer = target[1]

        var spec = Hobo.parseModelSpec(typedId)
        var url = urlBase + "/" + Hobo.pluralise(spec.name) +  "/complete_" + completer
        var parameters = spec.id ? "id=" + spec.id : ""
        new Ajax.Autocompleter(this.element, 
                               this.element.next('.completions-popup'), 
                               url, 
                               {paramName:'query', method:'get', parameters: parameters});
    }
})



Event.addBehavior.reassignAfterAjax = true;
Event.addBehavior({
    
    'div.section-group' : function() {
        if (Prototype.Browser.IE) Hobo.fixSectionGroup(this);
    },

    'div.select-many.input' : SelectManyInput(),

    'textarea.html' : function() {
        Hobo.makeHtmlEditor(this)
    },

    'form.filter-menu select:change': function(event) {
        var paramName = this.getAttribute('name')
        var params = {}
        var remove = [ 'page' ]
	    if ($F(this) == '') { 
            remove.push(paramName)
        } else {
            params[paramName] = $F(this)
	    }
	    location.href = Hobo.addUrlParams(params, {remove: remove})
    },

    '.autocompleter' : AutocompleteBehavior(),

    '.string.in-place-edit, .datetime.in-place-edit, .date.in-place-edit, .integer.in-place-edit, .float.in-place-edit, .decimal.in-place-edit' :
     function (ev) {

         var ipe = Hobo._makeInPlaceEditor(this)
         ipe.getText = function() {
             return this.element.innerHTML.gsub(/<br\s*\/?>/, "\n").unescapeHTML()
         }
    },

    '.text.in-place-edit, .markdown.in-place-edit, .textile.in-place-edit' : function (ev) {
        var ipe = Hobo._makeInPlaceEditor(this, {rows: 2})
        ipe.getText = function() {
            return this.element.innerHTML.gsub(/<br\s*\/?>/, "\n").unescapeHTML()
        }
    },

    ".html.in-place-edit" : function (ev) {
        if (Hobo.makeInPlaceHtmlEditor) {
            Hobo.makeInPlaceHtmlEditor(this)
        } else {
            var options = { 
                rows: 2, handleLineBreaks: false, okButton: true, cancelLink: true, okText: "Save", submitOnBlur: false
            }
            var ipe = Hobo._makeInPlaceEditor(this, options) 
        }
    },

    "select.integer.editor" : function(e) {
        var el = this
        el.onchange = function() {
            Hobo.ajaxSetFieldForElement(el, $F(el))
        }
    },
                                            
    "input.live-search[type=search]" : function(e) {
        var element = this
        new Form.Element.Observer(element, 1.0, function() { Hobo.doSearch(element) })
    }


});

ElementSet = Class.create(Enumerable, {
    
    initialize: function(array) {
        this.items = array
    },
    
    _each: function(fn) {
        return this.items.each(fn)
    },
    
    selectChildren: function(selector) {
        return new ElementSet(this.items.invoke('selectChildren', selector).pluck('items').flatten())
    },
    
    child: function(selector) {
        return this.selectChildren(selector).first()
    },
    
    select: function(selector) {
        return new ElementSet(this.items.invoke('select', selector).flatten())
    },

    down: function(selector) {
        for (var i = 0; i < this.items.length; i++) {
            var match = this.items[i].down(selector)
            if (match) return match
        }
        return null
    },
    
    size: function() {
        return this.items.length
    },
    
    first: function() {
        return this.items.first()
    },

    last: function() {
        return this.items.last()
    }
    
})

Element.addMethods({
    selectChildren: function(element, selector) {
        return new ElementSet(Selector.matchElements(element.childElements(), selector))
    }
})
