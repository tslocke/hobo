--- 
wordpress_id: 195
author_login: James
layout: page
comments: []

author: James
title: A Concise Introduction to DRYML
published: true
tags: []

date: 2008-03-11 10:39:42 +00:00
categories: 
- General
author_email: james@hobocentral.net
wordpress_url: http://hobocentral.net/blog/a-concise-introduction-to-dryml/
author_url: http://
status: publish
---
This section describes the basic mechanisms of DRYML and covers the core tags and attributes
provided by the language as part of the DRYML plugin. The richer set of tags provided by
Hobo Rapid are documented elsewhere.

We begin with an example of using a tag:

    <page>
      <title:>Hi, Welcome To My Page!</title:>
      <body:>
        <h1>My Page</h1>
        <p>This is a page I wrote in DRYML</p>
      </body:>
    </page>

`<page>` is a tag that we have defined. Here is a simple example of a tag definition:
  
    <def tag="page">
      <html>
        <head>
          <title param>Default Page Title</title>
        </head>
        <body param></body>
      </html>
    </def>

A tag definition is a template consisting of HTML and calls to other DRYML tags which are evaluated when the tag is used. The tag definition can provide named "parameters" that define particular points in the content that can be modified and replaced when using the tag. In the above example we have provided two parameters "title" and "body".

---
## Tag Parameters

Parameters can be used to replace some content:

    <page>
      <title:>Hi, Welcome To My Page!</title:>
    </page>

The contents of title becomes "Hi, Welcome To My Page!" instead of "Default Page Title"

---
In addition to replacing content, parameters can be used to add attributes to a tag:

    <page>
      <body: class="my-page" id="my-id"/>
    </page>

The attributes "class" and "id" are added to `<body>` in the output HTML.

---
Parameters provide insertion points, you can add extra content before and after:

    <page>
      <after-title:>
        <meta name="description" content="my description"/>
      </after-title:>
    </page>

Adds the `<meta>` tag in the output, after `<title>`. `<before-title:>` is also available.

---
You can append and prepend to the default content:

    <page>
      <prepend-title:>My Page - </prepend-title:>
    </page>

The contents of title becomes "My Page - Default Page Title". `<append-title:>` is also available.

---
You can recall the default content of a parameter in order to perform wrapping on the content:

    <page>
      <title:>My Page - <param-content/> - My Site Name</title:>
    </page>

The content of title becomes "My Page - Default Page Title - My Site Name". `<param-content/>` is a special tag that provides the original content of the parameter being used.

---
## Nested Parameters

A more complicated example:

    <def tag="page">
      <html>
        <head param>
          <title param>Default Page Title</title>
        </head>
        <body param>
          <div class="page-header" param="page-header"></div>
          <div class="page-content" param="page-content"></div>      
        </body>
      </html>
    </def>

Here we have nested parameters in the tag definition (e.g. "title" is inside "head"). Parameter naming is also illustrated, param="page-header" defines a parameter called `<page-header:>`. If no right hand side is given
then the name of the tag that the parameter is defined on is used, e.g. `<head param>` defines a parameter called `<head:>`.
  
---
Even though parameter definitions are nested, when the tag is used the parameters are always called as direct descendants.

    <page>
      <body: class="my-body"/>
      <page-header:>My page header</page-header:>
      <page-content:>My page header</page-content:>
    </page>

Here we have added a class to `<body:>` but not replaced it's content. We have provided content for `<page-header:>` and `<page-content:>`. An important thing to note is that if we had provided content for `<body:>` then `<page-header:>` and `<page-content:>` would no longer be available because they would have been overridden by the new content for `<body:>`.

---
## The default parameter

    <def tag="section">
      <div class="section">
        <h1 param="heading"></h1>
        <div param="default"></div>
      </div>
    </def>

A parameter called "default" has a special behaviour. If you only want to use this one parameter when using the tag, you can omit the parameter all together. For example:

    <section>
      <p>My section content</p>
    </section>

is the same as: 

    <section>
      <default:><p>My section content</p></default:>
    </section>

However, you can't mix parameter tags with normal content at the top level when using a tag. So in the above example if you want to use both `<heading:>` and `<default:>` parameters you have to write:

    <section>
      <heading:>My section heading</heading:>
      <default:>My section content</default:>
    </section>

