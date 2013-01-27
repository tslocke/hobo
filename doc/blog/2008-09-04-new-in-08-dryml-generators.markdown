--- 
wordpress_id: 206
author_login: admin
layout: post
comments: 
- author: Andy Orahood
  date: Fri Sep 05 02:30:18 +0000 2008
  id: 47500
  content: |
    <p>It may be easy for you to understand but I'm having a lot of trouble with it. I'm sure you're used to this by now, but please work on some documentation for DRYML syntax. It appears to me that DRYML attempts to pack a lot of expressive power into an XML syntax by subtly co-opting things like namespace notation and attribute. Right now I believe that there will be a great payoff to blurring the distinction between markup and logic, but the learning curve is made much steeper because of the confusion this conflation causes. I often find myself looking at DRYML and at first blush thinking I see what it does because it just looks like markup, but the longer I stare at it the more I realize that I don't follow the logic at all.</p>
    
    <p>As an example, my understanding of parameter syntax is that inside that definition of  above, you define tags by using the param attribute inside a tag, and you invoke tags by appending a colon to the name of the defined parameter. So I don't understand the tags where you both append a colon and use the param attribute. I.e.:</p>
    
    <p>... = defining a 'heading' tag</p>
    
    <p>stuff = using the 'heading' tag</p>
    
    <p> = ??? (defining and using together?)</p>

  date_gmt: Fri Sep 05 02:30:18 +0000 2008
  author_email: jorahood@indiana.edu
  author_url: ""
- author: Andy Orahood
  date: Fri Sep 05 02:32:30 +0000 2008
  id: 47501
  content: |
    <p>oops, didn't do the markdown formatting. The examples should be
        ... = defining a 'heading' tag</p>
    
    <pre><code><heading:>stuff</heading:> = using the 'heading' tag
    
    <content: param> = ??? (defining and using together?)
    </code></pre>

  date_gmt: Fri Sep 05 02:32:30 +0000 2008
  author_email: jorahood@indiana.edu
  author_url: ""
- author: Andy Orahood
  date: Fri Sep 05 02:33:22 +0000 2008
  id: 47502
  content: |
    <p>If at first you don't succeed...</p>
    
    <pre><code><h2 param='heading'>...</h2> = defining a 'heading' tag
    
    <heading:>stuff</heading:> = using the 'heading' tag
    
    <content: param> = ??? (defining and using together?)
    </code></pre>

  date_gmt: Fri Sep 05 02:33:22 +0000 2008
  author_email: jorahood@indiana.edu
  author_url: ""
- author: solars
  date: Fri Sep 05 08:09:29 +0000 2008
  id: 47528
  content: |
    <p>Great explanation Tom, I think the generators will be very helpful to get startet with dryml.</p>
    
    <p>Andy:
    There already is dryml documentation available at http://hobocentral.net/docs/dryml/ which should explain the usage you are questioning.</p>
    
    <p>'param' marks a tag that can be reused later, eg. param="heading" marks a param called 'heading' which can then be reused using the colon syntax: fubar</p>

  date_gmt: Fri Sep 05 08:09:29 +0000 2008
  author_email: cb@tachium.at
  author_url: http://railsbased.org
- author: Tom
  date: Fri Sep 05 12:03:30 +0000 2008
  id: 47540
  content: |
    <p>Andy - <code><content: paramm></code> is exactly that - you're passing a parameter to the tag that you're calling, and you're also making that parameter available to the tag you are defining.</p>
    
    <p>Please dive in to the forums if you've still got questions after checking out the docs. It's easier to handle detailed questions like these over there.</p>

  date_gmt: Fri Sep 05 12:03:30 +0000 2008
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Owen
  date: Mon Sep 08 01:50:03 +0000 2008
  id: 47676
  content: |
    <p>Yes, Tom. Time for some short-and-sweet screencasts!</p>

  date_gmt: Mon Sep 08 01:50:03 +0000 2008
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
author: Tom
title: New in 0.8 - DRYML Generators
excerpt: |+
  There's a ton of new stuff in Hobo 0.8, mainly in the area of DRYML and the Rapid tag library. This post is the first in a short series that will give an overview of what's new, what's changed and why.
  
published: true
tags: []

date: 2008-09-04 10:44:51 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2008/09/04/new-in-08-dryml-generators/
author_url: http://www.hobocentral.net
status: publish
---
There's a ton of new stuff in Hobo 0.8, mainly in the area of DRYML and the Rapid tag library. This post is the first in a short series that will give an overview of what's new, what's changed and why.

