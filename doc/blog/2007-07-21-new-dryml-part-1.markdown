--- 
wordpress_id: 163
author_login: admin
layout: post
comments: 
- author: Finn Higgins
  date: Sat Jul 21 22:15:51 +0000 2007
  id: 7855
  content: |
    <p>Looking very good, Tom.  Can't wait for part 2...</p>
    
    <p>I suppose the question on everybody's mind is when this is going to make it into a release proper?  I'm building something on Hobo at the moment, so an approximate release date is going to affect my decision to pull down the preview and work to the new DRYML syntax or stick with 0.5.3 and migrate to the new syntax after launch...</p>

  date_gmt: Sat Jul 21 22:15:51 +0000 2007
  author_email: finn.higgins@gmail.com
  author_url: ""
- author: Stuart Rackham
  date: Mon Jul 30 20:35:56 +0000 2007
  id: 8260
  content: |
    <p>Hi Tom, the templates are a hugely powerful simplification, I guess you had one of those eureka moments.</p>
    
    <p>Just one thing, is merge_attrs any clearer than xattrs? Why not just attrs? The context clearly differentiates them from the  attrs and they both do deal with the notion of setting attributes.</p>
    
    <p>Looking forward to Part 2.</p>

  date_gmt: Mon Jul 30 20:35:56 +0000 2007
  author_email: srackham@methods.co.nz
  author_url: ""
- author: Stuart Rackham
  date: Tue Jul 31 01:59:29 +0000 2007
  id: 8272
  content: |
    <p>My previous comment should have read:</p>
    
    <p>... differentiates them from the  attrs ...</p>

  date_gmt: Tue Jul 31 01:59:29 +0000 2007
  author_email: srackham@methods.co.nz
  author_url: ""
- author: Stuart Rackham
  date: Tue Jul 31 02:02:24 +0000 2007
  id: 8274
  content: |
    <p>OK the, comment markup drops text in angle brackets, so without them should have read:</p>
    
    <p>... differentiates them from the def attrs ...</p>
    
    <p>Apologies for the confusion.</p>

  date_gmt: Tue Jul 31 02:02:24 +0000 2007
  author_email: srackham@methods.co.nz
  author_url: ""
- author: hachaboob
  date: Tue Jul 31 03:21:23 +0000 2007
  id: 8275
  content: |
    <p>When will Rapid generate valid [new] DRYML tags?</p>

  date_gmt: Tue Jul 31 03:21:23 +0000 2007
  author_email: hachaboob@optusnet.com.au
  author_url: ""
- author: Tom
  date: Wed Aug 01 13:06:33 +0000 2007
  id: 8363
  content: |
    <p>Stuart - the reason for having the word 'merge' in there is that it kind of equivalent to something like (in Ruby):</p>
    
    <pre><code>some_method({:foo => baa}.merge(my_options))
    </code></pre>
    
    <p>I think <code>attrs</code> by itself is a bit less clear. Especially given that you can use it without a RHS: <code><my_tag merge_attrs/></code> which means "merge any additional attributes passed to the tag I'm defining". That's by far the most common usage. </p>
    
    <p>hachaboob - soon :-)</p>

  date_gmt: Wed Aug 01 13:06:33 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Tom
  date: Wed Aug 01 13:18:06 +0000 2007
  id: 8364
  content: |
    <p>Finn - I'd suggest sticking with the 0.5.3 syntax for now and waiting for the new stuff to stabilise - it's going to be a bit experimental for a while (like the whole of Hobo!)</p>

  date_gmt: Wed Aug 01 13:18:06 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Stuart Rackham
  date: Wed Aug 01 20:09:07 +0000 2007
  id: 8391
  content: |
    <p>Tom - you are right, I just needed to read merge_attrs as a verb not a noun.</p>

  date_gmt: Wed Aug 01 20:09:07 +0000 2007
  author_email: srackham@methods.co.nz
  author_url: ""
- author: Thomas Fee
  date: Sat Aug 04 20:34:29 +0000 2007
  id: 8594
  content: |
    <p>Can't wait to try it out, but I'm a neophyte with this. After running script/plugin install svn://hobocentral.net/hobo/tags/rel_0.6-pre1, I didn't know what to do to "hook it in". I tried script/generate hobo --add-routes, but just got a NoMethodError.</p>
    
    <p>Tom, can you provide a couple of hints?</p>

  date_gmt: Sat Aug 04 20:34:29 +0000 2007
  author_email: gasbeing@gmail.com
  author_url: http://rmcsco.org
- author: bronson
  date: Thu Nov 15 22:25:18 +0000 2007
  id: 15283
  content: |
    <p>FWIW, append, prepend, before, and after have all gone away in 0.6.2+.  And it seems like merge<em>attrs, merge</em>params, and merge all do pretty much the same thing now.</p>

  date_gmt: Thu Nov 15 22:25:18 +0000 2007
  author_email: brons_hobo@rinspin.com
  author_url: http://u32.net
