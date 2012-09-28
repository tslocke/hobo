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
using Ajax.  Editors act like standard views until they are clicked
on.   Once clicked, they transform into an input so the user may
modify them.  When the input loses focus, the update is sent
asynchronously to Hobo.

Perhaps the easiest way of using editors is to [convert your show
page](/tutorials/agility#story-status-ajaxified) to use editors
instead of views:

     <show-page>
        <field-list: tag="editor" />
     <show-page>

If you want a single editor, all you have to do is declare it in the
context of a field:

     <editor:name/>

Editors fall back to use a view if the user does not have edit
permissions.  (Edit permission also requires view permission).  So if
you do not see the expected editor, check your permissions.

## Extending Editors

The client-side functionality for Hobo's editors is provided by
script.aculo.us' [Ajax.InPlaceEditor](http://wiki.github.com/madrobby/scriptaculous/ajax-inplaceeditor).  

To create an editor for your rich type, start by copying and modifying
the definition for a similar type, such as `<editor for='string'>`.
You will also need to add behaviour to your application.js.  You can
find several examples in hobo-rapid.js:

    Event.addBehavior({    
      '.my-rich-type.in-place-edit:change' : function (ev) {
        // Ajax.InPlaceEditor options to override the Hobo defaults
        var options = {};  
        var ipe = Hobo._makeInPlaceEditor(this, options);
        ipe.getText = function() {
            return this.element.innerHTML.gsub(/<br\s*\/?>/, "\n").unescapeHTML();
        }
      }});

If you need to pass data down into your javascript, one option is to
use classdata:

    <editor:name class="#{css_data(:rows, 2)}">

    var options = {rows: parseInt(Hobo.getClassData(el, "rows"))};

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

However, if you use a `<repeat>` or a `<table>` to display a part more
than once, you'll need to specify the ID explicitly.

    <repeat:comments>
      <do part="comment" id="comment-#{this_field}">
        <form update="comment-#{this_field}"/>
      </do>
    </repeat>

In Hobo, `this_field` contains the key if you're iterating over a
hash, or the index into the array if you're iterating over an array.

[Tom wrote a
recipe](http://cookbook.hobocentral.net/recipes/8-use-parts-on-repeated-elements)
that covers this topic in further detail.

## Other form attributes

An Ajax form supports all of the Ajax attributes and Ajax callbacks
listed on the [Rapid Forms manual index
page](/api_taglibs/rapid_forms).  These attributes include `update`,
`params`, `confirm`, `message`, and `spinner-next-to`.  They also
support the attributes `reset-form` and `refocus-form`, which are
documented on the [form manual page](/api_tag_defs/form).

# Other Ajax mechanisms

Several other tags in Rapid support the [standard Ajax
attributes](/api_taglibs/rapid_forms) (update, params, confirm,
message and spinner-next-to).  These tags work very similarly to
`<form>`, so refer to the documentation above as well as the manual
page.

 - [remote-method-button](/api_tag_defs/remote-method-button):
   Provides a button to invoke a web method (RPC call) on an object.

 - [update-button](/api_tag_defs/update-button): similar to an Ajax
   form containing zero or more hidden inputs and a submit button

 - [create-button](/api_tag_defs/create-button): similar to `<form
   with="&Foo.new" update="part17"><submit label="New Foo"/></form>`

 - [transition-button](/api_tag_defs/transition-button): invoke a
   lifecycle transition.

# Submitting an Ajax form via Javascript

To make your form even more AJAXy, you may wish to get rid of your
submit button.  Here's a chunk of
[lowpro](http://www.danwebb.net/lowpro) javascript that you can throw
into your application.dryml.  Hobo includes lowpro as a dependency,
but if you prefer to use jQuery or a different library, you're
certainly welcome to.

    Event.addBehavior({
      ".project-name:change": function(ev) {
        Hobo.ajaxRequest(this.up('form'), ['my-part']);
      }
    });

This javascript fragment adds the inner anonymous javascript function
to the change event on every object with the *project-name* class.
When the event happens, `Hobo.ajaxRequest` is called.

ajaxRequest takes three parameters:

  - `url_or_form`:  the URL to submit to or the form element to submit

  - `updates`: a list of part DOM id's to update

  - `options`: optional options hash

The meat of this functions is performed by prototype.js'
[Ajax.Request](http://api.prototypejs.org/ajax/ajax/request.html).
The options hash is basically passed straight through to Ajax.Request,
so you can see the [prototype.js Ajax
documentation](http://api.prototypejs.org/ajax_section.html) for more
details.  Hobo adds the following options:

  - `params`: a hash of the parameters in the request.  Hobo adds the
    form parameters if you specified a form in `form_or_url`.  The
    prototype.js `parameters` option will be overridden by Hobo -- you
    must use `params` instead.

  - `message`: the message to display in the update spinner while the
    Ajax is in progress.  If set explicitly to false, the spinner is
    not displayed.

  - `spinnerNextTo`: the element or element ID to display the spinner
    next to.  If not specified, the spinner is not moved from its
    present location.

# Supporting Hobo Ajax in random controller actions

Most Hobo controller actions have Ajax support built in to them.  The
ones that don't are the ones that only display a web page but do not
create or modify any models.  For example, `edit` does not support
Ajax, but `update` does.  Lifecycle controller actions also have ajax
support baked in.

To add ajax support to your controller, call `hobo_ajax_response`:

    hobo_ajax_response if request.xhr?

Another good option is to call `hobo_update` or `hobo_create` without
supplying a block.   These two functions do more than just the
response, but often it's useful stuff that you'd be doing in your
controller action anyways.  See the [controllers
manual](/manual/controllers) for more information.

If you do need to supply a block to `hobo_update`, `hobo_create` or a
lifecycle controller action, be sure to call `hobo_ajax_response` so
that you do not lose Ajax support.  Here is the default response block
for `hobo_update`, which you can copy and modify.  I've removed
support for [editors](/api_taglibs/rapid_editing) and for
internationalization for simplification.  See `model_controller.rb` in
the hobo source code for the full block if you need either of these.

        if valid?
          respond_to do |wants|
            wants.html do
              redirect_after_submit options
            end
            wants.js do
              hobo_ajax_response(this)

              # Maybe no ajax requests were made
              render :nothing => true unless performed?
            end
          end
        else
          respond_to do |wants|
            wants.html { re_render_form(:edit) }
            wants.js do
              errors = @this.errors.full_messages.join("\n")
              render(:status => 500, :text => "There was a problem with that change.\n#{errors}")
            end
          end
        end

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

# old rapid form documentation

Rapid Forms provides various tags that make it quick and easy to produce working new or edit forms.

### Overview

The main tags are:

 - `<form>`, which acts like the dumb HTML tag if you provide the `action` attribute, and picks up various Rapid smarts
   otherwise.

 - `<input>`, which automatically choses an appropriate form control based on the type of the date.

### Ajax Attributes

Several of the tags in this taglib support the following set of ajax attributes:

 - update: one or more DOM ID's (comma separated string or an array) to be updated as part of the ajax call. Default - no
   update.

   NOTE: yes that's *DOM ID's* not part-names. A common source of confusion because by default the part name and DOM ID are
   the same.

 - params: a hash of name/value pairs that will be converted to HTTP parameters in the ajax request

 - confirm: a message to be displayed in a JavaScript confirm dialog. By default there is no confirm dialog

 - message: a message to be displayed in the Ajax progress spinner. Default: "Saving..."

 - spinner-next-to: DOM ID of an element to position the ajax progress spinner next to.

### Ajax Callbacks

The following attributes are also supported by all the ajax tags. Set them to fragments of javascript to have that script
executed at various points in the ajax request cycle:

 - success: script to run on successful completion of the request

 - failure: script to run on a request failure

 - complete: script to run on completion, regardless of success or failure.

