# Installing

Modify or add the following lines in your Gemfile:

    gem 'hobo', :git => 'git://github.com/tablatom/hobo.git', :branch => 'jquery'
    gem "jquery-rails"
    gem "hobo-jquery", :git => "git://github.com/bryanlarsen/hobo-jquery.git", :branch => "no-prototype"

And then run

    bundle install
    rails generate jquery:install --ui
    rails generate hobo_jquery:install

Add the following to your application.dryml:

    <include gem="hobo-jquery"/>

If you previously had hobo-jquery installed, remove the
`<hjq-assets/>` call you previously added.

## Running the integration tests:

Unfortunately, 2 of the integration tests fails on firefox, which
works out of the box, so we also have to install capybara-webkit and
selenium-chrome.

     $ git clone -b jquery git://github.com/Hobo/agility-gitorial.git
     $ cd agility-gitorial

Make sure you have the prerequisites for capybara-webkit:
https://github.com/thoughtbot/capybara-webkit/wiki/Installing-QT

     $ bundle install
     $ rake db:migrate

Download the selenium-chrome server and place in your path:
http://code.google.com/p/chromium/downloads/list

     $ rake test:integration

Email the list and/or bryan@larsen.st if you get any failures.

# Changes from Hobo 1.3 & hobo-jquery 1.3

## Retention of Prototype

Currently the jquery branch of github.com:/tablatom/hobo is a 1.3
variant that should actually still works with prototype.js with the
exception of editors.

The current plan is also to drop prototype.js support in Hobo 1.4.  It
could be maintained if there was sufficient demand, but we don't
believe that the demand is there.

## Framework Agnosticism

jQuery support is being written in a manner that should make it easier to support other frameworks if we ever decide to do so.   Basically all this means is that we're annotating our HTML and the javascript is picking up the information from the annotations rather than calling functions or setting variables.

## Unobtrusiveness

The agnosticism is a side benefit -- really the main reason its written this way is so that we're coding using "unobtrusive javascript" techniques.

Hobo currently many different mechanisms to pass data to javascript:

- classdata ex class="model::story:2"
- non-HTML5-compliant element attributes: ex hobo-blank-message="(click to edit)"
- variable assignment: ex hoboParts = ...;
- function calls: ex onclick="Hobo.ajaxRequest(url, {spinnerNextTo: 'foo'})"

hobo-jquery currently uses JSON inside of comments:

    <!-- json_annotation ({"tag":"datepicker","options":{},"events":{}}); -->

We are switching all 5 of these mechanisms to use HTML5 data
attributes.  HTML5 data attributes are technically illegal in HTML4
but work in all browsers future and past (even IE6).  The illegality
of them is the reason that I didn't choose them in Hobo-jQuery, but
it's now 2011.

We mostly use a single attribute: `data-rapid`.  This is a JSON hash
where the keys are the tag names and the values are options hashes.
DRYML has been modified to appropriately merge this tag in a fashion
similar to what it currently does for the `class` tag.  For example,
live-search will have the attribute `data-rapid='{"live-search":{}}'`.
When hobo-jquery initializes, it will then attempt to initialize a
jQuery plugin named `hjq_live_search`, which we provide in
public/javascripts/hobo-jquery/hjq-live-search.js.

`data-rapid-page-data` contains data required by the javascript
library, such as the part information.

One last attribute that may be set is `data-rapid-context`.  This
contains a typed_id of the current context.  This is used to assist
tags like `delete-button` with DOM manipulation.

## Compatibility

Obviously compatibility with hobo-rapid.js is not going to be
maintained, since that's written in prototype.

The internal structure of hobo-jquery has changed completely.  We have
switched to using a more standard jQuery plugin style.

## Enhancements

### multiple parts

I've updated DRYML so that it emits a different DOM ID if you re-instantiate a part.   (The first use of a part retains the DOM ID=partname convention for backwards compatibility)  "update=" requires a DOM ID, so I've also added 2 new AJAX attributes that can be used instead of "update=".

The first one is "updates=".  (name TBD).  Instead of a comma separated list of DOM ID's, it takes a CSS selector.

