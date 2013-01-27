--- 
wordpress_id: 374
author_login: bryanlarsen
layout: post
comments: 
- author: Owen
  date: Sat Mar 31 14:08:26 +0000 2012
  id: 52243
  content: |
    <p>Great work, Bryan!</p>

  date_gmt: Sat Mar 31 14:08:26 +0000 2012
  author_email: ""
  author_url: http://barquin.com
- author: Dale Reagan
  date: Sun Apr 01 23:36:21 +0000 2012
  id: 52245
  content: |
    <p>Seems to be a Rails issue and not a Hobo issue... I am reluctant to create yet-another-account-on-yet-another-system/service... so I am posting here.  This might be useful on the 1.4 docs page (which does not allow comments...) </p>
    
    <p>Notes
    -- Hobo 1.4 pre requires Rails 3.1.x
    -- Javascript issue workaround (Centos 6.1)</p>
    
    <p>1) install Rails 3.1.x</p>
    
    <p>2) install hobo (pre)</p>
    
    <p>3) hobo new test14  (will Error out due to 'missing' gems)</p>
    
    <p>4) edit test14/Gemfile and add:
    gem 'execjs'
    gem 'therubyracer'</p>
    
    <p>5) hobo new test14 ## You will be prompted to replace files
    - Keep the Gemfile and
    - accept overwrites for everything else</p>
    
    <p>6) cd test14</p>
    
    <p>7) rails s</p>
    
    <p>8) point your browser at the instance...</p>
    
    <p>Suggests the need to:
    a) add above gems to 'default' for Hobo?
    b) add a hobo command line option to include 'special/missing' gems?</p>
    
    <p>:)
    Dale</p>

  date_gmt: Sun Apr 01 23:36:21 +0000 2012
  author_email: rhobo@ga-usa.net
  author_url: http://web-tech.ga-usa.com/
- author: Owen
  date: Mon Apr 02 19:15:45 +0000 2012
  id: 52247
  content: |
    <p>Thanks for the input, Dale!</p>

  date_gmt: Mon Apr 02 19:15:45 +0000 2012
  author_email: ""
  author_url: ""
author: Bryan Larsen
title: Hobo 1.4 beta available
published: true
tags: []

date: 2012-03-29 15:39:06 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=374
author_url: http://bryan.larsen.st
status: publish
---
We're proud to announce the release of Hobo 1.4 beta.

Install with `gem install hobo --pre`.

## Major New Features

* all prototype.js code has been removed and replaced with jQuery

* new tags to facilitate fragment caching

* Rails' asset pipeline is required

* themes may now be installed via plugins; multiple themes may be used
  per application

* plugins are first class citizens; RAPID is now supplied via a plugin

* several additional tags have gained AJAX support.  This includes, but is not limited to a, filter-menu and page-nav.

* all tags now use the standard Hobo ajax support mechanism, which used to be known as Hobo form AJAX.  The editor tags in particular have changed substantially

* part ids for AJAX updates may now be supplied implicitly or via a CSS selector

* support for AJAX file uploads

* support for push-state on AJAX requests

* new tags: nested-cache, live-editor, click-editor, formlet, hot-input, feckless-fieldset, accordion, accordion-collection, autocomplete, combobox, datepicker, dialog-box, tabs and more.

## Documentation & Installation Instructions

[Detailed documentation of the changes & Installation Instructions](http://cookbook-1.4.hobocentral.net/manual/changes14) are available on http://cookbook-1.4.hobocentral.net/.   Not all sections of that site have been updated for Hobo 1.4.   The entire taglibs section is up to date.

## Regressions

 * after-submit, sortable-input-many and name-many do not work
 * Hobo 1.4 breaks default\_scope.  If you're setting the order, you
   can use Hobo's set\_default\_order as a stopgap although once it's
   fixed please switch back to default\_scope as set\_default\_order
   is deprecated.
 * remote-method-button, create-button, update-button,
   transition-button: normal usages of these tags work, but they do
   not work if you ask them to do AJAX
 * live-search works, but it's not 'live'.  You have to press return
   to start the search
 * remove-button, remote-method-button, create-button & update-button
   used to display inline but now display as a block.   In other
   words, they now display one per line rather than several in a
   single line.
 * the rapid\_summary tags have been moved out
   of core Hobo into their own plugin,
   https://github.com/Hobo/hobo\_summary, which is not yet in a working state

The rest of the TODO list for completion of Hobo 1.4 is available here:

https://github.com/tablatom/hobo/blob/master/hobo/TODO-1.4.txt