author: Tom
title: New DRYML - Part 1
excerpt: |+
  As I've mentioned a few times, there's lot of breaking changes in the "new DRYML". In some ways there's not a huge amount of new functionality, but we really feel it's *much* cleaner and more elegant now. I'll go over the new features in this and probably one or two further posts.
  
published: true
tags: []

date: 2007-07-21 15:42:15 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/07/21/new-dryml-part-1/
author_url: http://www.hobocentral.net
status: publish
---
As I've mentioned a few times, there's lot of breaking changes in the "new DRYML". In some ways there's not a huge amount of new functionality, but we really feel it's *much* cleaner and more elegant now. I'll go over the new features in this and probably one or two further posts.

<a id="more"></a><a id="more-163"></a>

If you want to try any of this out, Hobo 0.6-pre1 has been tagged in the repository:

 * `svn://hobocentral.net/hobo/tags/rel_0.6-pre1`
 
It's just a preview though and you'll likely encounter bugs. We won't we updating the website or releasing a gem.

# Changes to current features

Let's start by working through some features from the perspective of changing an app to work with the new DRYML.

## A bunch of names changes

The `hobolib` directory (`app/views/hobolib`) is now `taglibs`. We wanted to make Hobo feel less like an add-on and more integrated.

`<taglib>` is now `<include>`
    
The `part_id` attribute for creating ajax parts is now simply `part`. Hopefully this will help avoid some confusion about the different roles in the ajax mechanism of part names and DOM IDs.

The `xattrs` attribute for adding a hash-full of attributes to a tag in one go is now `merge_attrs`. 

## Code attributes
 
Code attributes are now signified with `&` instead of a `#`, so for example:

    <if q="&logged_in">
    
Instead of 

    <if q="#logged_in">

The reason for the change is that you can now use `#{...}` at the start of an attribute, e.g.:

    <button label="#{name} is my name" />
    
## `field` and `with` instead of `attr` and `obj`

To set the context to some field of the current context you now say `field="..."` instead of `attr="...". You can also use a new shorthand:

    <repeat:comments> ... </repeat>
    
Notice the `:comments` part is missing from the close tag (that's optional).
  
To set the context to any value, use `with="&..."` instead of `obj="#..."`

## Bye bye parameter tags, hello templates

Parameter tags used to offer an alternate syntax to attributes for passing parameters to tags, so

    <page title="My Page"/>
    
Was the same as

    <page><:title>My Page</:title></page>
    
It looks great in a simple example like that, but in practice this feature was getting messy. Looking at some DRYML code, it was far from obvious why you'd be using a `<:parameter_tag>` in one place and a `<normal_tag>` in another. And what happened when you had a tag-body *and* parameter tags? That was even messier. And what about inner tags? Are they another name for parameter tags or something different? And then there was the mysterious `content_option` and `replace_option`. Which one should I use? Why?

So now there are no parameter tags, and instead there are template tags. Templates are a new kind of tag you can define:

 * They are distinguished form normal tags because the name is in `<CamelCase>`
 * They don't have a tag-body. You never user `<tagbody>` in a template definition
 * Templates have attributes like regular defined tags. They also have *parameters*
 * A parameter is a section of content that the caller of the template can augment or replace
 * You create a parameter by adding the `param` attribute to any tag inside the template

Here's an example:

    <def tag="Page">
      <html>
        <head param="head">
          <title param="title" />
        </head>
        <body param="body">
          <div class="header" param="header" />
          <div class="main" param="main" />
          <div class="footer" param="footer" />
        </body>
      </html>
    </def>
    
(note: it's quite common that the parameter name is the same as the tag name, as in `<head param="head">`, in this case you can omit the parameter name, e.g. `<head param>`)

When calling this template, you can provide content and attributes for any of thed parameters. You can also append and prepend to parameters, or even replace parameters entirely:

    <Page>
      <title>My Page</title>
      <head.append>
        <script src="..."/>
      </head.append>
      <body onclick="runMyScript()"/>
      <header>
        ...my header...
      </header>
      <main>
        ...my content...
      </main>
      <footer.replace/>
    </Page>
    
To explain what's going on in terms of "old DRYML", it's as if *every* child of `<Page>` is a parameter tag. `<title>`, `<head>`, `<body>` etc. are neither defined tags or plain HTML tags. They are template parameters. The attributes and content of these tags are passed to the template and appear in the appropriate places.
    
Parameters can be called with various modifiers. In the above example we see `<head.append>`, which adds a script tag to the head section, and `<footer.replace/>` which replaces the footer entirely -- in this case with nothing at all, so the footer is simply removed. The full set of these modifiers is:
    
 * *append*: append content to the body of the parameter
 * *prepend*: prepend content to the body of the parameter
 * *before*: insert content just before the parameter
 * *after*: insert content just after the parameter
 * *replace*: replace the parameter entirely
 
The power really kicks in with the fact that you can nest parameters, but I think that will have to go in part 2, along with local tags, control attributes and a few other bits and bobs...