The other one is "ajax".  (name TBD).   If used inside of a part, it
indicates that part should be updated.   If used outside of a part,
AJAX will be used but no parts will be updated.

These three Ajax attributes may be used simultaneously.

Example:

    <collection:stories>
       <div part="inner">
          <form ajax>
             <input:title/>
          </form>
       </div>
     </collection>

### allowing errors in parts

Older versions of Hobo did not render a part update if the update did
not pass validation.

This behaviour may now be overridden by using the 'errors-ok'
attribute on your form.  (or formlet or whatever other tag initiates
the Ajax call).

The 'errors-ok' attribute is processed in update_response.   If you've
supplied a block to hobo_update you will be responsible for
implementing this functionality yourself.

### AJAX file uploads

If you have malsup's form plugin installed, Ajax file uploads should
"just work", as long as you have debug_rjs turned off in your
config/initiailizers/development.rb.

### AJAX events

The standard 'before', 'success', 'done' and 'error' callbacks may
still be used.   Additionally, the AJAX code now triggers
'rapid:ajax:before', 'rapid:ajax:success', 'rapid:ajax:done' and
'rapid:ajax:error' events to unable you to code more unobtrusively.

If your form is inside of a part, it's quite likely that the form will
be replaced before the rapid:ajax:success and rapid:ajax:done events
fire.  To prevent memory leaks, jQuery removes event handlers from all
removed elements, making it impossible to catch these events.
If this is the case, hobo-jquery triggers these events on the document
itself, and passes the element as an argument.

      $(document).ready(function() {
         jQuery(document).on("rapid:ajax:success", function(event, el) {
            // `this` is the document and `el` is the form
            alert('success');
         });
      });

### before callback

A new callback has been added to the list of Ajax Callbacks: before.
This callback fires before any Ajax is done.   If you return false
from this, the Ajax is cancelled.  So you should probably ensure you
explicitly return true if you use it and don't want your ajax
cancelled.

### callbacks

Normally in HTML you can attach either a snippet of javascript or a
function to a callback.

    <button onclick=fbar/>

This doesn't work in DRYML because the function is not defined in
Ruby, it's only defined in Javascript.

In Hobo 1.3 you would thus be forced to do this to get equivalent behaviour:

    <form update="foo" success="return fbar.call(this);"/>

Now you can just return the function name:

    <form ajax success="fbar"/>

### `hide` and `show` ajax options

