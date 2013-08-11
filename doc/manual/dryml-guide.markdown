The DRYML Guide
{: .document-title}

DRYML is a templating language based on the concept of composable parameterized tags.  This makes it possible to create a complex tag (such as a whole web page) whose inner (parameterized) pieces can be customized differently on different invocations.  For example, for every resource (model-view-controller) created in application, hobo automatically creates an associated CRUD interface that is easily adaptable to meet the application's requirements.  Indeed, most Hobo applications, even the ones with complex interfaces, simply use the generated interface with minor adaptions.

This chapter is devoted to the details of how to use, create and extend DRYML tags.  If you have little or no experience with Hobo and DRYML, then it would be better for you to start with the Agility tutorial---to get an understanding of how DRYML is used---before staring on this chapter.  If you are developing an application and want to customize part of the interface, then it would be better for you to start in the app/views/taglibs/auto/rapid/ directory of your application, where the automatically generated tags are stored.  If you need more information about the tags used construct your application's interface, or need specialized tags, then you probably should be exploring the Tab Libraries (Taglibs).  Finally, if you need to create new tags, extend old tags, or need to call tags in a non-simple way, then read on.





Contents
{: .contents-heading}

- contents
{:toc}


# What is DRYML?

DRYML is a template language for Ruby on Rails that you can use in
place of Rails' built-in ERB templates. It is part of the larger Hobo
project, but can be used standalone without Hobo or even without
Rails. DRYML was created in response to the observation that the vast
majority of Rails development time seems to be spent in the
view-layer. Rails' models are beautifully declarative, the controllers
can be made so pretty easily (witness the many and various "result
controller" plugins), but the views, ah the views...

Given that so much of the user interaction we encounter on the web is so similar from one website to another, surely we don't have to code all this stuff up from low-level primitives over and over again? Please, no! Of course what we want is a nice library of ready-to-go user interface components, or widgets, which can be quickly added to our project, and easily tailored to the specifics of our application.

If you've been at this game for a while you're probably frowning about now. Re-use is a very, very thorny problem. It's one of those things that sounds straight-forward and obvious in principle, but turns out to be horribly difficult in practice. When you come to re-use something, you very often find that your new needs differ from the original ones in a way that wasn't foreseen or catered for in the design of the component. The more complex the component, the more likely it is that bending the thing to your needs will be harder than starting again from scratch. 

So the challenge is not in being able to re-use code, it is in being able to re-use code in ways that were not foreseen. The reason we created DRYML was to see if this kind of flexibility could be built into the language itself. DRYML is a tag-based language that makes it trivially easy to give the defined tags a great deal of flexibility.

So DRYML is just a means to an end. The real goal is to create a library of reusable user-interface components that actually succeed in making it very quick and easy to create the view layer of a web application. That library is also part of Hobo -- the *Rapid* tag library, but Rapid is not covered in this guide. Here we will see how DRYML provides the tools and raw materials that make a library like Rapid possible.

Not covering Rapid means that many of the examples are *not* good advice for use of DRYML in a full Hobo app. For example, in this guide you might see

    <%= h this.name %>
    
Which in an app that used Rapid would be better written `<view:name/>` or even just `<name/>` (that's a tag by the way, called `name`, not some metaprogramming trick that lets you use field names as tags). Bear that in mind while you're reading this guide. The examples are chosen to illustrate the point at hand, they are not necessarily something you want to paste right into your application.
    


# Simple page templates and ERB

In its most basic usage, DRYML can be indistinguishable from a normal Rails template. That's because DRYML is (almost) an extension of ERB, so you can still insert Ruby snippets using the `<% ... %>` notation. For example, a show-page for a blog post might look like this:

    <html>
      <head>
        <title>My Blog</title>
      </head>
      <body>
        <h1>My Famous Blog!</h1>
        <h2><%= @post.title %></h2>
        
        <div class="post-body">
          <%= @post.body %>
        </div>
      </body>
    </html>
{.dryml}

## No ERB inside tags

DRYML's support for ERB is not *quite* the same as true ERB templates. The one thing you can't do is use ERB snippets inside a tag. To have the value of an attribute generated dynamically in ERB, you could do:

    <a href="<%= my_url %>">
{.dryml}
 
In DRYML you would do:

    <a href="#{my_url}">
{.dryml}

In rare cases, you might use an ERB snippet to output one or more entire attributes:

    <form <%= my_attributes %>>
{.dryml}
    
We're jumping ahead here, so just skip this if it doesn't make sense, but to do the equivalent in DRYML, you would need your attributes to be in a hash (rather than a string), and do:

    <form merge-attrs="&my_attributes">
{.dryml}
    
Finally, in a rare case you could even use an ERB snippet to generate the tag name itself:

    <<%= my_tag_name %>> ... </<%= my_tag_name %>>
{.dryml}
    
To achieve that in DRYML, you could put the angle brackets in the snippet too:

    <%= "<#{my_tag_name}>" %> ... <%= "</#{my_tag_name}>" %>
{.dryml}

Or you could use the `<call-tag>` or `<wrap>` DRYML tags to compose
your snippet:

    <call-tag tag="&my_tag_name"> ... </call-tag>
{.dryml}
    
## Where are the layouts?

Going back to the `<page>` tag at the start of this section, from a "normal Rails" perspective, you might be wondering why the boilerplate stuff like `<html>`, `<head>` and `<body>` are there. What happened to layouts? You don't tend to use layouts with DRYML, instead you would define your own tag, typically `<page>`, and call that. Using tags for layouts is much more flexible, and it moves the choice of layout out of the controller and into the view layer, where it should be.
    
We'll see how to define a `<page>` tag in the next section.


# Defining simple tags

One of the strengths of DRYML is that defining tags is done right in the template (or in an imported tag library) using the same XML-like syntax. This means that if you've got markup you want to re-use, you can simply cut-and-paste it into a tag definition.

Here's the page from the previous section, defined as a `<page>` tag simply by wrapping the markup in a `<def>` tag:

    <def tag="page">
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body>
          <h1>My Famous Blog!</h1>
          <h2><%= @post.title %></h2>
      
          <div class="post-body">
            <%= @post.body %>
          </div>
        </body>
      </html>
    </def>
{.dryml}


Now we can call that tag just as we would call any other:

    <page/>
{.dryml}

If you'd like an analogy to "normal" programming, you can think of the `<def>...</def>` as defining a method called `page`, and `<page/>` as a call to that method. In fact, DRYML is implemented by compiling to Ruby, and that is exactly what is happening.

## Parameters

We've illustrated the most basic usage of `<def>`, but our `<page>` tag is not very useful. Let's take it a step further to make it into the equivalent of a layout. First of all, we clearly need the body of the page to be different each time we call it. In DRYML we achieve this by adding *parameters* to the definition, which is accomplished with the `param` attribute. Here's the new definition:

    <def tag="page">
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body param/>
      </html>
    </def>
{.dryml}


Now we can call the `<page>` tag and provide our own body:

    <page>
      <body:>
        <h1>My Famous Blog!</h1>
        <h2><%= @post.title %></h2>
    
        <div class="post-body">
          <%= @post.body %>
        </div>
      </body:>
    </page>
{.dryml}

See how easy that was? We just added `param` to the `<body>` tag, which means our page tag now has a parameter called `body`. In the `<page>` call we provide some content for that parameter. It's very important to read that call to `<page>` properly. In particular, the `<body:>` (note the trailing ':') is *not* a call to a tag, it is providing a named parameter to the call to `<page>`. We call `<body:>` a *parameter tag*. In Ruby terms you could think of the call like this:
        
    page(:body => "...my body content...")
{.ruby}

Note that is not actually what the compiled Ruby looks like in this case, but it illustrates the important point that `<page>` is a call to a defined tag, whereas `<body:>` is providing a parameter to that call.
    
## Changing Parameter Names
    
To give the parameter a different name, we can provide a value to the `param` attribute:

    <def tag="page">
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body param="content"/>
      </html>
    </def>
{.dryml}

We would now call the tag like this:

    <page><content:> ...body content goes here... </content:></page>
{.dryml}

## Multiple Parameters
    
As you would expect, we can define many parameters in a single tag. For example, here's a page with a side-bar:

    <def tag="page">
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body>
          <div param="content"/>
          <div param="aside" />
        </body>
      </html>
    </def>
{.dryml}

Which we could call like this:

    <page>
      <content:> ... main content here ... </content:>
      <aside:>  ... aside content here ... </aside:>
    </page>
{.dryml}

Note that when you name a parameter, DRYML automatically adds a CSS class of the same name to the output, so the two `<div>` tags above will be output as `<div class="content">` and `<div class="aside">` respectively.
    
## Default Parameter Content

In the examples we've seen so far, we've only put the `param` attribute on empty tags. That's not required though. If you declare a non-empty tag as a parameter, the content of that tag becomes the default when the call does not provide that parameter. This means you can easily add a parameter to any part of the template that you think the caller might want to be able to change:

    <def tag="page">
      <html>
        <head>
          <title param>My Blog</title>
        </head>
        <body param>
      </html>
    </def>
{.dryml}

We've made the page title parameterised. All existing calls to `<page/>` will continue to work unchanged, but we've now got the ability to change the title on a per-page basis:

    <page>
      <title:>My VERY EXCITING Blog</title:>
      <body:>
        ... body content
      </body:>
    </page>
{.dryml}

This is a very nice feature of DRYML - whenever you're writing a tag, and you see a part that might be useful to change in some situations, just throw the `param` attribute at it and you're done.

## Nested `param` Declarations

You can nest `param` declarations inside other tags that have `param` on them. For example, there's no need to choose between a `<page>` tag that provides a single content section and one that provides an aside section as well -- a single definition can serve both purposes:

    <def tag="page">
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body param>
          <div param="content"/>
          <div param="aside" />
        </body>
      </html>
    </def>
{.dryml}

Here the `<body>` tag is a `param`, and so are the two `<div>` tags inside it. The `<page>` tag can be called either like this:

    <page>
      <body:> ... page content goes here ... </body:>
    </page>
{.dryml}

Or like this:

    <page>
      <content:> ... main content here ... </content:>
      <aside:>  ... aside content here ... </aside:>
    </page>
{.dryml}

An interesting question is, what happens if you give both a `<body:>` parameter and say, `<content:>`. By providing the `<body:>` parameter, you have replaced everything inside the body section, including those two parameterised `<div>` tags, so the `<body:>` you have provided will appear as normal, but the `<content:>` parameter will be silently ignored.

    
## The Default Parameter

In the situation where a tag will usually be given a single parameter when called, you can give your tag a more compact XML-like syntax by using the special parameter name `default`:

    <def tag="page">
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body param="default"/>
      </html>
    </def>
{.dryml}

Now there is no need to give a parameter tag in the call at all - the content directly inside the `<page>` tag becomes the `default` parameter:
    
    <page> ... body content goes here -- no need for a parameter tag ... </page>
    
You might notice that the `<page>` tag is now indistinguishable from a normal HTML tag. Some find this aspect of DRYML disconcerting at first -- how can you tell what is an HTML tag and what it a defined DRYML tag? The answer is -- you can't, and that's quite deliberate. This allows you to do nice tricks like define your own smart `<form>` tag or `<a>` tag (the Rapid library does exactly that). Other tag-based template languages (e.g. Java's JSP) like to put everything in XML namespaces. The result is very cluttered views that are boring to type and hard to read. From the start we put a very high priority on making DRYML templates compact and elegant. When you're new to DRYML you might have to do a lot of looking things up, as you would with any new language or API, but things gradually become familiar and then view templates can be read and understood very easily.
{.aside}


# The Implicit Context

In addition to the most important goal behind DRYML - creating a template language that would encourage re-use in the view layer, a secondary goal is for templates to be concise, elegant and readable. One aspect of DRYML that helps a lot in this regard is something called the *implicit context*.

This feature was born of a simple observation that pretty much every page in a web app renders some kind of hierarchy of application objects. Think about a simple page in a blog - say, the permalink page for an individual post. The page as a whole can be considered a rendering of a BlogPost object. Then we have sections of the page that display different "pieces" of the post -- the title, the date, the author's name, the body. Then we have the comments. The list of comments as a whole is also a "piece" of the BlogPost. Within that we have each of the individual comments, and the whole thing starts again: the comment title, date, author... This can carry on even further, for example some blogs are set up so that you can comment on comments.

This structure is incredibly common, perhaps even universal, as it seems to be intrinsically tied to the way we visually parse information. DRYML's implicit context takes advantage of this fact to make templates extremely concise while remaining readable and clear. The object that you are rendering in any part of the page is known as the *context*, and every tag has access to this object through the method `this`. The controller sets up the initial context, and the templates then only have to mention where the context needs to *change*.

We'll dive straight into some examples, but first a quick general point about this guide. If you like to use the full Hobo framework, you will probably always use DRYML and the Rapid tag library together. DRYML and Rapid have grown up together, and the design of each is heavily influenced by the other. Having said that, this is the DRYML Guide, not the Rapid Guide. We won't be using any Rapid tags in this guide, because we want to document DRYML the language properly. That will possibly be a source of confusion if you're very used to working with Rapid. Just keep in mind that we're not allowed to use any Rapid tags in this guide and you'll be fine.

In order to see the implicit context in its best light, we'll start by defining a `<view>` tag, that simply renders the current context with HTML escaping. Remember the context is always available as `this`:
    
    <def tag="view"><%= h this.to_s %></def>
{.dryml}

Next we'll define a tag for making a link to the current context. We'll assume the object will be recognised by Rails' polymorphic routing. Let's call the tag `l` (for link):

    <def tag="l"><a href="#{url_for this}" param="default"/></def>
{.dryml}

Now let's use these tags in a page template. We'll stick with the comfortingly boring blog post example. In order to set the initial context, our controller action would need to do something like this:

    def show
      @this = @blog_post = BlogPost.find(params[:id])
    end
{.ruby}

The DRYML template handler looks for the `@this` instance variable for the initial context. It's quite nice to also set the more conventionally named instance variable as we've done here. 

Now we'll create the page. Let's assume we're using a `<page>` tag along the lines of those defined above. We'll also assume that the blog post object has these fields: `title`, `published_at`, `body` and `belongs_to :author`, and that the author has a `name` field:
    
    <page>
      <content:>
        <h2><view:title/></h2>
        <div class="details">
          Published by <l:author><view:name/></l> on <view:published-at/>.
        </div>
        <div class="post-body">
          <view:body/>
        </div>
      </content:>
    </page>
{.dryml}

When you see a tag like `<view:title/>`, you don't get any prizes for guessing what will be displayed. In terms of what actually happens, you can read this as "change the context to be the `title` attribute of the current context, then call the `<view`> tag". You might like to think of that change to the context as `this = this.title` (although in fact `this` is not assignable). But really you just think of it as "view the title". Of what? Of whatever is in context, in this case the blog post.

Be careful with the two different uses of colon in DRYML. A trailing colon as in `<foo:>` indicates a parameter tag, whereas a colon joining two names as in `<view:title/>` indicates the `<view>` call with the change of context.

When the tag ends, the context is set back to what it was. In the case of `<view/>` which is a self-closing tag familiar from XML, that happens immediately. The `<l:author>` tag is more interesting. We set the context to be the author, so that the link goes to the right place. Inside the `<l:author>` that context remains in place so we just need `<view:name/>` in order to display the author's name.

## `with` and `field` attributes

The `with` attribute is a special DRYML attribute that sets the context to be the result of any Ruby expression before the tag is called. In DRYML any attribute value that starts with '&' is interpreted as a Ruby expression. Here's the same example as above using only the `with` attribute:

    <page>
      <content:>
        <h2><view with="&@blog_post.title"/></h2>
        <div class="details">
          Published by <l with="&@blog_post.author"><view with="&this.name"/></l>
          on <view with="&@blog_post.published-at"/>.
        </div>
        <div class="post-body">
          <view with="&@blog_post.body"/>
        </div>
      </content:>
    </page>
{.dryml}

Note that we could have used `&this.title` instead of `&@blog_post.title`.

The `field` attribute makes things more concise by taking advantage of a common pattern. When changing the context, we very often want to change to some attribute of the current context. `field="x"` is a shorthand for `with="&this.x"` (actually it's not quite the same, using the `field` version also sets `this_parent` and `this_field`, whereas `with` does not. This is discussed later in more detail).

The same template again, this time using `field`:

    <page>
      <content:>
        <h2><view field="title"/></h2>
        <div class="details">
          Published by <l field="author"><view field="name"/></l>
          on <view field="published-at"/>.
        </div>
        <div class="post-body">
          <view field="body"/>
        </div>
      </content:>
    </page>
{.dryml}

If you compare that example to the first one, you should notice that the `:` syntax is just a shorthand for the `field` attribute; i.e., `<view field="name">` and `<view:name>` are equivalent.
    
## Field chains

Sometimes you want to drill down through several fields at a time. Both the `field` attribute and the `:` shorthand support this. For example:

    <view:category.name/>
    <view field="category.name"/>
{.dryml}

    
## `this_field` and `this_parent`

When you change the context using `field="my-field"` (or the `<tag:my-field>` shorthand), the previous context is available as `this_parent`, and the name of the field is available as `this_field`. If you set the context using `with="..."`, these values are not available. That means the following apparently identical tag calls are not quite the same:

    <my-tag with="&@post.title"/>

is not quite the same as:

    <my-tag with="&@post" field="title"/>

If the tag requires `this_parent` and `this_field`, and in Rapid, for
example, some do, then it must be called using the second style.

## Numeric field indices

If your current context is a collection, you can use the field
attribute to change the context to a single item.

    <my-tag field="7" />

and

    <% i=97 %>
    <my-tag field="&i" />

The `<repeat>` tag sets `this_field` to the current index into the
collection.

    <repeat:foos>
      <td><%= this_field %></td>
      <td><view /></td>
    </repeat:foos>

## Forms

When rendering the Rapid library's `<form>` tag, DRYML keeps track of
even more metadata in order to add `name` attributes to form fields
automatically.  This mechanism does not work if you set the context
using `with=`.  

# Tag attributes

As we've seen, DRYML provides parameters as a mechanism for customising the markup that is output by a tag. Sometimes we want to provide other kinds of values to control the behaviour of a tag: URLs, filenames or even Ruby values like hashes and arrays. For this situation, DRYML lets you define tag attributes.

As a simple example, say your application has a bunch of help files in `public/help`, and you have links to them scattered around your views. Here's a tag you could define:

    <def tag="help-link" attrs="file">
      <a class="help" href="#{base_url}/help/#{file}.html" param="default"/>
    </def>
{.dryml}

`<def>` takes a special attribute `attrs`. Use this to declare a list (separated by commas) of attributes, much as you would declare arguments to a method in Ruby. Here we've defined one attribute, `file`, and just like arguments in Ruby, `file` becomes a local variable inside the tag definition. In this definition we construct the `href` attribute from the `base_url` helper and `file`, using Ruby string interpolation syntax (`#{....}`). Remember that you can use that syntax when providing a value for any attribute in DRYML.

The call to this tag would look like this:

    <help-link file="intro">Introductory Help</help-link>
{.dryml}

Using regular XML-like attribute syntax -- `file="intro"` -- passes "intro" as a string value to the attribute. DRYML also allows you to pass any Ruby value. When the attribute value starts with `&`, the rest of the attribute is interpreted as a Ruby expression. For example you could use this syntax to pass `true` and `false` values:

    <help-link file="intro" new-window="&true">Introductory Help</help-link>
    <help-link file="intro" new-window="&false">Introductory Help</help-link>
{.dryml}

And we could add that `new-window` attribute to the definition like this:

    <def tag="help-link" attrs="file, new-window">
      <a class="help" href="#{base_url}/help/#{file}.html"
         target="#{new_window ? '_blank' : '_self' }" param="default"/>
    </def>
{.dryml}

An important point to notice there is that the markup-friendly dash in the `new-window` attribute became a Ruby-friendly underscore (`new_window`) in the local variable inside the tag definition.

Using the `&`, you can pass any value you like -- arrays, hashes, active-record objects...

In the case of boolean values like the one used in the above example, there is a nicer syntax that can be used in the call...


## Flag attributes

That `new-window` attribute shown in the previous section is simple switch - on or off. DRYML lets you omit the value of the attribute, giving a flag-like syntax:

    <help-link file="intro" new-window>Introductory Help</help-link>
    <help-link file="intro">Introductory Help</help-link>
{.dryml}

Omitting the attribute value is equivalent to giving `"&true"` as the value. In the second example the attribute is omitted entirely, meaning the value will be `nil` which evaluates to false in Ruby and so works as expected.


## `attributes` and `all_attributes` locals

Inside a tag definition two hashes are available in local variables: 
- `attributes` contains all the attributes that *were not declared* in the `attrs` list of the `def` but that were provided in the call to the tag.
- `all_attributes` contains every attribute, including the declared ones.


## Merging Attributes

In a tag definition, you can use the `merge-attrs` attribute to take any 'extra' attributes that the caller passed in, and add them to a tag of your choosing inside your definition. Let's backtrack a bit and see why you might want to do that.

Here's a simple definition for a `markdown-help` tag- it's similar to a tag defined in the Hobo Cookbook app:

    <def tag="markdown-help">
      <a href="http://daringfireball.net/..." param="default"/>
    </def>
{.dryml}

You would use it like this:

    Add formatting using <markdown-help>markdown</markdown-help>
{.dryml}

Suppose you wanted to give the caller the ability to choose the `target` for the link. You could extend the definition like this:

    <def tag="markdown-help" attrs="target">
      <a href="http://daringfireball.net/..." target="&target" param="default"/>
    </def>
{.dryml}

Now we can call the tag like this:

    Add formatting using <markdown-help target="_blank">markdown</markdown-help>
{.dryml}

OK, but maybe the caller wants to add a CSS class, or a javascript `onclick` attribute, or any one of a dozen potential HTML attributes. This approach is not going to scale. That's where `merge-attrs` comes in.  As mentioned above, DRYML keeps track of all the attributes that were passed to a tag, even if they were not declared in the `attrs` list of the tag definition. They are available in two hashes: `attributes` (that has only undeclared attributes) and `all_attributes` (that has all of them), but in normal usage you don't need to access those variables directly. To add all of the undeclared attributes to a tag inside your definition, just add the `merge-attrs` attribute, like this:

    <def tag="markdown-help">
      <a href="http://daringfireball.net/..." merge-attrs param="default"/>
    </def>
{.dryml}

Note that the `merge` attribute is another way of merging attributes. Declaring `merge` is a shorthand for declaring both `merge-attrs` and `merge-params` (which we'll cover later).

## Merging selected attributes

`merge-attrs` can be given a value - either a hash containing attribute names and values, or a list of attribute names (comma separated), to be merged from the `all_attributes` variable.

Examples:

    <a merge-attrs="href, name">
    
    <a merge-attrs="&my_attribute_hash">
{.dryml}

A requirement that crops up from time to time is to forward to a tag all the attributes that it understands (i.e. the attributes from that tag's `attrs` list), and to forward some or all the other attributes to tags called within that tag. Say for example, we are declaring a tag that renders a section of content, with some navigation at the top. We want to be able to add CSS classes and so on to the main `<div>` that will be output, but the `<navigation>` tag also defines some special attributes, and these need to be forwarded to it.
    
To achieve this we take advantage of a helper method `attrs_for`. Given the name of a tag, it returns the list of attributes declared by that tag.

Here's the definition:

    <def tag="section-with-nav">
      <div class="section" merge-attrs="&attributes - attrs_for(:navigation)">
        <navigation merge-attrs="&attributes & attrs_for(:navigation)"/>
        <do param="default"/>
      </div>
    </def>
{.dryml}
    
Note that:

 - The expression `attributes - attrs_for(:navigation)` returns a hash of only those attributes from the `attributes` hash that are *not* declared by `<navigation>` (The `-` operator on `Hash` comes from HoboSupport)

 - The expression `attributes & attrs_for(:navigation)` returns a hash of only those attributes from the `attributes` hash that *are* declared by `<navigation>` (The `&` operator on `Hash` comes from HoboSupport)
     
 - The `<do>` tag is a "do nothing" tag, defined by the core DRYML taglib, which is always included.

## The class attribute

If you have the following definition:

    <def tag="foo">
      <div id="foo" class="bar" merge-attrs />
    </def>
{.dryml}

and the user invokes it with:

    <foo id="baz" class="bop" />
{.dryml}

The following content will result:

    <foo id="baz" class="bar bop" />

The `class` attribute receives special behaviour when merging.  All
other attributes are overridden with the user specified values.  The
`class` attribute takes on the values from both the tag definition and
invocation.

# Repeated and optional content

As you would expect from any template language, DRYML has the facility to repeat sections of content, and to optionally render or not render given sections according to your application's data. DRYML provides two alternative syntaxes, much as Ruby does (e.g. Ruby has the block `if` and the one-line suffix version of `if`).


## Conditionals - if and unless

DRYML provides `if` and `unless` both as tags, which come from the core tag library, and are just ordinary tag definitions, and as attributes, which are part of the language:

The tag version:

    <if test="&logged_in?"><p>Welcome back</p></if>
{.dryml}

The attribute version:

    <p if="&logged_in?">Welcome back</p>
{.dryml}
    
Important note! The test is performed (in Ruby terms) like this:

    if (...your test expression...).blank?
{: .ruby}

Got that? Blankiness not truthiness (`blank?` comes from ActiveSupport by the way -- Rails' mixed bag of core-Ruby extensions). So for example, in DRYML:

    <if test="&current_user.comments">
{.dryml}

is a test to see if there are any comments -- empty collections are considered blank. We are of the opinion that Matz made a fantastic choice for Ruby when he followed the Lisp / Smalltalk approach to truth values, but that view templates are a special case, and testing for blankness is more often what you want.

Can we skip `<unless>`? It's like `<if>` with the nest negated. You get the picture, right?


## Repetition

For repeating sections of content, DRYML has the `<repeat>` tag (from the core tag library) and the `repeat` attribute.
    
The tag version:
    
    <repeat with="&current_user.new_messages"> <h3><%= h this.subject %></h3> </repeat>
{.dryml}

The attribute version:

    <h3 repeat="&current_user.new_messages"><%= h this.subject %></h3>
{.dryml}

Notice that as well as the content being repeated, the implicit context is set to each item in the collection in turn.


### even/odd classes

It's a common need to want alternating styles for items in a collection - e.g. striped table rows. Both the repeat attribute and the repeat tag set a scoped variable `scope.even_odd` which will be alternately 'even' then 'odd', so you could do:

    <h3 repeat="&new_messages" class="#{scope.even_odd}"><%= h this.subject %></h3>
{.dryml}

That example illustrates another important point -- any Ruby code in attributes is evaluated *inside* the repeat. In other words, the `repeat` attribute behaves the same as wrapping the tag in a `<repeat>` tag.
    
    
### `first_item?` and `last_item?` helpers

Another common need is to give special treatment to the first and last items in a collection. The `first_item?` and `last_item?` helpers can be used to find out when these items come up; e.g., we could use `first_item?` to capitalise the first item:

    <h3 repeat="&new_messages"><%= h(first_item? ? this.subject.upcase : this.subject) %></h3>
{.dryml}


### Repeating over hashes

If you give a hash as the value to repeat over, DRYML will iterate over each key/value pair, with the value available as `this` (i.e. the implicit context) and the key available as `this_key`. This is particularly useful for grouping things in combination with the `group_by` method:

    <div repeat="&current_user.new_messages.group_by(&:sender)">
      <h2>Messages from <%= h this_key %></h2>
        <ul>
          <li repeat><%= h this.subject %></li>
        </ul>
      <h2>
    </div>
{.dryml}

That example has given a sneak preview of another point - using if/unless/repeat with the implicit context. We'll get to that in a minute.


## Using the implicit context

If you don't specify the test of a conditional, or the collection to repeat over, the implicit context is used. This allows for a few nice shorthands. For example, this is a common pattern for rendering collections:

    <if:comments>
      <h3>Comments</h3>
      <ul>
        <li repeat> ... </li>
      </ul>
    </if>
{.dryml}

We're switching the context on the `<if>` tag to be `this.comments`, which has two effects. Firstly the comments collection is used as the test for the `if`, so the whole section including the heading will be omitted if the collection is empty (remember that `if` tests for blankness, and empty collections are considered blank). Secondly, the context is switched to be the comments collection, so that when we come to repeat the `<li>` tag, all we need to say is `repeat`.


### One last shorthand - attributes of `this`

The attribute versions of `if`/`unless` and `repeat` support a useful shortcut for accessing attributes or methods of the implicit context. If you give a literal string attribute--that is, an attribute that does not start with `&`--this is interpreted as the name of a method on `this`. For example:

    <li repeat="comments"/>
{.dryml}
 
is equivalent to

    <li repeat="&this.comments"/>
{.dryml}
    
Similarly

    <p if="sticky?">This post has been marked 'sticky'</p>
{.dryml}


is equivalent to

    <p if="this.sticky?">This post has been marked 'sticky'</p>
{.dryml}

    
It is a bit inconsistent that these shortcuts do not work with the tag versions of `<if>`, `<unless>` and `<repeat>`. This may be remedied in a future version of DRYML.
  
## Content tags only

The attributes introduced in this section -- `repeat`, `if` and `unless`, can only be used on content tags, i.e. static HTML tags and defined tags. They cannot be used on tags like `<def>`, `<extend>` and `<include>`.

    

# Pseudo parameters - `before`, `after`, `append`, `prepend`, and `replace`

For every parameter you define in a tag, there are five "pseudo parameters" created as well. Four allow you to insert extra content without replacing existing content, and one lets you replace or remove a parameter entirely.

To help illustrate these, here's a very simple `<page>` tag:
    
    <def tag="page">
      <body>
        <h1 param="heading"><%= h @this.to_s %></h1>
        <div param="content"></div>
      </body>
    </def>
{.dryml}

We've assumed that `@this.to_s` will give us the name of the object that this page is presenting.


## Inserting extra content

The output of the heading would look something like:

    <h1 class="heading">Welcome to my new blog</h1>
    
Pseudo parameters give us the ability to insert extra context in four places, marked here as `(A)`, `(B)`, `(C)` and `(D)`:

    (A)<h1 class="heading">(B)Welcome to my new blog(C)</h1>(D)
    
The parameters are:

 - (A) -- `<before-heading:>`
 - (B) -- `<prepend-heading:>`
 - (C) -- `<append-heading:>`
 - (D) -- `<after-heading:>`

So, for example, suppose we want to add the name of the blog to the heading:

    <h1 class="heading">Welcome to my new blog -- The Hobo Blog</h1>
{.dryml}


To achieve that on one page, we could call the `<page>` tag like this:
    
    <page>
      <append-heading:> -- The Hobo Blog</append-heading:>
      <body:>
        ...
      </body:>
    </page>
{.dryml}

Or we could go a step further and create a new page tag that added that suffix automatically. We could then use that new page tag for an entire section of our site:

    <def tag="blog-page">
      <page>
        <append-heading:> -- The Hobo Blog</append-heading:>
        <body: param></body:>
      </page>
    </def>
{.dryml}
    
(Note: we have explicitly made sure that the `<body:>` parameter is still available. There is a better way of achieving this using `merge-params` or `merge`, which are covered later.)

## The default parameter supports append and prepend

As we've seen, the `<append-...:>` and `<prepend-...:>` parameters insert content at the beginning and end of a tag's content. But in the case of a defined tag that may output all sorts of other tags and may itself define many parameters, what exactly *is* the tag's "content"? It is whatever is contained in the `default` parameter tag. So `<append-...:>` and `<prepend-...:>` only work on tags that define a default parameter. 

For this reason, you will often see tag definitions include a `default` parameter, even though it would be rare to use it directly. It is there so that `<append-...:>` and `<prepend-...:>` work as expected.


## Replacing a parameter entirely

So far, we've seen how the parameter mechanism allows us to change the attributes and content of a tag, but what if we want to remove the tag entirely? We might want a page that has no `<h1>` tag at all, or has `<h2>` instead. For that situation we can use "replace parameters". Here's a page with an `<h2>`  instead of an `<h1>`:
    
    <page>
      <heading: replace><h2>My Awesome Page</h2></heading:>
    </page>
{.dryml}
    
And here's one with no heading at all:

    <page>
      <heading: replace/>
    </page>
{.dryml}
    
There is a nice shorthand for the second case. For every parameter, the enclosing tag also supports a special `without` attribute. This is exactly equivalent to the previous example, but much more readable:

    <page without-heading/>
{.dryml}
    
Note: to make things more consistent, `<heading: replace>` may become `<replace-heading:>` in the future.
    
## Current limitation

Due to a limitation of the current DRYML implementation, you cannot use both `before` and `after` on the same parameter. You can achieve the same effect as follows (this technique is covered properly later in the section on wrapping content):

    <heading: replace>
      ... before content ...
      <heading restore>
      ... after content ...
    </heading:>
{.dryml}


# Nested parameters

As we've discussed at the start of this guide, one of the main motivations for the creation of DRYML was to deliver a higher degree of *re-use* in the view layer. One of the great challenges of re-use is managing the constant tension between re-use and flexibility: the greater the need for flexibility, the harder it is to re-use existing code. This has a very direct effect on the *size* of things that we can successfully re-use. Take the humble hypertext link for example. A link is a link is a link -- there's only so much you could really want to change, so it's not surprising that long ago we stopped having to assemble links from fragments of HTML text. Rails has its `link_to` helper, and Hobo Rapid has its `<a>` tag. At the other extreme, reusing an entire photo gallery or interactive calendar is extremely difficult. Again no surprise--these things have been built from scratch over and over again, because each time something slightly (or very) different is needed. A single calendar component that is flexible enough to cover every eventuality would be so complicated that configuring it would be more effort than starting over.

This tension between re-use and flexibility will probably never go away; life is just like that. As components get larger they will inevitably get either harder to work with or less flexible. What we can do though, through technologies like DRYML, is slow down the onset of these problems. By thinking about the fundamental challenges to re-use, we have tried to create a language in which, as components grow larger, simplicity and flexibility can be retained longer.

One of the most important features that DRYML brings to the re-use party is *nested parameters*. They are born of the following observations:

 - As components get larger, they are not really single components at all, but compositions of many smaller sub-components.
 
 - Often, the customisation we wish to make is not to the "super-component" but to one of the sub-components.
 
 - What is needed, then, is a means to pass parameters and attributes not just to the tag you are calling, but to the tag called within the tag, or the tag called within the tag called within the tag, and so on.
 
DRYML's nested parameter mechanism does exactly that. After you've been using DRYML for some time, you may notice that you don't use this feature very often. But when you do use it, it can make the difference between sticking with your nice high-level components or throwing them away and rebuilding from scratch. A little use of nested parameters goes a long way.

## An example 

To illustrate the mechanism, we'll build up a small example using ideas that are familiar from Rapid. This is not a Rapid guide though, so we'll define these tags from scratch. First off, the `<card>` tag. This captures the very common pattern of web pages displaying collections of some kind of object as small "cards": comments, friends, discussion threads, etc.
    
    <def tag="card">
      <div class="card" merge-attrs>
        <h3 param="heading"><%= h this.to_s %></h3>
        <div param="body"></div>
      </div>
    </def>
{.dryml}

We've defined a very simple `<card>` that uses the `to_s` method to give a default heading, and provides a `<body:>` parameter that is blank by default. Here's how we might use it:

    <h2>Discussions</h2>
    <ul>
      <li repeat="@discussions">
        <card>
          <body:><%= this.posts.length %> posts</body:>
        </card>
      </li>
    </ul>
{.dryml}

This example (specifically, the collection created in the `<li repeat="@discussions">` section) demonstrates that as soon as we have the concept of a card, we very often find ourselves wanting to render a collection of `<card>` tags. The obvious next step is to capture that collection-of-cards idea as a reusable tag:

    <def tag="collection">
      <h2 param="heading"></h2>
      <ul>
        <li repeat>
          <card param>
        </li>
      </ul>
    </def>
{.dryml}

The `<collection>` tag has a straightforward `<heading:>` parameter, but notice that the `<card>` tag is also declared as a parameter. Whenever you add `param` to a tag that itself also has parameters, you give your "super-tag" (`<collection>` in this case) the ability to customise the "sub-tag" (`<card>` in this case) using *nested parameters*. Here's how we can use the nested parameters in the `<collection>` tag to get the same output as the `<li repeat="@discussions">` section in the previous example:
    
    <collection>
      <heading:>Discussions</heading:>
      <card:><body:><%= this.posts.length %> posts</body:></card:>
    </collection>
{.dryml}

This nesting works to any depth. To show this, if we define an `<index-page>` tag that uses `<collection>` and declares it as a paramater:

    <def tag="index-page">
      <html>
        <head> ... </head>
        <body>
          <h1 param="heading"></h1>
          ... 
          <collection param>
          ...
        </body>
      </html>
    </def>
{.dryml}
    
we can still access the card inside the collection inside the page:
        
    <index-page>
      <heading:>Welcome to our forum</heading:>
      <collection:>
        <heading:>Discussions</heading:>
        <card:><body:><%= this.posts.length %> posts</body:></card:>
      </collection:>
    </index-page>
{.dryml}
    
Pay careful attention to the use of the trailing ':'. The definition of `<index-page>` contains a *call* the collection tag, written `<collection>` (no ':'). By contrast, the above call to `<index-page>` *customises* the call to the collection tag that is already present inside `<index-page>`, so we write `<collection:>` (with a ':'). Remember:

 - Without ':' -- call a tag
 - With ':' -- customise an existing call inside the definition
 

# Customising and extending tags

As we've seen, DRYML makes it easy to define tags that are highly customisable. By adding `param`s to the tags inside your definition, the caller can insert, replace and tweak to their heart's content. Sometimes the changes you make to a tag's output are needed not once, but many times throughout the site. In other words, you want to define a new tag in terms of an existing tag.


## New tags from old

As an example, let's bring back our card tag:

    <def tag="card">
      <div class="card" merge-attrs>
        <h3 param="heading"><%= h this.to_s %></h3>
        <div param="body"></div>
      </div>
    </def>
{.dryml}

Now let's say we want a new kind of card, one that has a link to the resource that it represents. Rather than redefine the whole thing from scratch, we can define the new card, say, "linked-card", like this:

    <def tag="linked-card">
      <card>
        <heading: param><a href="&object_url this"><%= h this.to_s %></a></heading:>
      </card>
    </def>
{.dryml}

That's all well and good but there are a couple of problems:

 - The original card used `merge-attrs` so that we could add arbitrary HTML attributes to the final `<div>`. Our new card has lost that feature
     
 - Worse than that, the new card is in fact useless, as there's no way to pass it the body parameter
 
Let's solve those problems in turn. First the attributes. 


## `merge-attrs` again

In fact `merge-attrs` works just the same on defined tags as it does on HTML tags that are output, so we can simply add it to the call to `<card>`, like this:

    <def tag="linked-card">
      <card merge-attrs>
        <heading: param><a href="&object_url this"><%= h this.to_s %></a></heading:>
      </card>
    </def>
{.dryml}

Now we can do things like `<linked-card class="emphasised">`, and the attribute will be passed from `<linked-card>`, to `<card>`, to the rendered `<div>`.
  
Now we'll fix the parameters, it's going to look somewhat similar...


## `merge-params`

We'll introduce `merge-params` the same way we introduced `merge-attrs` -- by showing how you would get by without it. The problem with our `<linked-card>` tag is that we've lost the `<body:>` parameter. We could bring it back like this:

    <def tag="linked-card">
      <card merge-attrs>
        <heading: param><a href="&object_url this"><%= h this.to_s %></a></heading:>
        <body: param/>
      </card>
    </def>
{.dryml}

In other words, we use the `param` declaration to give `<linked-card>` a `<body:>` parameter, which is forwarded to `<card>`. But what
if `<card>` had several parameters? We would have to list them all out. And what if we add a new parameter to `<card>` later? We would have to remember to update `<linked-card>` and any other customised cards we had defined. 
    
Instead we use `merge-params`, much as we use `merge-attrs`:

    <def tag="linked-card">
      <card merge-attrs merge-params>
        <heading: param><a href="&object_url this"><%= h this.to_s %></a></heading:>
      </card>
    </def>
{.dryml}

You can read `merge-params` as: take any "extra" parameters passed to `<linked-card>` and forward them all to `<card>`. By "extra" parameters, we mean any that are not declared as parameters (via the `param` attribute) inside the definition of `<linked-card>`.
    
There are two local variables inside the tag definition that mirror the `attributes` and `all_attributes` variables described previously:
- `parameters` a hash containing all the "extra" parameters (those that do not match a declared parameter name)
- `all_parameters` a hash containing all the parameters passed to the tag 

The values in these hashes are Ruby procs. One common use of `all_parameters` is to test if a certain parameter was passed or not:

    <if test="&all_parameters[:body]">
{.dryml}

In fact, `all_parameters` and `parameters` are not regular hashes, they are instances of a subclass of `Hash` -- `Hobo::Dryml::TagParameters`. This subclass allows parameters to be called as if they were methods on the hash object, e.g.:

    parameters.default
{: .ruby}

That's not something you'll use often.

## `merge`

As it's very common to want both `merge-attrs` and `merge-params` on the same tag, there is a shorthand for this: `merge`. So the final, preferred definition of `<linked-card>` is:

    <def tag="linked-card">
      <card merge>
        <heading: param><a href="&object_url this"><%= h this.to_s %></a></heading:>
      </card>
    </def>
{.dryml}

## Merging selected parameters

Just as with `merge-attrs`, `merge-params` can be given a value - either a hash containing the parameters you wish to merge, or a list of parameter names (comma separated), to be merged from the `all_parameters` variable.

Examples:

    <card merge-params="heading, body">
    
    <card merge-params="&my_parameter_hash">
{.dryml}

## Extending a tag

We've now seen how to easily create a new tag from an existing tag. But what if we don't actually want a new tag, but rather we want to change the behaviour of an existing tag in some way, and keep the tag name the same. What we can't do is simply use the existing name in the definition:

    <!-- DOESN'T WORK! -->
    <def tag="card">
      <card merge>
        <heading: param><a href="&object_url this"><%= h this.to_s %></a></heading:>
      </card>
    </def>
{.dryml}


All we've done there is created a nice stack overflow when the card calls itself over and over. 

Fortunately, DRYML has support for extending tags. Use `<extend>` instead of `<def>`:

    <extend tag="card">
      <old-card merge>
        <heading: param><a href="&object_url this"><%= h this.to_s %></a></heading:>
      </old-card>
    </extend>
{.dryml}

The one thing to notice there is that the "old" version of `<card>`,
i.e. the one that was active before you're extension, is available as
`<old-card>`. That's about all there is to it.  `<old-card>` is only
available inside of `<extend>` -- if you need it elsewhere you can
alias the old card *before* you extend it.  (See the next chapter).

Here's another example where we add a footer to every page in our application. It's very common to `<extend tag="page">` in your application.dryml, in order to make changes that should appear on every page:
    
    <extend tag="page">
      <old-page merge>
        <footer: param>
          ... your custom footer here ...
        </footer:>
      </old-page>
    </extend>
{.dryml}


# Aliasing tags

Welcome to the shortest chapter of The DRYML Guide.

If you want to create an alias of a tag; i.e., an identical tag with a different name:

    <def tag="my-card" alias-of="card"/>
{.dryml}

Note that's a self closing tag -- there is no body to the definition.
    
So... that's aliasing tags then...


# Polymorphic tags

DRYML allows you to define a whole collection of tags that share the same name, where each definition is appropriate for a particular type of object being rendered. When you call the tag, the type (i.e. class) of the context is used to determine which definition to call. These are called polymorphic tags.

To illustrate how these work, let's bring back our simple `<card>` tag once more.
    
    <def tag="card" polymorphic>
      <div class="card" merge-attrs>
        <h3 param="heading"><%= h this.to_s %></h3>
        <div param="body"></div>
      </div>
    </def>
{.dryml}

We've added the `polymorphic` attribute to the `<def>`. This tells DRYML that `<card>` can have many definitions, each for a particular type. The definition we've given here is called the "base" definition or the "base card". The base definition serves two purposes:
    
 - It is the fallback if we call `<card>` and no definition is found for the current type.
    
 - The type-specific definition can use the base definition as a starting point to be further customised.
 
To add a type-specific `<card>`, we use the `for` attribute on the `<def>`. For example, a card for a `Product`:
    
    <def tag="card" for="Product">
      ...
    </def>
{.dryml}
    
(Note: if the name in the `for` attribute starts with an uppercase letter, is is taken to be a class name. Otherwise it is taken to be an abbreviated name registered with HoboFields; e.g., `<def tag="input" for="email_address">`)
    
For the product card, lets make the heading be a link to the product, and put the price of the product in the body area:

    <def tag="card" for="Product">
      <card merge>
        <heading: param><a href="#{object_url this}"><%= h this.to_s %></a></heading:>
        <body: param="price">$<%= this.price %></body:>
      </card>
    </def>
{.dryml}

We call this a type-specific definition. Some points to notice:

 - The callback to `<card>` is not a recursive loop, but a call to the base definition. 
     
 - We're using the normal technique for customising / extending an existing card; i.e., we're using `merge`.

It is not required for the type-specific definition to call the base definition, it's just often convenient. In fact the base definition is not required. It is valid to declare a polymorphic tag with no content:

    <def tag="my-tag" polymorphic/>
{.dryml}


## Type hierarchy

If, for a given call, no type-specific definition is available for `this.class`, the search continues with `this.class.superclass` and so on up the superclass chain. If the search reaches either `ActiveRecord::Base` or `Object`, the base definition is used.


## Specifying the type explicitly

Sometimes it is useful to give the type for the call explicitly (i.e., to override the use of `this.class`). The `for-type` attribute (on the call) provides this facility. For example, you might want to implement one type-specific definition in terms of another:

    <def tag="card" for="SpecialProduct">
      <card for-type="Product"><append-price:> (Today Only!)</append-price:></card>
    </def>
{.dryml}
 
     
## Extending polymorphic tags

Type-specific definitions can be extended just like any other tag using the `<extend>` tag. For example, here we simply remove the price:
    
    <extend tag="card" for="Product">
      <old-card merge without-price/>
    </extend>
{.dryml}


# Wrapping content

DRYML provides two mechanism for wrapping existing content inside new tags.

## Wrapping *inside* a parameter

Once or twice in the previous examples, we have extended our card tag definition, replacing the plain heading with a hyperlink heading. Here is an example call to our extended card tag:

    <card>
      <heading:><a href="#{object_url this}"><%= h this.to_s %></a></heading:>
    </card>
{.dryml}

There's a bit of repetition there -- `<%= h this.to_s %>` was already present in the original definition. All we really wanted to do was wrap the existing heading in an `<a>`. In this case there wasn't much markup to repeat, so it wasn't a big deal, but in other cases there might be much more.
    
We can't use `<prepend-heading:><a></prepend-heading:>` and `<append-heading:></a></append-heading:>` because that's not well formed markup (and is very messy besides). Instead, DRYML has a specific feature for this situation. The `<param-content>` tag is a special tag that brings back the default content for a parameter. Here's how it works:

    <card>
      <heading:><a href="#{object_url this}"><param-content for="heading"/></a></heading:>
    </card>
{.dryml}

That's the correct way to wrap *inside* the parameter, so in this case the output is:

    <h3><a href="...">Fried Bananas</a></h3>
    
What if we wanted to wrap the *entire* `<heading:>` parameter, including the `<h3>` tags?


## Wrapping *outside* a parameter
    
For example, we might want to give the card a new 'header' section, that contained the heading, and the time the record was created, like this:
    
    <div class="header">
      <h3>Fried Bananas</h3>
      <p>Created: ....</p>
    </div>
{.dryml}

To use DRYML terminology, what we've done there is *replaced* the entire heading with some new content, and the new content happens to contain the original heading. So we replaced the heading, and then restored it again, which in DRYML is written:

    <card>
      <heading: replace>
        <div class="header">
          <heading: restore/>
          <p>Created: <%= this.created_at.to_s(:short) %></p>
        </div>
      </heading:>
    </card>
{.dryml}
    
To summarise, to wrap content inside a parameter, use `<param-content/>`. To wrap an entire parameter, including the parameterised tag itself (the `<h3>` in our examples), use the `replace` and `restore` attributes.
    

# Local variables and scoped variables.

DRYML provides two tags for setting variables: `<set>` and `<set-scoped>`.
    
## Setting local variables with `<set>`

Sometimes it's useful to define a local variable inside a template or a tag definition. It's worth avoiding if you can, as we don't really want our view layer to contain lots of low-level code, but sometimes it's unavoidable. Because DRYML extends ERB, you can simply write:

    <% total = price_of_fish * number_of_fish %>
{.dryml}

For purely aesthetic reasons, DRYML provides a tag that does the same thing:

    <set total="&price_of_fish * number_of_fish"/>
{.dryml}

Note that you can put as many attribute/value pairs as you like on the same `<set>` tag, but the order of evaluation is not defined.
    
## Scoped variables -- `<set-scoped>`

Scoped variables (which is not a great name, I realise as I come to document them properly) are kind of like global variables with a limited lifespan. We all know the pitfalls of global variables, and DRYML's scoped variables should indeed be used as sparingly as possible, but you can pull off some very useful tricks with them.

The `<set-scoped>` tag is very much like `<set>` except you open it up and put DRYML inside it:
    
    <set-scoped xyz="&...">
       ...
    </set-scoped>
{.dryml}
    
The value is available as `scope.xyz` anywhere inside the tag *and in any tags that are called inside that tag*. That's the difference between `<set>` and `<set-scoped>`. They are like *dynamic variables* from LISP. To repeat the point, they are like global variables that exist from the time the `<set-scoped>` tag is evaluated, and for the duration of the evaluation of the body of the tag, and are then removed.
    
As an example of their use, let's define a simple tag for rendering navigation links. The output should be a list of `<a>` tags, and the `<a>` that represents the "current" page should have a CSS class "current", so it can be highlighted in some way by the stylesheet. (In fact, the need to create a reusable tag like this is where the feature originally came from).

On our pages, we'd like to simply call, say:

    <main-nav current="Home">
{.dryml}

And we'd like it to be easy to define our own `<main-nav>` tag in our applications:

    <def tag="main-nav">
      <navigation merge-attrs>
        <nav-item href="...">Home</nav-item>
        <nav-item href="...">News</nav-item>
        <nav-item href="...">Offers</nav-item>
      </navigation>
    </def>
{.dryml}
    
Here's the definition for the `<navigation>` tag:
    
    <def tag="navigation" attrs="current">
      <set-scoped current-nav-item="current">
        <ul merge-attrs param="default"/>
      </set-scoped>
    </def>
{.dryml}

All `<navigation>` does is set a scoped-variable to whatever was given as `current` and output the body wrapped in a `<ul>`. 

Here's the definition for the `<nav-item>` tag:

    <def tag="nav-item">
      <set body="&parameters.default"/>
      <li class="#{'current' if scope.current_nav_item == body}">
        <a merge-attrs><%= body %>
      </li>
    </def>
{.dryml}

The content inside the `<nav-item>` is compared to `scope.current_nav_item`. If they are the same, the "current" class is added. Also note the way `parameters.default` is evaluated and the result stored in the local variable `body`, in order to avoid evaluating the body twice.

### Nested scopes

One of the strengths of scoped variables is that scopes can be nested, and where there are name clashes, the parent scope variable is temporarily hidden, rather than overwritten. With a bit of tweaking, we could use this fact to extend our `<navigation>` tag to support a sub-menu of links within a top level section. The sub-menu could also use `<navigation>` and `<nav-item>` and the two `scope.current_nav_item` variables would not conflict with each other.


# Taglibs

DRYML provides the `<include>` tag to support breaking up lots of tag definitions into separate "tag libraries", known as taglibs. You can call `<include>` with several different formats:
    
    <include src="foo"/>
{.dryml}

Load `foo.dryml` from the same directory as the current template or taglib.

    <include src="path/to/foo"/>
{.dryml}

Load `app/views/path/to/foo.dryml`
    
    <include gem="foo_gem"/>
{.dryml}
    
Load `taglibs/foo_gem.dryml` inside of foo_gem.

    <include src="*"/>
{.dryml}

Wild cards are supported in Hobo 2.0.  This loads everything from the same directory as the current source except for the current source.

When running in development mode, libraries are reloaded if a change is noted.   ActiveSupport isn't completely aware of the DRYML structure; sometimes it's useful to touch the source file for the current page if you make a change to a dependent file.

# Divergences from XML and HTML

## Self-closing tags

In DRYML, `<foo:/>` and `<foo:></foo:>` have two slightly different
meanings.

The second form replaces the parameter's default inner content with the
specified content: nothing in this case.

The first form uses the parameters default inner content unchanged.

This is very useful if you wish to add an attribute to a parameter but
leave the inner content unchanged.  In this example:

    <def tag="bar">
      <div class="container" merge-attrs>
        <p class="content" param>
          Hello
        </p>
      </div>
    <def>

    <bar><foo: class="my-foo"/></bar>
{.dryml}

gives

    <div class="container">
      <p class="content my-foo">
        Hello
      </p>
    </div>
{.dryml}

If you used

    <bar><foo: class="my-foo"></foo:></bar>
{.dryml}

You would get

    <div class="container">
      <p class="content my-foo"></p>
    </div>
{.dryml}
    
## Colons in tag names

In XML, colons are valid inside tag and attribute names.   However
they are reserved for "experiments for namespaces".   So it's possible
that we may be non-compliant with the not-yet-existent XML 2.0.

## Close tag shortcuts

In DRYML, you're allowed to close tags with everything preceding the
colon:

    <view:name> Hello </view>
{.dryml}

XML requires the full tag to be specified:

    <view:name> Hello </view:name>
{.dryml}

## Null end tags

Self-closing tags are [technically
illegal](http://www.w3.org/TR/html401/intro/sgmltut.html#h-3.2.1) in
HTML.  So `<br />` is technically not valid HTML.  However, browsers
do parse it as you expect.  It is valid XHTML, though.

However, browsers only do this for _empty_ elements.  So tags such as
`<script>` and `<a>` require a separate closing tag in HTML.  This
behaviour has surprised many people.   `<script src="foobar.js" />` is
not recognized in many web browsers for this reason.  You must use
`<script src="foorbar.js"></script>` in HTML instead.

DRYML follows the XML conventions.  `<a/>` is valid DRYML.

That's all folks!

