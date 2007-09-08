LowPro = {};
LowPro.Version = '0.4.1';

if (!Element.addMethods) 
  Element.addMethods = function(o) { Object.extend(Element.Methods, o) };

// Simple utility methods for working with the DOM
DOM = {
  insertAfter : function(element, node, otherNode) {
    element = $(element);
    if (otherNode.nextSibling)
      return element.insertBefore(node, otherNode.nextSibling);
    else
      return element.appendChild(node);
  },
  addBefore : function(element, node) {
    element = $(element);
    return element.parentNode.insertBefore(node, element);
  },
  addAfter : function(element, node) {
    element = $(element);
    return $(element.parentNode).insertAfter(node, element);
  },
  replaceElement : function(element, node) {
    $(element).parentNode.replaceChild(node, element);
    return node;
  },
  prependChild : function(element, node) {
    $(element).insertBefore(node, element.firstChild);
  },
  appendChildren : function(element, children) {
    element = $(element);
    if (!(children instanceof Array))
      children = Array.prototype.slice.call(arguments, 1);
    children.each(function(child) { element.appendChild(child) });
    return children;
  }
};

// Add them to the element mixin
Element.addMethods(DOM);

// DOMBuilder for prototype
DOM.Builder = {
  IE_TRANSLATIONS : {
    'class' : 'className',
    'for' : 'htmlFor'
  },
  cache: {},
  ieAttrSet : function(attrs, attr, el) {
    var trans;
    if (trans = this.IE_TRANSLATIONS[attr]) el[trans] = attrs[attr];
    else if (attr == 'style') el.style.cssText = attrs[attr];
    else if (attr.match(/^on/)) el[attr] = new Function(attrs[attr]);
    else el.setAttribute(attr, attrs[attr]);
  },
  getElement : function(tag) {
    var element = DOM.Builder.cache[tag];
    if (element == null) 
      element = DOM.Builder.cache[tag] = document.createElement(tag);
    return element.cloneNode(false);
  },
	tagFunc : function(tag) {
	  return function() {
	    var attrs, children; 
	    if (arguments.length>0) { 
	      if (arguments[0].nodeName || 
	        typeof arguments[0] == "string") 
	        children = arguments; 
	      else { 
	        attrs = arguments[0]; 
	        children = Array.prototype.slice.call(arguments, 1); 
	      };
	    }
	    return DOM.Builder.create(tag, attrs, children);
	  };
  },
	create : function(tag, attrs, children) {
		attrs = attrs || {}; children = children || []; tag = tag.toLowerCase();
		var isIE = navigator.userAgent.match(/MSIE/);
		var el = (isIE && attrs.name) ? 
		  document.createElement("<" + tag + " name=" + attrs.name + ">") : 
		  DOM.Builder.getElement(tag);
		
		for (var attr in attrs) {
		  if (attrs[attr] === true) attrs[attr] = attr;
		  if (typeof attrs[attr] != 'function') {
		    if (isIE) this.ieAttrSet(attrs, attr, el);
		    else el.setAttribute(attr, attrs[attr].toString());
		  } else if (attr.match(/^on(.+)$/)) {
		    Event.observe(el, RegExp.$1, attrs[attr]);
		  };
	  }
	  
		for (var i=0; i<children.length; i++) {
			if (typeof children[i] == 'string') 
			  children[i] = document.createTextNode(children[i]);
			el.appendChild(children[i]);
		}
		return $(el);
	}
};

// Automatically create node builders as $tagName.
(function() { 
	var els = ("p|div|span|strong|em|img|table|tr|td|th|thead|tbody|tfoot|pre|code|" + 
				     "h1|h2|h3|h4|h5|h6|ul|ol|li|form|input|textarea|legend|fieldset|" + 
				     "select|option|blockquote|cite|br|hr|dd|dl|dt|address|a|button|abbr|acronym|" +
				     "script|link|style|bdo|ins|del|object|param|col|colgroup|optgroup|caption|" + 
				     "label|dfn|kbd|samp|var").split("|");
  var el, i=0;
	while (el = els[i++]) 
	  window['$' + el] = DOM.Builder.tagFunc(el);
})();

DOM.Builder.fromHTML = function(html) {
  var root;
  if (!(root = arguments.callee._root))
    root = arguments.callee._root = document.createElement('div');
  root.innerHTML = html;
  return root.childNodes[0];
};

String.prototype.toElement = function() {
  return DOM.Builder.fromHTML(this);
};

