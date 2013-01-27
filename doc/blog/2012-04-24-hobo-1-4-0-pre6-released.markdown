--- 
wordpress_id: 387
author_login: bryanlarsen
layout: post
comments: 
- author: Owen
  date: Sat May 12 20:31:28 +0000 2012
  id: 52332
  content: |
    <p>Thanks, Bryan, Looking forward to checking it out.</p>

  date_gmt: Sat May 12 20:31:28 +0000 2012
  author_email: ""
  author_url: http://barquin.com
author: Bryan Larsen
title: Hobo 1.4.0.pre6 released
published: true
tags: []

date: 2012-04-24 15:48:31 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=387
author_url: http://bryan.larsen.st
status: publish
---
Hobo 1.4.0.pre6 has been released.   Hobo 1.4.0.pre5 did not generate the Gemfile correctly: the hobo gems were not correctly versioned, and the hobo\_clean\_admin gem was not added.   If you generated an application using Hobo 1.4.0.pre5 you can make these fixes manually rather than regenerating.

Also, to clear up one thing that I did not address in the pre5 announcement:  Hobo 1.4.0.pre5 and later do not automatically load dryml files in the app/views/taglibs/application/ directory.   If you relied on this behaviour, you can add

    <include src="application/*"/>

to your front_site.dryml or application.dryml
