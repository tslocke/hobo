Ajax in Hobo
{.document-title}

Ajax is used throughout Hobo.   In many cases, Hobo makes it easier to
use Ajax in your pages than it is to use "traditional" web
techniques.  In general, Ajax in Hobo is very easy to use.  This
chapter mostly documents advanced usage.  The first part of the first
two sections will cover 99% of all Hobo Ajax usage.

Contents
{.contents-heading}

- contents
{:toc}

# Editors

[Editors](/api_taglibs/rapid_editing) are perhaps the easiest way of
using Ajax.  Editors act like standard views with live-editing capability: changes made to them are sent to the server immediately.

There are two types of editors: `<live-editor>` and `<click-editor>`.
Live editors always display the `<input>` form of the data.  Click
editors display the `<view>` form until they are clicked on when they
switch to the `<input>` form.  When the user moves away form the click
editor, it transforms back into the `<view>` form.

Perhaps the easiest way of using editors is to [convert your show
page](/tutorials/agility#story-status-ajaxified) to use editors
instead of views:

     <show-page>
        <field-list: tag="click-editor" />
     <show-page>

If you want a single editor, all you have to do is declare it in the
context of a field:

     <click-editor:name/>

Editors fall back to use a view if the user does not have edit
permissions.  (Edit permission also requires view permission).  So if
you do not see the expected editor, check your permissions.

## Extending Editors

Because `<click-editor>` and `<live-editor>` use AJAX parts internally, they are not directly customizable.   Instead, you may utilize the customizable `<click-editor-innards>` and `<live-editor-innards>` directly by providing your own part.  The part name is not significant.

    <part name="my-part">
      <click-editor-innards>
        <view: replace>
          My <view restore/>
        </view:>
      </click-editor-innards>
    </part>

The most useful parameters to customize are the `view`, `blank-view` and `input` parameters on `<click-editor>` and the `input` parameter on `<live-editor>`.

`<click-editor>`, `<live-editor>`, `<click-editor-innards>` and `<live-editor-innards>` are not polymorphic.   They do utilize the polymorphic `<input>` and `<view>` tags, so any customizations you do for those tags will be picked up and utilized.

## Backwards Compatibility

The `<editor>` tag simply selects either `<live-editor>` or `<click-editor>`, depending on which one most closely mimics the functionality available in Hobo 1.3 or earlier.  But it is not simply a backwards compatibility shim, it is useful in its own right -- feel free to use it in new code if you feel it is appropriate.

# Forms

Perhaps the most common way to enable Ajax in Hobo is to use a form.
Simply add the update attribute to your form declaration and the form
will be submitted via Ajax rather than directing the user to a new
page.

    <edit-page:>
      <form: update="something" />
    </edit-page:>

The above example will allow the form to be submitted without leaving
the page.   That's sufficient -- "something" does not have to refer to
anything.   However, usually it does.

After an Ajax form has been submitted, Hobo can update any part of the
page you mark as a part and then specify in the update attribute:

    <edit-page:>
      <content-body:>
        <count:comments part="count"/>
        <form update="count" />
      </content-body:>
    </edit-page:>

## Specifying the DOM ID

The update attribute technically has to be set to the DOM id of the
part rather than the part name.   Normally that's not an issue since
the default DOM id for a part is the part name.

Hobo adds two new attributes to make this simpler.  Instead of `update`, you can instead use `updates` or `ajax`.

`updates` uses a jQuery/CSS selector instead of a DOM id.   So `updates="#foo"` is the same as `update="foo"`.

The `ajax` attribute specifies that the enclosing part is to be updated.   In this example, the part named `foo` would be updated:

    <part name="foo">
      <form ajax/>
    </part>

## Multiple parts

In Hobo 1.3, it was illegal to have two parts with the same name.  Hobo 2.0 automatically renames duplicate part names.  A renamed part will be inaccessible using the `update` attribute, but can be accessed using the `updates` or `ajax` attributes.

For example:

    <repeat>
      <part name="foo">
        <form update="foo">
          ...

If there is more than one item in the list, then only the first part will have the DOM id "foo".   So if you submit the second form, Hobo would update the first form.   This is easily fixed:

    <repeat>
      <part name="foo">
        <form ajax>
          ...

## Other AJAX attributes

There are several other attributes that can be used with AJAX forms.  The use of any one of these attributes specifies will convert the form into an AJAX form.

### messages

* `confirm`: a message to display before form submission.   If you wish to use this with non-AJAX forms, use the jquery-rails attribute `data-confirm`.

* `message`: the message to display in the AJAX progress spinner

### callbacks

There are four callback attributes:  `success`, `failure`, `complete` and `before`.

You can pass either a javascript snippet or the name of a javascript function.

     <form before="alert('hello');">

     <form before="Foo.confirmFrobification">

For all callbacks, the context (aka this) will be set to the form DOM element.

* `before`: called before the form is submitted.  If it returns false,
form submission is cancelled and no other callbacks are called.  Given
Javascript's liberal interpretation of "falsiness", you should
probably explicitly return true if you use it and don't want your ajax
cancelled.

* `success`, `failure`: called in the event of success or failure, respectively

* `complete`:  called after the `success` or `failure` callback

### effects

The `hide` and `show` attributes are passed through to jQuery-UI when
removing the old part and replacing it with the new part. See
[here](http://jqueryui.com/demos/show/) and
[here](http://docs.jquery.com/UI/Effects) for more documentation on
these two functions.  Due to ruby to javascript translation
difficulties, you may not drop optional middle parameters.

Examples:

     <form ajax hide="puff,,slow" show="&['slide', {:direction => :up}, 'fast', 'myFunctionName']/>

     <form ajax hide="drop" show="&['slide', nil, 1000, 'alert(done);']"/>

These default effect is "no effect".  They may be overridden by passing options to the page-script parameter of `<page>`:

     <extend tag="page">
       <old-page merge>
         <page-scripts: hide="&['slide',{:direction => :up}, 'fast']" show="&['slide',{:direction => :up},'fast']"/>
       </old-page>
     </extend>

If, after changing the default you wish to disable effects on one specific ajax element, pass false:

     <form ajax hide="&false" show="&false" ...

Note that these effects require jQuery-UI.  You will get Javascript errors if you attempt to use effects and do not have jQuery-UI installed.

### spinner

By default, the spinner is now displayed next to the element being
updated.

- spinner-next-to: DOM id of the element to place the spinner next to.
- spinner-at: CSS selector for the element to place the spinner next to.
- no-spinner: if set, the spinner is not displayed.
- spinner-options: passed to [jQuery-UI's position](http://jqueryui.com/demos/position/).   Defaults are `{my: 'right bottom', at: 'left top'}`
- message: the message to display inside the spinner

The above attributes may be added to most tags that accept the standard ajax attributes.

These options may be overridden globally by adding them as attributes to the `page-scripts` parameter for the page.

     <extend tag="page">
       <old-page merge>
         <page-scripts: spinner-at="#header" spinner-options="&{:my => 'left top', :at => 'left top'}" />
       </old-page>
     </extend>

Note that all positioning is done using jQuery-UI.   If jQuery-UI is not included in your application, the spinner will be positioned in the top left corner.

### push-state

AJAX now supports a new AJAX option 'push-state' if you have
History.js installed.   It was inspired by [this
post](http://37signals.com/svn/posts/3112-how-basecamp-next-got-to-be-so-damn-fast-without-using-much-client-side-ui)
which uses push-state and fragment caching to create a very responsive
rails application.    Hobo has always supported fragment caching
through Rails, but push-state support is new.

The easiest way to install History.js is to use the [jquery-historyjs](https://github.com/wweidendorf/jquery-historyjs)
gem.  Follow the instructions in the [README at the
link](https://github.com/wweidendorf/jquery-historyjs).

push-state blurs the line between AJAX and non-AJAX techniques,
bringing the advantages of both to the table.   It's considerably more
responsive than a page refresh, yet provides allows browser bookmarks
and history navigation to work correctly.

For example, if the foos and the bars pages have exactly the same
headers but different content, you can speed up links between the
pages by only refreshing the content:

    <%# foos/index.dryml %>
    <index-page>
      <content:>
        <do part="content">
          <a href="&bars_page" ajax push-state new-title="Bars">Bars</a>
          ...
        </do>
      </content:>
    <index-page>

The `new-title` attribute may be used with push state to update the
title.  If you want to update any other section in your headers, you
can put that into a part and list it in the update list as well.
However the new page cannot have new javascript or stylesheets.
Avoiding the refresh of these assets is one of the major reasons to
use push-state!

push-state is well suited for tasks that refreshed the current page
with new query parameters in Hobo 1.3, like `filter-menu`, pagination and
sorting on a `table-plus`.  Thus these tags have been updated to
support all of the standard ajax attributes.

Of course, ajax requests that update only a small portion of the page
will update faster than those that update most of the page.   However,
a small update may mean that a change to the URL is warranted, so you
may want to use standard Ajax rather than push-state in those cases.
Also, push-state generally should not be used for requests that modify
state

push-state works best in an HTML5 browser.  It works in older browsers
such as IE8, IE9 or Firefox 3, but results in strange looking URL's.   See
the README for History.js for more details on that behaviour.

### errors-ok

Older versions of Hobo did not render a part update if the update did
not pass validation.

This behaviour may now be overridden by using the 'errors-ok'
attribute on your form.  (or formlet or whatever other tag initiates
the Ajax call).

The 'errors-ok' attribute is processed in `update_response`.  If you
render or redirect inside a block to `hobo_update` you will be
responsible for implementing this functionality yourself, or calling
update_response to do it for you.

### reset-form

If set, the form inside the part will be reset after AJAX.

### refocus-form

If set, the focus will be reset to the first input inside of the part after AJAX.

### params

Hobo 1.3 included a `params` attribute.   This is *NOT* supported in Hobo 2.0.  If you wish to add additional parameters, just use a hidden input inside your form:

    <input type="hidden" name="foo" value="17"/>

# Using AJAX without the `<a>` tag

The `<a>` tag also includes support for AJAX.  See it's documentation
for more details.  Note that `<a>` tag is used to display a
*different* page, which can cause issues with context.  The `<form>`
tag rerenders the current page with the appropriate changes.

In many cases you're better off using a construction like this instead of the `<a href="somewhere/else">`

    <form action="somewhere/else" update="foo"><submit label="update foo"/></form>

# Ajax without the `<form>` tag.

Hobo 2.0 uses forms for almost all of its AJAX.  If you want to use
Hobo part AJAX for things that would not conventionally be handled by
a form, it's still easiest to use a form.

For instance, you can create an AJAX button with something like:

    <form action="foo" update="foo-part"><submit label="foo"/></form>

If you wish to invoke AJAX via Javascript, you can create a hidden
form that you can parameterize and submit via Javascript:

    <form id="foo-form" style="display:none;" action="foo" update="foo-part">
        <input name="p1" value="17" type="hidden"/>
    </form>

    $("input[name=p1]").val(92);
    $("form#foo-form").submit();

# The Part Context

This is some background information to some of the magic that Hobo
performs.  You probably don't need to know this, but it helps.

A Hobo Ajax request involves two separate controller actions: the
action that displays the initial page, and the action that handles the
ajax request.  In the [agility
tutorial](http://cookbook.hobocentral.net/tutorials/agility#auto-completion-form)
there is an ajax form on the project show page that allows you to add
new members to the project.   The page is displayed by `projects#show`,
but after you add a member, the part is rendered by
`project_memberships#create`.

Here's the snippet from agility:

    <aside:>
      <h2>Project Members</h2>
      <collection:members part="members"/>

      <form:memberships.new update="members" reset-form refocus-form>
        <div>
          Add a member:
          <name-one:user/>
        </div>
      </form>
    </aside:>

The context (aka *this*) for `projects#show` is a Project.  The context for
`project_memberships#create` is a ProjectMembership.  However, the
part (`<collection:members>`) is always rendered with the context set
to the appropriate Project no matter which controller action rendered
it.

To make this magic happen, hobo saves the [typed_id](/manual/model) of
your context in a cryptographically secure fashion at the bottom of
your page in the
[page-scripts](http://cookbook.hobocentral.net/api_tag_defs/page-scripts)
tag.  This is passed back to Hobo in the Ajax call, which looks up the
model in the database, and renders the part with it.

If your context is not stored in the database, your part will likely
not render correctly.

There is one exception: if your part context is the same as the page
context, but it hasn't been saved in the database, Hobo will use the
controller's context for the part.

# Local Variables


A part is rendered separately. If you have defined any local
variables in the rest of the page they are not available inside
the part unless you declare them in the `part-locals` attribute.

    <set x="17">
    <do part="part1" part-locals="x">
      <%= x %>
    </do>

If the variable is an ActiveRecord instance, the `typed_id` of the
variable is saved, and the variable is reloaded from the database when
the part is rendered.

Otherwise the variable is serialized for re-use when the part is
rendered.

## Instance variables

For convenience, Hobo allows you to place an instance variable inside
a part-locals attribute.  These two snippets are identical:

    <set x="@x">
    <do part="part2" part-locals="x">

and

    <do part="part2" part-locals="@x">

Inside of the part, use the local variable `x` rather than the
instance variable `@x`.  You can use `@x`, but that refers to
something the variable created by the part's controller, not the one
created by the page's controller.   If it's the variable from the
part's controller you want, I recommend not placing it in part-locals
simply to avoid confusion.   I'll use a simple example to illustrate the
difference.  We'll re-create something similar to the standard flash
message.

We're going to place an ajax form inside the show page of an object.
So the first time our flash part renders, it will be using the edit
controller method.  When the user submits the form, it will be
processed by the update controller method, which will re-render the
part.

    <edit-page>
      <content-body:>
        <do part="part-flash2" part-locals="@flash2">
          <p>Message 1: <%= flash2 %></p>
          <p>Message 2: <%= @flash2 %></p>
        </do>
        <form update="part-flash2"/>
      </content-body:>
    </edit-page>

The controller:

    def show
      @flash2 = "Editing object."
      hobo_show
    end

    def update
      @flash2 = "Object updated."
      hobo_update
    end

If you try this out, when you render the show page, both messages
display "Editing object."   When you click on save, the first message
displays the old message, but the second message displays the new
message: "Object updated."

In this example it's the second behaviour we want.   So to avoid
confusion, drop the part-locals attribute.  Without it you will need
to ensure that the instance variable is declared in both of the
relevant controller actions.
