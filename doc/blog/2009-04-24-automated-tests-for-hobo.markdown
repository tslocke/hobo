--- 
wordpress_id: 224
author_login: bryanlarsen
layout: post
comments: 
- author: Sam Livingston-Gray
  date: Fri Apr 24 17:03:43 +0000 2009
  id: 51596
  content: |
    <p>That's very promising.  One of my major beefs with Hobo from the 0.5.x days was that the highly-factored code combined with the complete lack of tests (or if there were any, they weren't included in the plugin) made debugging unnecessarily difficult.  Perhaps I'll give Hobo another look when 1.0 comes out.</p>

  date_gmt: Fri Apr 24 17:03:43 +0000 2009
  author_email: geeksam@gmail.com
  author_url: ""
- author: Owen
  date: Mon Apr 27 11:56:27 +0000 2009
  id: 51597
  content: |
    <p>It is great to have you on board, Bryan!</p>
    
    <p>-Owen</p>

  date_gmt: Mon Apr 27 11:56:27 +0000 2009
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
- author: Hobo - The web app builder for Rails
  date: Tue Apr 28 01:02:29 +0000 2009
  id: 51599
  content: |
    <p>[...] Unit tests have been updated, and integration tests have been added. More information is available in this post. [...]</p>

  date_gmt: Tue Apr 28 01:02:29 +0000 2009
  author_email: ""
  author_url: http://hobocentral.net/blog/2009/04/28/this-week-in-edge-hobo/
- author: Hobo - The web app builder for Rails
  date: Thu May 14 23:51:16 +0000 2009
  id: 51632
  content: |
    <p>[...] Significant effort was put into unit and integration tests in this release. [...]</p>

  date_gmt: Thu May 14 23:51:16 +0000 2009
  author_email: ""
  author_url: http://hobocentral.net/blog/2009/05/14/hobo-086-released/
author: Bryan Larsen
title: Automated Tests for Hobo
published: true
tags: []

date: 2009-04-24 12:56:04 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=224
author_url: http://bryan.larsen.st
status: publish
---
I've been a sponsored member of the Hobo team for about 2 weeks now.
One of my first acts was to fix [bug
368](https://hobo.lighthouseapp.com/projects/8324/tickets/368).&nbsp; In
the process, I created [Bug
400](https://hobo.lighthouseapp.com/projects/8324/tickets/368)!&nbsp; It's
a good thing that one of my focuses will be to increase the Hobo test
coverage.

Unit Tests
----------

Hobo has a set of unit tests and doctests.&nbsp; I've updated these so that
they all pass.&nbsp; To run them:
<pre>&nbsp;&nbsp;&nbsp; rake test_all</pre>
You may have to install/upgrade rubydoctest:
<pre>&nbsp;&nbsp;&nbsp; gem sources -a http://gems.github.com
&nbsp;&nbsp;&nbsp; sudo gem install bryanlarsen-rubydoctest</pre>
Integration Tests
-----------------

I've created several integration tests for Hobo.&nbsp; Integration tests live in
[Agility](http://github.com/tablatom/agility/tree/master).

There are two different types of integration tests in Agility:
[Webrat](http://github.com/brynary/webrat/tree/master) and
[Selenium](http://seleniumhq.org/projects/on-rails/).

To run the webrat tests:
<pre>&nbsp;&nbsp;&nbsp; rake test:integration</pre>
To run the selenium tests:
<pre>&nbsp;&nbsp;&nbsp; vi config/selenium.yml&nbsp; # edit appropriately
&nbsp;&nbsp;&nbsp; script/server -e test -p 3001 &amp;
&nbsp;&nbsp;&nbsp; rake test:acceptance</pre>