(function() {
  var old$ = $;
  $ = function(element) {
    if (element && element.toElement && element.match(/^<(.+)>$/)) 
      return $(element.toElement());
    return old$.apply(this, arguments);
  }
})();



// Adapted from DOM Ready extension by Dan Webb
// http://www.vivabit.com/bollocks/2006/06/21/a-dom-ready-extension-for-prototype
// which was based on work by Matthias Miller, Dean Edwards and John Resig
//
// Usage:
//
// Event.onReady(callbackFunction);
Object.extend(Event, {
  _domReady : function() {
    if (arguments.callee.done) return;
    arguments.callee.done = true;

    if (Event._timer)  clearInterval(Event._timer);
    
    Event._readyCallbacks.each(function(f) { f() });
    Event._readyCallbacks = null;
    
  },
  onReady : function(f) {
    if (!this._readyCallbacks) {
      var domReady = this._domReady;
      
      if (domReady.done) return f();
      
      if (document.addEventListener)
        document.addEventListener("DOMContentLoaded", domReady, false);
        
        /*@cc_on @*/
        /*@if (@_win32)
            var dummy = location.protocol == "https:" ?  "https://javascript:void(0)" : "javascript:void(0)";
            document.write("<script id=__ie_onload defer src='" + dummy + "'><\/script>");
            document.getElementById("__ie_onload").onreadystatechange = function() {
                if (this.readyState == "complete") { domReady(); }
            };
        /*@end @*/
        
        if (/WebKit/i.test(navigator.userAgent)) { 
          this._timer = setInterval(function() {
            if (/loaded|complete/.test(document.readyState)) domReady(); 
          }, 10);
        }
        
        Event.observe(window, 'load', domReady);
        Event._readyCallbacks =  [];
    }
    Event._readyCallbacks.push(f);
  }
});

// Extend Element with observe and stopObserving.
if (typeof Element.Methods.observe == 'undefined') Element.addMethods({
  observe : function(el, event, callback) {
    Event.observe(el, event, callback);
  },
  stopObserving : function(el, event, callback) {
    Event.stopObserving(el, event, callback);
  }
});

// Replace out existing event observe code with Dean Edwards' addEvent
// http://dean.edwards.name/weblog/2005/10/add-event/
Object.extend(Event, {
  _observeAndCache : function(el, type, func) {
    if (!func.$$guid) func.$$guid = Event._guid++;
  	if (!el.events) el.events = {};
  	var handlers = el.events[type];
  	if (!handlers) {
  		handlers = el.events[type] = {};
  		if (el["on" + type]) {
  			handlers[0] = el["on" + type];
  		}
  	}
  	handlers[func.$$guid] = func;
  	el["on" + type] = Event._handleEvent;
  	
  	if (!Event.observers) Event.observers = [];
  	Event.observers.push([el, type, func, false]);
	},
	stopObserving : function(el, type, func) {
	  el = $(el);
    if (el.events && el.events[type]) delete el.events[type][func.$$guid];
    
    for (var i = 0; i < Event.observers.length; i++) {
      if (Event.observers[i] &&
          Event.observers[i][0] == el && 
          Event.observers[i][1] == type && 
          Event.observers[i][2] == func) delete Event.observers[i];
    }
  },
  _handleEvent : function(e) {
    var returnValue = true;
    e = e || Event._fixEvent(window.event);
    var handlers = this.events[e.type], el = $(this);
    for (var i in handlers) {
    	el.$$handleEvent = handlers[i];
    	if (el.$$handleEvent(e) === false) returnValue = false;
    }
    if (returnValue == false) e.preventDefault();
  	return returnValue;
  },
  _fixEvent : function(e) {
    e.preventDefault = Event._preventDefault;
    e.stopPropagation = Event._stopPropagation;
    return e;
  },
  _preventDefault : function() { this.returnValue = false },
  _stopPropagation : function() { this.cancelBubble = true },
  _guid : 1
});

// Allows you to trigger an event element.  
Object.extend(Event, {
  trigger : function(element, event, fakeEvent) {
    element = $(element);
    fakeEvent = fakeEvent || { type :  event };
    if(element.events && element.events[event]) { 	
      $H(element.events[event]).each(function(cache) {
        cache[1].call(element, fakeEvent);
    	});
    }
  }
});

