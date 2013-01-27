--- 
wordpress_id: 384
author_login: bryanlarsen
layout: post
comments: 
- author: Edson
  date: Mon Apr 23 15:57:19 +0000 2012
  id: 52280
  content: |
    <p>Very good news Mr. Bryan.</p>
    
    <p>I'll give it a try in my brand new ubuntu environment.</p>
    
    <p>Good job.</p>
    
    <p>Edson</p>

  date_gmt: Mon Apr 23 15:57:19 +0000 2012
  author_email: edsonteixeira@cabosys.cv
  author_url: http://cabosys.cv
- author: Owen
  date: Mon Apr 23 17:47:34 +0000 2012
  id: 52281
  content: |
    <p>Nice job, Bryan!</p>
    
    <p>-Owen</p>

  date_gmt: Mon Apr 23 17:47:34 +0000 2012
  author_email: ""
  author_url: ""
author: Bryan Larsen
title: Hobo 1.4.0.pre5 released
published: true
tags: []

date: 2012-04-23 15:04:08 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=384
author_url: http://bryan.larsen.st
status: publish
---
I'm pleased to announce that Hobo 1.4.0.pre5 has been released.

The major change in pre5 is that application.dryml is not necessarily loaded automatically any more.  You will need to add an <code><include src="application"></code> to your front_site.dryml and/or admin_site.dryml.   If you don't have any X_site.dryml files in app/views/taglibs, you will not need to make any changes.

New Hobo applications generated with 1.4.0.pre5 will incorporate this change.

To upgrade to pre5, change references from "pre4" to "pre5" in your Gemfile and run <code>bundle install</code>.   If you reference hobo via :git in your gemfile, you can upgrade by running <code>bundle update --source hobo</code>

Other changes include bugfixes for table-plus, feckless-fieldset, input for="EnumString", live-search, default_scope, accordion, tabs, hobo_jquery_ui styling, select-many.

There are two new tags:  accordion-list & toggle, and support was added for the hobo_tokeninput plugin.

[Documentation for 1.4 is available in the cookbook.](http://cookbook-1.4.hobocentral.net/manual/changes14)