<a id="more"></a><a id="more-206"></a>

## DRYML Generators

This is the big change in 0.8 -- we've started using generators (*gasp!*) to create the automatic pages. If you've not been following along, you might wonder why the gasp. Well, we've always been quite opposed to using generators to automatically create a user-interface for your app. The reason being is that generators are really nothing more than copy-paste code re-use. Which as I'm sure you know is a terribly evil sin : ). The point being that if you've got five copies of something, and you want to change it, you've got to change it in five places, which is both tedious and error-prone.

Having said that, there's one thing that generators are really great at, and that's helping you *learn*. When you're new to Rails itself, for example, it's really useful to be able to look at the restful controller created by the scaffold generator. You learn at a glance how you're supposed to use the provided API.

When it comes to DRYML, a natural first step when wanting to customise something in the UI, is to look at the source for that tag definition. The problem is that lots of the tags within the Rapid library are very unusual. Unusual in the sense that they're not like the kind of tags that you would typically define in your own application. That's because these tags have been written with no knowledge whatsoever of your application, they're entirely generic. A good example is `<show-page>`, which does a remarkable job of presenting a reasonable looking page for any model that you throw at it. OK so you want to customise your `<show-page>`, so you go look at the source. Uh oh. All the logic for handling that generic magic is right there in the tag definition. As a result, we've noticed people copy some of these generic tricks into their own apps. This is really not a good idea -- your app does not need to be generic, it's specific to what you are doing. 

So we don't want DRYML generators because we don't want DRYML to become WETML, but we would really like a generator-like approach to making DRYML, and Rapid, easier to learn. Here's what we came up with...

The parts of Rapid that were very generic: the pages, cards and forms, are now generated. You can go look at the source code. You'll find very simple code that's been tailored to your application and is a good guideline for how you should write your own tags. But there's a twist. The problem with generators is -- what happens when things change. Easy! We just generate again and overwrite the old tags. Huh? What about my edits? That's the twist - you don't make any.

The generated taglibs are all written out under the directory `app/views/taglibs/auto`, and the rule is -- you don't edit anything within that directory. Instead, you use the powerful features that DRYML gives you to customise those tags. You can either extend them, which you'd probably do in `application.dryml` (using the new `<extend>` tag), or, you just call them and use DRYML's parameter mechanism to tweak things to your needs.

This post is just to give you a heads-up of the thinking behind this feature, not to document how it all works, but here's a quick example. Suppose you have a Story model, which has a title, and Rapid has automatically given you a show-page that uses that title as the main heading. But that's not exactly what you want -- you want the heading to always start with "Story:".

So you mosey over to `app/views/taglibs/auto/rapid/pages.dryml` and find the tag definition for this page. It might look like this:

    <def tag="show-page" for="Story">
      <page merge title="Story">

        <body: class="show-page story" param/>

        <content: param>
          <header param="content-header">
            <a:project param="parent-link">&laquo; <name/></a>
            <h2 param="heading"><name/></h2>

            <a action="edit" if="&can_edit?" param="edit-link">Edit Story</a>
          </header>

          <section param="content-body">
            <view:body/>        
            <field-list fields="status" param/>
          </section>
        </content:>

      </page>
    </def>
    
That is *much* easier to understand than the old fully-generic definition of `<show-page>`. If you never saw it, take my word for it - it was scary : ). We can clearly see that `<show-page>` is calling `<page>`, adding a title, a couple of css classes to the `<body>` and some main content using the `<content:>` parameter. The content section itself is also very straightforward -- we can see a header and a body, a link back to the owning project, the heading in an `<h2>` tag, the edit link, and so on.
    
OK so we want to add that "Story:" prefix to the heading. Well we can clearly see that the `<h2>` in question is parameterised -- the parameter is `heading`. So, thanks to the magic of DRYML, we can simply create our `app/views/stories/show.dryml` as follows:
    
    <show-page>
      <prepend-heading:>Story: </prepend-heading:>
    </show-page>
    
Now that's not *quite* as obvious as simply hacking on the generated file, but once you get used to DRYML's parameter mechanism, it's really very easy. The beauty is what happens when you change your app. Say, for example, you decide you don't want an edit page for stories, so you remove that action in the controller. The page generators are re-run automatically, and the edit link will disappear from your show-page. You've got the best of both worlds: the ease of learning that you get from generators, and the flexibility to change that Hobo has always had.

I'm pretty excited about this change. I think it will take the ease of working with Hobo to a whole new level, and we really haven't compromised any flexibility.  How's that for change we can believe in ;o).
