--- 
wordpress_id: 28
author_login: admin
layout: post
comments: 
- author: Peter Nord
  date: Wed Jan 17 20:54:45 +0000 2007
  id: 157
  content: |
    <p>I been following the development of Hobo for a while now and I must say it is impressing. </p>
    
    <p>However, I wouldn't want to see Hobo makes the same mistakes like other great projects (Streamlined, Rails Engine, Various template plugins and other ground breaking CMS and what not project). Most of these above mentioned project are dying or dead or has about 5 to 7 hard core developers with no community.</p>
    
    <p>Fundamentaly they all have one thing in common - They all promises a bundle and pump in bleeding edge features without explaining those bleeding edge features to users i.e. lack of documentation thus they fail to build a community.</p>
    
    <p>I hope hobo doesn't make the same mistake. I really hope the development team focus on bringing more and more documentation instead of features, cos this features will come from the community when the docs are there to support community development.</p>
    
    <p>Just some thoughts!</p>

  date_gmt: Wed Jan 17 20:54:45 +0000 2007
  author_email: peter.nord@gmail.com
  author_url: ""
- author: Ed Chang
  date: Thu Jan 18 16:00:47 +0000 2007
  id: 159
  content: |
    <p>Tom,</p>
    
    <p>Just wanted to let you know that I think Hobo is pretty darn nifty. You're doing great work.</p>
    
    <p>Ed</p>

  date_gmt: Thu Jan 18 16:00:47 +0000 2007
  author_email: edchang@quoqua.com
  author_url: ""
- author: Tom
  date: Thu Jan 18 17:07:48 +0000 2007
  id: 160
  content: |
    <p>Peter - you're absolutely right.</p>
    
    <p>Hobo will be very well documented -- I promise. It might take a while to get there but we'll definitely get there. For my last open-source project, I once put a day aside to write a quick tutorial, and ended up spending the whole week writing a 100-page mini-book. We'll get there.</p>
    
    <p>Ed - Thanks very much!</p>

  date_gmt: Thu Jan 18 17:07:48 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Tim Chater
  date: Thu Jan 18 17:19:43 +0000 2007
  id: 161
  content: |
    <p>Great work Tom - it's good to see Hobo progress!</p>
    
    <p>I've just tried following along with the pod screencast but came across a problem when trying to use the app. I've spotted what looks like an typo on lines 190 and 195 of vendor/plugins/hobo/lib/hobo.rb - 'check<em>persmission' instead of 'check</em>permission'...</p>
    
    <p>Changing these seems to have fixed the problem.</p>
    
    <p>Keep up the good work!</p>

  date_gmt: Thu Jan 18 17:19:43 +0000 2007
  author_email: t.chater@sheffield.ac.uk
  author_url: ""
- author: ""
  date: Fri Jan 19 13:49:49 +0000 2007
  id: 162
  content: |
    <p>What happened to Logix? Just soooo 2004 I guess.</p>

  date_gmt: Fri Jan 19 13:49:49 +0000 2007
  author_email: ""
  author_url: ""
- author: Andy Goundry
  date: Mon Jan 22 11:22:48 +0000 2007
  id: 177
  content: |
    <p>Documentation, hmmm... Maybe i could help? I'm kinda used to writing readable technical docs and would enjoy documenting Hobo.</p>
    
    <p>Tom, what would be the best way to help out in this area?</p>
    
    <p>PS - It's great to see the project progressing so well. Great work to all involved (all contributors as you all count toward the success). I'm certain that Hobo is in NO DANGER of failing to gain a community. The direction is clear, support strong and quality high. Gotta be a winner :-)</p>

  date_gmt: Mon Jan 22 11:22:48 +0000 2007
  author_email: andy@adveho.net
  author_url: http://www.adveho.net
- author: Jeff
  date: Wed Jan 24 15:24:18 +0000 2007
  id: 185
  content: |
    <p>Confirmed Tim. Didn't have to bother searching for the source of the check_persmission error thanks to you. Pod runs great using 0.4.2 with Tim's quick change to hobo.rb</p>

  date_gmt: Wed Jan 24 15:24:18 +0000 2007
  author_email: robots7000@yahoo.ca
  author_url: ""
- author: Tom
  date: Fri Jan 26 14:13:25 +0000 2007
  id: 198
  content: |
    <p>Tim - thanks for reporting that - now fixed in Hobo 0.4.3</p>

  date_gmt: Fri Jan 26 14:13:25 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
author: Tom
title: Breaking Change
published: true
tags: []

date: 2007-01-17 18:11:02 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/01/17/breaking-change/
author_url: http://www.hobocentral.net
status: publish
---
We do reserve the right to make breaking changes at this stage in the game you know :-)

The `login` attribute in the default user model has been renamed to `username`. (a nice easy way to change this has been added too). You might need to rattle off a quick migration to rename that column in your database in order to keep things working.