---
## The Implicit Context

Most pages display some object, and sub-sections of the page drill down into sub-objects. 
Implicit context makes this kind of page very succinct.

The initial context is set in the controller: 

    def show 
      @this = BlogPost.find(params[:id])
    end 

The current context is available via the method `this`. This allows us to define tags that operate
on `this`, for example:

    <def tag="view"><%= this %></def>

(Note that Hobo Rapid's implementation of view is a lot more complicated)

We can then call the tag which operates on the current context:

    <view/>

We can change the context to another field or association relative to the current context using the
field attribute.

    <view field="title"/>

(The context becomes `this.title` before `<view>` is evaluated)

If you don't mind that DRYML doesn't validate strictly as XML you can use a nice short hand
notation:

    <view:title/>

You can also change the current context to any arbitrary Ruby object using the `with` attribute.

    <view with="&@my_blog_post"/>

Here, `@my_blog_post` is a pre-defined Ruby instance variable. The `&` symbol at the start of the
right hand side of the attribute indicates that instead of the value of the attribute being a
string, it should be the result of evaluating the provided Ruby code.

You can put any Ruby code in the right hand side of the attribute:

    <view with="&@my_blog_post.author.name"/>

You can also combine `with` and `field`:

    <view:name with="&@my_blog_post.author"/>

Tags can also change the context, for example:

    <repeat:comments>
      <p>By <view:author.name/></p>
      <div><view:body/></div>
    </repeat:comments>

Here, `<repeat>` changes the context as it iterates over a collection.

## DRYML Core Tags

`<repeat>` is one of the few core tags provided with DRYML. The other important ones are
`<do>`, `<with>`, `<if>`, `<else>`, `<unless>`, `<include>` and `<def>`. Hobo also provides higher level 
tags in a tag library called Hobo Rapid (not described here).

---
`<do>` and `<with>` do absolutely nothing (except output their contents). They just provide you with a 
convenient way to change the context without outputting anything. For example:

    <do with="&@my_blog_post">
      <view:title/>
    </do>

    <with:title><view/></with:title>

Use `<do>` when you want to use the `with` attribute, and `<with>` when you want to use `field` (because `<with with="">` is horrible).

---
Control tags
`<if test="&conditions">`
`<else>`
`<unless test="&conditions">`

Control attributes
`<do if="&conditions">`

TODO

---
`<include>`

TODO

---
`<def>` is used to define tags. We have seen a few simple examples of using it already. This section describes some of the more advanced features. Tag and attribute names should be lower case, and should use hyphens instead of underscores to separate words.

The attributes passed to a tag when it is used are stored in a Ruby hash called `attributes`. For example:
  
    <def tag="my-heading">
      <h1><%= attributes[:title] || "Default title" %></h1>
    </def>

    <my-heading title="My Title"/>

You can also defined named attributes which are automatically assigned to Ruby local variables using `attrs`. For example:

    <def tag="my-heading" attrs="title">
      <h1><%= title %></h1>
    </def>
    
Use commas to separate a list of multiple named attributes. In the above example "title" is no longer available as `attributes[:title]`, but any other attribute passed to `<my-heading>` (non-named attributes) are still placed in the `attributes` hash.

Tags can be defined as simple aliases of other tags using the `alias-of` attribute. For example:

    <def tag="with" alias-of="do"/>
    
Tags can also redefine existing tags of the same name, and have access to the old tag definition, using the `extend-with` attribute. For example:

    <def tag="page" extend-with="custom-stylesheet">
      <page-without-custom-stylesheet merge>
        <append-head:>
          <stylesheet name="my-stylesheet"/>
        </append-head:>
      </page-without-custom-stylesheet>
    </def>

This works in the same way as `alias_method_chain` in Ruby. In the example above, the old definition of `<page>` is aliased to `<page-without-custom-stylesheet>` which can then be called by the new definition of page.
  
The attribute `merge` in the above tag definition is important. It is used to merge the parameters and attributes passed to the defined tag into the tag being called. This means that all the parameters provided by the original `<page>` definition are available from our new `<page>` definition, and all the attributes placed on `<page>` when it is used are passed through to `<page-without-custom-stylesheet>`.
