Event.addBehavior({
    'body:click' : function(event) {
        if (event.shiftKey && event.altKey) {
            Dryml.click(event)
            Event.stop(event)
        }
    }
})


var Dryml = {

    menu: null,
    event: null,

    click: function(event) {
        Dryml.event = event
        Dryml.showSourceMenu(event.target)
    },

    showSourceMenu: function(element) {
        var stack = Dryml.getSrcInfoStack(element)
        Dryml.showMenu(stack)
    },

    getSrcInfoStack: function(element) {
        var stack = $A()
        while(element != document.documentElement) {
            var el = Dryml.findPrecedingDrymlInfo(element)
            if (el == null) {
                element = element.parentNode
            } else {
                element = el
                var info = Dryml.getDrymlInfo(element)
                stack.push(info)
            }
        }
        return stack
    },

    findPrecedingDrymlInfo: function(element) {
        var ignoreCount = 0
        var el = element
        while (el = el.previousSibling) {
            if (Dryml.isDrymlInfo(el)) {
                if (ignoreCount > 0)
                    ignoreCount -= 1;
                else
                    return el
            } else if (Dryml.isDrymlInfoClose(el)) {
                ignoreCount += 1
            }
        }
        return null
    },

    getDrymlInfo: function(el) {
        var parts = el.nodeValue.sub(/^\[DRYML\|/, "").sub(/\[$/, "").split("|")
        return { kind: parts[0], tag: parts[1], line: parts[2], file: parts[3] }
    },

    isDrymlInfo: function(el) {
        return el.nodeType == Node.COMMENT_NODE && el.nodeValue.match(/^\[DRYML/)
    },

    isDrymlInfoClose: function(el) {
        return el.nodeType == Node.COMMENT_NODE && el.nodeValue == "]DRYML]"
    },

    showMenu: function(stack) {
        Dryml.removeMenu()

        var style = $style({id: "dryml-menu-style"},
                           "#dryml-src-menu         { position: fixed; margin: 10px; padding: 10px; background: black; color: white; border: 1px solid white; }\n",
                           "#dryml-src-menu a       { color: white; text-decoration: none; border: none; }\n",
                           "#dryml-src-menu td      { padding: 2px 7px; }\n",
                           "#dryml-src-menu a:hover { background: black; color: white; text-decoration: none; border: none; }\n")
        $$("head")[0].appendChild(style)

        var items = stack.map(Dryml.makeMenuItem)

        var closer = $a({href:"#"}, "[close]")
        closer.onclick = Dryml.removeMenu
        Dryml.menu = $div({id:    "dryml-src-menu",
                           style: "position: fixed; margin: 10px; padding: 10px; background: black; color: #cfc; border: 1px solid white;"
                          },
                          closer,
                          $table(items))

        document.body.appendChild(Dryml.menu)
        Dryml.menu.style.top  = "20px"//Dryml.event.clientY + "px"
        Dryml.menu.style.left = "20px"//Dryml.event.clientX + "px"
    },

    editSourceFile: function(path, line) {
        new Ajax.Request("/dryml/edit_source?file=" + path + "&line=" + line)
    },


    makeMenuItem: function(item) {
        var text
        switch (item.kind) {
        case "call":
            text = "<" + item.tag + ">"
            break
        case "param":
            text = "<" + item.tag + ":>"
            break
        case "replace":
            text = "<" + item.tag + ": replace>"
            break
        case "def":
            text = "<def " + item.tag + ">"
            break
        }
        var a = $a({href:"#"}, text)
        a.onclick = function() { Dryml.editSourceFile(item.file, item.line); return false }

        var filename = item.file.sub("vendor/plugins", "").sub("app/views", "").sub(/^\/+/, "").sub(".dryml", "")

        return $tr($td({"class": "file"}, filename), $td(a))
    },

    removeMenu: function() {
        if (Dryml.menu) {
            $("dryml-menu-style").remove()
            Dryml.menu.remove()
            Dryml.menu = null
        }
    }

}
