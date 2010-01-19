# Hobo JQuery

This is a simple Rails plugin that works with
[Hobo](http://hobocentral.net).

It adds a bunch of tags to Hobo that instantiate various [JQuery
UI](http://jqueryui.com) widgets.

## Installing

Install with

    ruby script/plugin install git://github.com/bryanlarsen/hobo-jquery.git

Link jQuery, jQuery-UI, and hobo-jQuery assets into your public directory:

    rake hobo_jquery:link_jquery
    rake hobo_jquery:link_assets

If you're on Windows, you can use the install\_jquery and update\_assets tasks instead.

To use, you need to include hobo-jquery and add the assets to your page.  In your application.dryml:

    <include src="hobo-jquery" plugin="hobo-jquery" />

    <extend tag="page">
      <old-page merge>
        <custom-scripts:>
          <hjq-assets/>
        </custom-scripts>
      </old-page>
    </extend>

To install local documentation:

    git submodule update --init

## Notes

Hobo Jquery calls
[jQuery.noConflict()](http://docs.jquery.com/Core/jQuery.noConflict) 
to avoid conflicts with prototype.  `$` is still bound to
prototype.js.  To use jQuery, use `jQuery` instead of `$`.

## Documentation

[Auto generated documentation on GitHub](http://bryanlarsen.github.com/hobo-jquery/documentation.html).

[Auto generated documentation on HoboCentral](http://cookbook.hobocentral.net/api_taglibs/hobo-jquery).
