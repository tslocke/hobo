--- 
wordpress_id: 148
author_login: admin
layout: post
comments: 
- author: Jeff
  date: Tue Apr 03 15:57:54 +0000 2007
  id: 1331
  content: |
    <p>Thanks Tom! I'm going to give it a try in a new project today.</p>

  date_gmt: Tue Apr 03 15:57:54 +0000 2007
  author_email: ""
  author_url: ""
- author: kaspar
  date: Wed Apr 04 14:07:05 +0000 2007
  id: 1349
  content: |
    <p>A short writeup on that topic is also here: http://neotrivium.com/blog/2007/4/4/out<em>of</em>the<em>scope</em>of<em>scope</em>out?language=en-US</p>

  date_gmt: Wed Apr 04 14:07:05 +0000 2007
  author_email: kaspar@neotrivium.com
  author_url: http://neotrivium.com
- author: kaspar
  date: Wed Apr 04 14:10:03 +0000 2007
  id: 1350
  content: |
    <p>Ok, that was a bad idea, the link again: 
    <a href="http://neotrivium.com/blog/2007/4/4/out_of_the_scope_of_scope_out?language=en-US" rel="nofollow">scoped proxies at neotrivium.com</a></p>

  date_gmt: Wed Apr 04 14:10:03 +0000 2007
  author_email: kaspar@neotrivium.com
  author_url: http://neotrivium.com
- author: GSIY &#8230; Ruby-Rails Portal
  date: Wed Sep 05 00:40:46 +0000 2007
  id: 10130
  content: |
    <p>[...] Hobo creator insists you check out scope out&acirc;&euro;&brvbar; Here&acirc;&euro;&trade;s why [...]</p>

  date_gmt: Wed Sep 05 00:40:46 +0000 2007
  author_email: ""
  author_url: http://www.gsiy.com/scope-and-ruby-on-rails-scope_out-and-more/
- author: "A Fresh Cup &raquo; Blog Archive &raquo; Double Shot #31"
  date: Tue Jan 01 14:39:36 +0000 2008
  id: 19970
  content: |
    <p>[...] Scope Out ActiveRecord Conditions- A way to clean up code that needs to work with conditions in ActiveRecord. Bears investigating. (via Tom) [...]</p>

  date_gmt: Tue Jan 01 14:39:36 +0000 2008
  author_email: ""
  author_url: http://afreshcup.com/?p=595
author: Tom
title: Go get scope_out - it should be in core!
published: true
tags: []

date: 2007-04-03 07:26:02 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/04/03/go-get-scope_out-it-should-be-in-core/
author_url: http://www.hobocentral.net
status: publish
---
The [`scope_out`](http://www.dcmanges.com/blog/21) plugin is such a great extension to ActiveRecord I can't imagine any non-trivial app not benefiting from it.

I have just two reservations: I would have thought it could be named better (OK that's a niggle), and the customised `with_scope` methods it creates (e.g. `with_active`), should really be protected. Why? See [this thread](http://groups.google.com/group/rubyonrails-core/browse_frm/thread/a8e60f340a682977/).
