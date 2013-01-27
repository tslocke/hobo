--- 
wordpress_id: 474
author_login: bryanlarsen
layout: post
comments: 
- author: Aidan
  date: Sat Dec 22 08:18:51 +0000 2012
  id: 52860
  content: |
    <p>This is fantastic guys. When will 2.0 be ready for production use?</p>

  date_gmt: Sat Dec 22 08:18:51 +0000 2012
  author_email: aidan.a.bradley@gmail.com
  author_url: ""
- author: Bryan Larsen
  date: Sat Dec 22 15:38:31 +0000 2012
  id: 52866
  content: |
    <p>As soon as the documentation and staging.hobocentral.net is ready.  If you look at the changelog on Github, you'll notice that the documentation is coming along nicely.   Volunteers are always welcome!</p>

  date_gmt: Sat Dec 22 15:38:31 +0000 2012
  author_email: bryan@larsen.st
  author_url: http://bryan.larsen.st
- author: Owen
  date: Sat Dec 22 20:04:18 +0000 2012
  id: 52868
  content: |
    <p>Excellent, Bryan!</p>

  date_gmt: Sat Dec 22 20:04:18 +0000 2012
  author_email: ""
  author_url: ""
- author: Hobo 2.0 Pre-Release 8 Uses the Twitter Bootstrap Theme and UI as Default | Agile Business Intelligence
  date: Mon Dec 31 15:31:24 +0000 2012
  id: 52888
  content: |
    <p>[...] http://hobocentral.net/blog/2012/12/21/using-hobo-2-0-without-jquery-ui/ Like this:LikeBe the first to like this. [...]</p>

  date_gmt: Mon Dec 31 15:31:24 +0000 2012
  author_email: ""
  author_url: http://agile-business-intelligence.com/2012/12/31/hobo-2-0-pre-release-8-uses-the-twitter-bootstrap-theme-and-ui-as-default/
author: Bryan Larsen
title: Using Hobo 2.0 without jQuery-UI
published: true
tags: []

date: 2012-12-21 16:11:53 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=474
author_url: http://bryan.larsen.st
status: publish
---
As of 2.0.0.pre6, Hobo can be used without jQuery-UI if you are using the `hobo_bootstrap` theme along with the `hobo_bootstrap_ui` plugin.

jQuery-UI, `hobo_jquery_ui` and `hobo_bootstrap_ui` provide various overlapping capabilities to Hobo.  This post will describe what combinations are valid, which aren't, and the capabilities provided.

## Valid combinations

You must include either `hobo_jquery_ui` or `hobo_bootstrap_ui` or both.   `hobo_jquery_ui` depends on `hobo_jquery` and `jQuery-UI`.   `hobo_bootstrap_ui` depends on `hobo_jquery` and `hobo_bootstrap`.  `hobo_bootstrap_ui` cannot be used with alternate themes, such as `hobo_clean`.

If you are using `hobo_bootstrap_ui` without `hobo_jquery_ui` you may also remove `jQuery-UI` from your system, but you will lose effects and spinner positioning.

### Defaults

As of Hobo 2.0.0.pre8, a default invocation of the Hobo generator includes all three items, with `hobo_bootstrap_ui` loaded after `hobo_jquery_ui` so that `hobo_bootstrap_ui` is preferred when there is overlap.

If a theme other than `hobo_bootstrap` is chosen, `hobo_bootstrap_ui` is not included in the application but `hobo_jquery_ui` is.

`jQuery-UI` is always included by the Hobo generator.

## Essential tags

Hobo requires three tags that are provided by both `hobo_jquery_ui` and `hobo_bootstrap_ui`:  `<search-results-container>`, `<name-one>`, and `<input for="Date">`.

If you are using both plugins, the plugin loaded last will provide these three tags.   These tags are just aliases, though: the underlying implementations will still be available.

`hobo_jquery_ui` uses `<dialog-box>`, `<name-one-jquery-ui>` and `<datepicker>` for the implementation of the essential tags.

`hobo_bootstrap_ui` uses `<modal>`, `<name-one-bootstrap>` and `<bootstrap-datepicker>` for the implementation of the essential tags.

## acts-as-list tags

`hobo_jquery_ui` provides `<sortable-collection>` and `<sortable-input-many>`, which do not have equivalents in `hobo_bootstrap_ui`.  These tags are used by Hobo if you add the `acts_as_list` plugin to a hobo model.

## Other tags

Both plugins provide other tags that you can use in your application, but which aren't ever used automatically by Hobo.

`hobo_jquery_ui` provides `<accordion>`, `<tabs>`, `<toggle>`, `<combobox>` and others.  

`hobo_bootstrap_ui` contains fewer tags, although that is likely to grow in the future.

Consult the [documentation](http://cookbook.hobocentral.net/api_plugins) for a full listing.

## Effects

If you do not use `hobo_jquery_ui` in your application, then jQuery-UI itself becomes optional.  If you remove jQuery-UI you also lose the ability to use [effects](http://cookbook.hobocentral.net/manual/ajax#effects) with part AJAX as well as the ability to position the AJAX [spinner](http://cookbook.hobocentral.net/manual/ajax#spinner)

## Removing `hobo_jquery_ui`

To remove `hobo_jquery_ui` from your application, remove references to it in `Gemfile`, `app/assets/javascripts/*.js`, `app/assets/stylesheets/*.js` and `app/views/taglibs/*_site.dryml`, and then run `bundle install`.

## Removing jQuery-UI

After `hobo_jquery_ui` is removed, you may remove jQuery-UI from your system by removing references to it in `app/assets/javascripts/application.js` and `app/assets/stylesheets/*.[s]css`.
