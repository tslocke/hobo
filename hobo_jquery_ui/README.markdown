This plugin provides the jQuery UI widgets in a Hobo friendly manner.

### Usage

The jQuery UI tags support all of the [options that the corresponding jQuery UI widgets provide](http://docs.jquery.com/UI).  For example:

    <datepicker dateFormat="yy-mm-dd" />

Options that expect a type other than string can be provided by passing a ruby object:

    <datepicker dayNamesMin="&['Di', 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa']" />

Events are also supported.  Pass in a global Javascript function name:

    <datepicker onSelect="hjq.util.log" />


### Installation

    hobo generate install_plugin hobo_jquery_ui git://github.com/tablatom/hobo
