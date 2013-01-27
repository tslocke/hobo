--- 
wordpress_id: 272
author_login: bryanlarsen
layout: post
comments: 
- author: Owen
  date: Thu Dec 10 18:27:39 +0000 2009
  id: 51808
  content: |
    <p>Sweet! Nice improvements for imput-many...</p>

  date_gmt: Thu Dec 10 18:27:39 +0000 2009
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
author: Bryan Larsen
title: Hobo 1.0RC2 released
published: true
tags: []

date: 2009-12-10 17:42:48 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=272
author_url: http://bryan.larsen.st
status: publish
---

### Warning

If you are on Rails 2.3.5 and are running Hobo as a plugin,
please check out bug
[#574](https://hobo.lighthouseapp.com/projects/8324/tickets/574-rails-235-b0rks-our-rake-tasks-running-on-edge-hobo)
for a workaround you need to apply to your Rakefile.

### Bugs

This release fixes a couple of serious bugs:
[565](https://hobo.lighthouseapp.com/projects/8324-hobo/tickets/565)
and
[567](https://hobo.lighthouseapp.com/projects/8324-hobo/tickets/567).

### Input-Many & has-many :through

The `<input-many>` tag in Rapid has been replaced with a version
ported from the `<hjq-input-many>` tag in Hobo-JQuery.  This brings
the following enhancements:

 - it supports 0 length associations
 - input-many's may be nested inside of other input-many's
 - it allows the (+) and (-) buttons to be customized
 - it provides a default for the `item` parameter
 - it copies from a template rather than cloning the current item and clearing it
 - the template may be overridden
 - id's of textareas and selects and other non-input's are adjusted properly
 - classdata for inner elements updated

The new `<input-many>` tag differs from `<hjq-input-many>` in that:

 - it's written in prototype.js rather than in jquery
 - it doesn't have the delayed initialization feature
 - the name of the main parameter is `default` rather than `item`
 - hjq-input-many allows you to provide javascript callbacks.
   input-many fires rapid:add, rapid:change and rapid:remove events
   that can be hooked.

You will have to ensure that your hobo-rapid.js and clean.css files
are updated in your application.

### Changes

There were other minor bugs fixed.  See [the github log](http://github.com/tablatom/hobo/commits/v0.9.103)
