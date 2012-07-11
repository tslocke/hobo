// from Blixt @ http://stackoverflow.com/questions/2206958/best-way-to-reference-an-element-with-jquery

jQuery.fn.getPath = function () {
    if (this.length != 1) throw 'Requires one element.';

    if (this.attr("id")) return "#"+this.attr("id");

    var path, node = this;
    while (node.length) {
        var realNode = node[0], name = realNode.localName;
        if (!name) break;
        name = name.toLowerCase();

        var parent = node.parent();

        var siblings = parent.children(name);
        if (siblings.length > 1) {
            name += ':eq(' + siblings.index(realNode) + ')';
        }

        path = name + (path ? '>' + path : '');
        node = parent;
    }

    return path;
};
