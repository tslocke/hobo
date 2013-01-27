--- 
wordpress_id: 403
author_login: bryanlarsen
layout: post
comments: 
- author: Ignacio Huerta
  date: Wed Sep 12 20:32:41 +0000 2012
  id: 52474
  content: |
    <p>This is great news, I just started using the integrated push-state in Hobo 1.4 and it works amazingly well :)</p>

  date_gmt: Wed Sep 12 20:32:41 +0000 2012
  author_email: ignacio@ihuerta.net
  author_url: http://www.ihuerta.net
- author: Owen
  date: Wed Sep 12 20:34:17 +0000 2012
  id: 52475
  content: |
    <p>Thanks, Bryan!</p>

  date_gmt: Wed Sep 12 20:34:17 +0000 2012
  author_email: ""
  author_url: ""
- author: "This Week in Ruby: Rails Rumble Dates, Active Admin 0.5, Protected Methods in Ruby 2.0"
  date: Fri Sep 14 22:15:46 +0000 2012
  id: 52481
  content: |
    <p>[...] Hobo 2.0.0.pre1 Released: The Web App Builder for Rails [...]</p>

  date_gmt: Fri Sep 14 22:15:46 +0000 2012
  author_email: ""
  author_url: http://www.rubyinside.com/this-week-in-ruby-early-sep-2012-5933.html
author: Bryan Larsen
title: Hobo 2.0.0.pre1 released
published: true
tags: []

date: 2012-09-12 18:23:01 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=403
author_url: http://bryan.larsen.st
status: publish
---
We're proud to announce the release of Hobo 2.0.0.pre1.

## 2.0.0.pre1

We've decided to call the next release "2.0" rather than "1.4". The
major number is justified by two major breaking changes:

- we require and heavily utilize the Rails asset pipeline
- all of our Javascript has been rewritten to use jQuery rather than prototype.js.

A full list of minor and/or potential breakages are listed in the [CHANGES document](http://cookbook-1.4.hobocentral.net/manual/changes14#changes_from_hobo_13__hobojquery_13)

There are also major new features:

- much improved theming support
- new plugin format and generators
- new caching helper tags
- push-state support
- Ajax support has been added to a large number of tags
- more flexibility in specifying Ajax parts
- new Ajax options
- new tags, such as hot-input

The full list of enhancements can be found in the [CHANGES document](http://cookbook-1.4.hobocentral.net/manual/changes14#enhancements)

## Code Freeze

The release of 2.0.0.pre1 coincides with a soft code freeze. From now
on, only bug fixes should be going into Hobo 2.0.

## Named routes

A major refactoring was done to Hobo's routing support for 2.0.0.pre1.
While doing the refactoring, we changed the names of named routes to
match standard Rails conventions.

There is a new config option config.hobo.dont_emit_deprecated_routes.
If set to false or not set at all, the old route names will be
generated as well as the new names.

Newly generated Hobo apps have config.hobo.dont_emit_deprecated_routes
set to true.

More information is [in the CHANGES document](http://cookbook-1.4.hobocentral.net/manual/changes14#named_routes_names_changed_to_use_standard_rails_names)

2.0.0.pre1 contains some code to generate URL's using both the old and
the new code and compares the result. This is slower, but will result
in quicker error detection and better backtraces. The old code will be
removed in 2.0.0.pre2.

## Other differences between 1.4.0.pre8 and 2.0.0.pre1:

- Rails 3.2 is now required
- `hobo_clean_sidemenu` theme ported from 1.3
- theme choice added to initial generator
- attribute whitelist support has been added to the generators
- renamed the jQuery-UI widget "button" to "jqbutton" to avoid aliasing the corresponding Bootstrap widget.
- sortable-input-many, create-button ported from 1.3
- document workarounds for 'update-button' and 'remote-method-button' as these won't be ported from 1.3.
- delete-button et al now properly display in-line.
- links-for-collection display a list of `view`s rather than a list of `a`s.
- before-unload option added to form tag
- ajax rendering defaults changed to match hobo_jquery.   In other words, we're now sending fewer parameters over the wire for Ajax requests.
- numerous bugfixes.   See the git log for more details.