There are two new ajax options: `hide` and `show`.  These are passed
directly to the jQuery-UI `hide` and `show` functions.  See
(here)[http://jqueryui.com/demos/show/] and
(here)[http://docs.jquery.com/UI/Effects] for more documentation on
these two functions.  Due to ruby to javascript translation
difficulties, you may not drop optional middle parameters.

Examples:

     <form ajax hide="puff,,slow" show="&['slide', {:direction => :up}, 'fast', 'myFunctionName']/>

     <form ajax hide="drop" show="&['slide', nil, 1000, 'alert(done);']"/>

These two options have global defaults which are TBD.  They may be overridden by passing options to the page-script parameter of `<page>`:

     <extend tag="page">
       <old-page merge>
         <page-scripts: hide="&['slide',{:direction => :up}, 'fast']" show="&['slide',{:direction => :up},'fast']"/>
       </old-page>
     </extend>

To disable effects entirely:

### spinner options

By default, the spinner is now displayed next to the element being
updated.  Besides the old `spinner-next-to` option, there are a number
of new options that control how the spinner is displayed.

- spinner-next-to: DOM id of the element to place the spinner next to.
- spinner-at: CSS selector for the element to place the spinner next to.
- no-spinner: if set, the spinner is not displayed.
- spinner-options: passed to [jQuery-UI's position](http://jqueryui.com/demos/position/).   Defaults are `{my: 'right bottom', at: 'left top'}`
- message: the message to display inside the spinner

These options may be overridden globally by adding them as attributes to the `page-scripts` parameter for the page.

     <extend tag="page">
       <old-page merge>
         <page-scripts: spinner-at="#header" spinner-options="&{:my => 'left top', :at => 'left top'}" />
       </old-page>
     </extend>

### hjq-datepicker

hjq-datepicker now automatically sets dateFormat to the value
specified in your translations:  (I18n.t :"date.formats.default").

### sortable-collection

sortable-collection now supports the standard Ajax callbacks

### delete-button

The new `delete-button` behaviour is not as much different from the
old `delete-button` as a comparison of the documentation would have
you believe, however its Ajax triggering behaviour has changed slightly.

The `fade` attribute is no longer supported.   Instead use the new
standard ajax attribute `hide`.

### autocomplete

`hjq-autocomplete` has been renamed to `autocomplete`.  It has gained
the attribute `nil-value` and the ability to work with the standard
Hobo autocomplete and hobo_completions controller actions.

`name-one` is now a simple backwards-compatibility wrapper around
`autocomplete`.

### input-many

`hjq-input-many` and `input-many` have been merged into `input-many`.
The new standard ajax attributes `hide` and `show` are also now
supported.

Differences from old `input-many`:

- supports hobo-jquery delayed initialization.
- new attributes: add-hook, remove-hook, hide, show

Differences from `hjq-input-many`:

- name of the main parameter is `default` rather than `item`.
- rapid:add, rapid:change and rapid:remove events added.
- new attributes: hide, show

### dialog-box

`hjq-dialog` has been renamed to `dialog-box`.  (`dialog` has already
been taken in HTML5).

The helper functions have been renamed.   For instance,
`hjq.dialog.formletSubmit` has been renamed to
`hjq_dialog_box.submit`.

Dialog positioning has been updated and should work better now.   See
the documentation for more details.

### live-search

`live-search` works in a substantially different fashion now, it has
almost completely lost its magic, instead using standard ajax forms
and parts.   It should now be possible to customize using standard
Hobo techniques.   See the documentation for `<live-search>` and
`<search-results>` for more details.

`live-search` has temporarily lost it's live-ness.  Currently you have
to press 'return' to initiate the search.  This should be easy to fix
in hjq-live-search.js -- the hard part will probably be in doing it in
a way that works in all possible browsers.

## Editors

Editors are no longer special-cased, they now use the standard DRYML
part mechanism.

There are two types of editors: `<click-editor>` and `<live-editor>`.
click-editor is the click-to-edit type of control similar to what
Rapid currently uses for a string, and live-editor always renders the
input, and is similar to what Rapid currently uses for Boolean's and
enum-strings.

Please refer to the documentation for `click-editor` and `live-editor`
for more details.

`<editor>` is now a polymorphic input that uses either `<click-editor>` or
`<live-editor>`.

TBD: Right now live-editor and click-editor use `<formlet>`.  The
major advantage of formlet is that it is safe to use inside of a form.
I can't think of any good use cases for that behaviour, but it does
seem like something people might do by accident.

The alternative is to use `<form>`.   Since this implementation of
editor starts with an input and switches to a view via Javascript,
using a form would allow reasonable javascript-disabled behaviour.

## Missing items

TODO

 * sortable-input-many
 * name-many
 * live-search works, but it's not 'live'

It's quite likely that some of the new tag definitions are missing
id, class, merge or param attributes.  This doesn't impact core
functionality, but it does limit your ability to extend the tags.  If
you notice any such omissions, please let us know, it is easy to fix..

## Changes behind the scenes

### reloading of part context

[This change](https://github.com/tablatom/hobo/commit/6048925) ensures that
DRYML does not reload the part context if it is already in `this`.

### i18n

These commits will require translation updates for languages other
than English.  (Presumably this list will get larger because right now
the change is one I could do myself...)

- https://github.com/tablatom/hobo/commit/e9460d336ef85388af859e5082763bfae0ad01f5

### controller changes

Due to limitations on Ajax file uploads, multipart forms are not sent with the proper Ajax headers.   If your controller action may receive multipart forms, rather than using:

   respond_to do |wants|
      wants.js { hobo_ajax_response }
      wants.html {...}
   end

use

   if request.params[:render]
      hobo_ajax_response
   else
      ....
   end

for more information see http://jquery.malsup.com/form/#file-upload

## Testing

hobo-jquery is being tested using capybara & qunit.js.
