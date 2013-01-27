--- 
wordpress_id: 211
author_login: admin
layout: post
comments: 
- author: solars
  date: Wed Oct 15 11:26:58 +0000 2008
  id: 49365
  content: |
    <p>cool, some really nice enhancements</p>
    
    <p>thank you :)</p>

  date_gmt: Wed Oct 15 11:26:58 +0000 2008
  author_email: cb@tachium.at
  author_url: http://railsbased.org
- author: MartOn
  date: Thu Oct 16 10:41:59 +0000 2008
  id: 49399
  content: |
    <p>Maybe a few words on how to upgrade hobo on existing projects would be nice?</p>

  date_gmt: Thu Oct 16 10:41:59 +0000 2008
  author_email: frode@meling.name
  author_url: ""
- author: sinobra
  date: Thu Oct 16 13:37:08 +0000 2008
  id: 49402
  content: |
    <p>I downloaded the latest, and started working through the agility tutorial.  Got to the point where I try to create tasks, and got this error:</p>
    
    <p>ActiveRecord::HasManyThroughSourceAssociationMacroError in TasksController#new 
    Invalid source reflection macro :has<em>many :through for has</em>many :users, :through => :task_assignments.  Use :source to specify the source reflection.</p>
    
    <p>Any ideas?</p>

  date_gmt: Thu Oct 16 13:37:08 +0000 2008
  author_email: sinobra@gmail.com
  author_url: ""
author: Tom
title: Hobo 0.8.3 released
published: true
tags: []

date: 2008-10-15 11:05:55 +00:00
categories: 
- Releases
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2008/10/15/hobo-083-released/
author_url: http://www.hobocentral.net
status: publish
---
I've just released Hobo 0.8.3. Various bug fixes, plus a few nice new features, including much better support for multi-model forms. See the [changes](/gems/CHANGES.txt) for the details.Please remember that Rubyforge takes a good while to get with the program, so `gem update hobo` might not work for a while. You can download the gem files from Rubyforge manually though.Enjoy!
