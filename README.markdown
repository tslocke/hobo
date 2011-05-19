# Hobo JQuery

This is a simple Rails plugin that works with
[Hobo](http://hobocentral.net).

It adds a bunch of tags to Hobo that instantiate various [JQuery
UI](http://jqueryui.com) widgets.

## Installing

Install with

    rails plugin install git://github.com/bryanlarsen/hobo-jquery.git -r rails3

or add

    gem "hobo-jquery", :git => "git://github.com/bryanlarsen/hobo-jquery.git", :branch => "rails3"

to your Gemfile.

Install the javascript and css files with

    rails generate hobo_jquery:install

To use, you need to include hobo-jquery and add the assets to your page.  In your application.dryml:

if you installed it as a plugin:

    <include plugin="hobo-jquery" />

if you installed it as a gem:

    <include gem="hobo-jquery" />

in both cases you must add also:

    <extend tag="page">
      <old-page merge>
        <custom-scripts:>
          <hjq-assets/>
        </custom-scripts>
      </old-page>
    </extend>

## Notes

Hobo Jquery calls
[jQuery.noConflict()](http://docs.jquery.com/Core/jQuery.noConflict)
to avoid conflicts with prototype.  `$` is still bound to
prototype.js.  To use jQuery, use `jQuery` instead of `$`.

## Documentation

[Auto generated documentation on HoboCentral](http://cookbook.hobocentral.net/api_taglibs/hobo-jquery).