// Based on event:Selectors by Justin Palmer
// http://encytemedia.com/event-selectors/
//
// Usage:
//
// Event.addBehavior({
//      "selector:event" : function(event) { /* event handler.  this refers to the element. */ },
//      "selector" : function() { /* runs function on dom ready.  this refers to the element. */ }
//      ...
// });
//
// Multiple calls will add to exisiting rules.  Event.addBehavior.reassignAfterAjax and
// Event.addBehavior.autoTrigger can be adjusted to needs.
Event.addBehavior = function(rules) {
  var ab = this.addBehavior;
  Object.extend(ab.rules, rules);
  
  if (!ab.responderApplied) {
    Ajax.Responders.register({
      onComplete : function() { 
        if (Event.addBehavior.reassignAfterAjax) 
          setTimeout(function() { ab.unload(); ab.load(ab.rules) }, 10);
      }
    });
    ab.responderApplied = true;
  }
  
  if (ab.autoTrigger) {
    this.onReady(ab.load.bind(ab, rules));
  }
  
};

Object.extend(Event.addBehavior, {
  rules : {}, cache : [],
  reassignAfterAjax : true,
  autoTrigger : true,
  
  load : function(rules) {
    for (var selector in rules) {
      var observer = rules[selector];
      var sels = selector.split(',');
      sels.each(function(sel) {
        var parts = sel.split(/:(?=[a-z]+$)/), css = parts[0], event = parts[1];
        $$(css).each(function(element) {
          if (event) {
            $(element).observe(event, observer);
            Event.addBehavior.cache.push([element, event, observer]);
          } else {
            if (!element.$$assigned || !element.$$assigned.include(observer)) {
              if (observer.attach) observer.attach(element);
              
              else observer.call($(element));
              element.$$assigned = element.$$assigned || [];
              element.$$assigned.push(observer);
            }
          }
        });
      });
    }
  },
  
  unload : function() {
    this.cache.each(function(c) {
      Event.stopObserving.apply(Event, c);
    });
    this.cache = [];
  }
  
});

Event.observe(window, 'unload', Event.addBehavior.unload.bind(Event.addBehavior));

// A silly Prototype style shortcut for the reckless
$$$ = Event.addBehavior;

// Behaviors can be bound to elements to provide an object orientated way of controlling elements
// and their behavior.  Use Behavior.create() to make a new behavior class then use attach() to
// glue it to an element.  Each element then gets it's own instance of the behavior and any
// methods called onxxx are bound to the relevent event.
// 
// Usage:
// 
// var MyBehavior = Behavior.create({
//   onmouseover : function() { this.element.addClassName('bong') } 
// });
//
// Event.addBehavior({ 'a.rollover' : MyBehavior });
// 
// If you need to pass additional values to initialize use:
//
// Event.addBehavior({ 'a.rollover' : MyBehavior(10, { thing : 15 }) })
//
// You can also use the attach() method.  If you specify extra arguments to attach they get passed to initialize.
//
// MyBehavior.attach(el, values, to, init);
//
// Finally, the rawest method is using the new constructor normally:
// var draggable = new Draggable(element, init, vals);
//
// Each behaviour has a collection of all its instances in Behavior.instances
//
Behavior = {
  create : function(members) {
    var behavior = function() { 
      var behavior = arguments.callee;
      if (this == window || $H(this).values().include(behavior)) {
        var args = [];
        for (var i = 0; i < arguments.length; i++) 
          args.push(arguments[i]);
          
        return function() {
          var initArgs = [this].concat(args);
          behavior.attach.apply(behavior, initArgs);
        };
      } else {
        var args = (arguments.length == 2 && arguments[1] instanceof Array) ? 
                    arguments[1] : Array.prototype.slice.call(arguments, 1);

        this.element = $(arguments[0]);
        this.initialize.apply(this, args);
        behavior._bindEvents(this);
        behavior.instances.push(this);
      }
    };
    behavior.prototype.initialize = Prototype.K;
    Object.extend(behavior.prototype, members);
    Object.extend(behavior, Behavior.ClassMethods);
    behavior.instances = [];
    return behavior;
  },
  ClassMethods : {
    attach : function(element) {
      return new this(element, Array.prototype.slice.call(arguments, 1));
    },
    _bindEvents : function(bound) {
      for (var member in bound)
        if (member.match(/^on(.+)/) && typeof bound[member] == 'function')
          bound.element.observe(RegExp.$1, bound[member].bindAsEventListener(bound));
    }
  }
};


