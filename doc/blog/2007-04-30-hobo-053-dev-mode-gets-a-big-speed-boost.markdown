--- 
wordpress_id: 153
author_login: admin
layout: post
comments: 
- author: Robert Berger
  date: Mon Apr 30 19:46:56 +0000 2007
  id: 2314
  content: |
    <p>Any tips on updating? If we used svn on install, can we just svn up?
    Need to run any scripts afterwards?</p>
    
    <p>Thanks!!!!
    Rob</p>

  date_gmt: Mon Apr 30 19:46:56 +0000 2007
  author_email: rberger@ibd.com
  author_url: ""
- author: Tom
  date: Fri May 04 13:27:36 +0000 2007
  id: 2454
  content: |
    <p>The file that often needs updating is hobo<em>rapid.js. You can do this by running the hobo</em>rapid generator again, but be careful when it asks if it's OK to overwrite this and that -  you don't want to overwrite any hand modified code!</p>

  date_gmt: Fri May 04 13:27:36 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
author: Tom
title: Hobo 0.5.3 - dev mode gets a big speed boost
excerpt: |+
  A quick release this time -- not too many changes. The reason is, I wanted to quickly get a couple of important changes to you.
  
published: true
tags: []

date: 2007-04-30 09:43:51 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/04/30/hobo-053-dev-mode-gets-a-big-speed-boost/
author_url: http://www.hobocentral.net
status: publish
---
A quick release this time -- not too many changes. The reason is, I wanted to quickly get a couple of important changes to you.

<a id="more"></a><a id="more-153"></a>

The first is a fix to a trivial but annoying bug that sneaked into 0.5.2. The `<show>` tag was playing up so that certain "magic-updates" after in-place-edits were not working, and worse, `belongs_to` and `has_many` associations were not displayed at all by `<show>`. People were hitting this as soon as they tried the screencast for themselves. Not good.
	
The second thing is more fun. Development mode just got a whole lot faster. Like Rails, in development mode DRYML reloads every taglib on every request. Because of dependencies, we even reload taglibs that haven't changed. Avoiding these reloads is actually pretty hard, but we've at least made the reload *much* faster by caching the generated ERB source.

This improvement was implemented by James -- the new guy at HoboTech, so many thanks to James.

There's a couple of smaller changes too, including stuff that you kind folk have reported in the forums. Check the changelog for details.

  * [Change Log](/gems/CHANGES.txt)
  * [hobo-0.5.3.gem](/gems/hobo-0.5.3.gem)
