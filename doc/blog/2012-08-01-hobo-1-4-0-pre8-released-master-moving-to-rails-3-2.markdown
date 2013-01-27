--- 
wordpress_id: 399
author_login: bryanlarsen
layout: post
comments: 
- author: Betelgeuse
  date: Wed Aug 01 16:10:19 +0000 2012
  id: 52406
  content: |
    <p>"This will be the last release supporting Rails 3.1."</p>
    
    <p>How does this relate to the 1.3.0 release that is the current "stable" version on rubygems?</p>

  date_gmt: Wed Aug 01 16:10:19 +0000 2012
  author_email: golffari@gmail.com
  author_url: ""
- author: Bryan Larsen
  date: Wed Aug 01 16:15:00 +0000 2012
  id: 52407
  content: |
    <p>This doesn't affect 1.3 at all, which will always only support rails 3.0.  I really should package up a 1.3.1 at some point that contains the current state of 1-3-stable branch.   The only major difference between 1.3.0 and 1.3.1 is some bug fixes related to deploying a Hobo app in a non-root context, aka where root_path is not set to "/".</p>

  date_gmt: Wed Aug 01 16:15:00 +0000 2012
  author_email: bryan@larsen.st
  author_url: http://bryan.larsen.st
- author: Bryan Larsen
  date: Wed Aug 01 16:45:10 +0000 2012
  id: 52408
  content: |
    <p>Just a reminder that documentation for 1.4 can be found here:  http://cookbook-1.4.hobocentral.net/</p>
    
    <p>The changes document is here:  http://cookbook-1.4.hobocentral.net/manual/changes14</p>

  date_gmt: Wed Aug 01 16:45:10 +0000 2012
  author_email: bryan@larsen.st
  author_url: http://bryan.larsen.st
- author: Betelgeuse
  date: Wed Aug 01 19:59:16 +0000 2012
  id: 52411
  content: |
    <p>My point is that you announced that 1.4 will never reach stable status which made me think that maybe 1.3 is not supported as well. The uncertainty of releases and support is what ultimately made me abandon Hobo for all new projects.</p>

  date_gmt: Wed Aug 01 19:59:16 +0000 2012
  author_email: golffari@gmail.com
  author_url: ""
- author: Bryan Larsen
  date: Wed Aug 01 20:06:08 +0000 2012
  id: 52412
  content: |
    <p>When did I say that?   We fully intend to release a 1.4.0.  As far as I'm concerned, 1.4.0 is ready for production use -- there are a couple of minor regressions that are the primary reason why 1.4.0 has not yet been released.   https://github.com/tablatom/hobo/blob/master/hobo/TODO-1.4.txt</p>

  date_gmt: Wed Aug 01 20:06:08 +0000 2012
  author_email: bryan@larsen.st
  author_url: http://bryan.larsen.st
- author: Paul Hanson
  date: Wed Aug 01 23:21:27 +0000 2012
  id: 52413
  content: |
    <p>Re: Hobo 1.4 - acts<em>as</em>list</p>
    
    <p>You guys do an awesome job! Been using Hobo for 3+ years now. I'm finally getting good enough to really  make some tracks. Thank you Bryan Larson and the rest of the team that makes this all work!</p>
    
    <p>Been using Hobo 1.3 and have a few major sized projects. Wanting to move to 1.4. I've been porting over, but not getting acts<em>as</em>list to work. I don't every recall doing anything special in 1.3 to make it work. Am I missing something?</p>
    
    <p>Soon as I add acts<em>as</em>list to a model and then run hobo g migration, I get method missing errors. I'm using ruby 1.9.3-p194 and Rails 3.1.7.</p>
    
    <p>Thanks!</p>
    
    <p>-Paul</p>

  date_gmt: Wed Aug 01 23:21:27 +0000 2012
  author_email: paulrhanson316@gmail.com
  author_url: ""
- author: Betelgeuse
  date: Thu Aug 02 10:57:14 +0000 2012
  id: 52416
  content: |
    <p>Brian: As the title was about about 1.4.0_pre8 I made the conclusion that there would be no more 1.4.x versions based on the statement: &ldquo;This will be the last release supporting Rails 3.1.&rdquo;</p>

  date_gmt: Thu Aug 02 10:57:14 +0000 2012
  author_email: golffari@gmail.com
  author_url: ""
- author: Bryan Larsen
  date: Thu Aug 02 13:45:12 +0000 2012
  id: 52418
  content: |
    <p>Paul: acts<em>as</em>list is working fine in one of our test jigs:   see the Hobo 1.4 branch of https://github.com/Hobo/agility-gitorial/tree/hobo-1.4, in the task model.   Post a backtrace to the hobo-users mailing list if you continue to have problems.</p>
    
    <p>Betelgeuse:  I should have been more explicit.   1.4.0.pre9 will support Rails 3.2.</p>

  date_gmt: Thu Aug 02 13:45:12 +0000 2012
  author_email: bryan@larsen.st
  author_url: http://bryan.larsen.st
- author: Betelgeuse
  date: Thu Aug 02 15:47:58 +0000 2012
  id: 52421
  content: |
    <p>Bryan: I would jump the version to 1.5.0.pre9 to keep the linkage between hobo version numbers and rails version numbers more explicit. It should also work better with the version restrictions people keep in their Gemfiles.</p>

  date_gmt: Thu Aug 02 15:47:58 +0000 2012
  author_email: golffari@gmail.com
  author_url: ""
- author: Bryan Larsen
  date: Thu Aug 02 15:55:39 +0000 2012
  id: 52422
  content: |
    <p>Perhaps you're right Betelgeuse, but we're still on pre, and the 3.1 -> 3.2 jump is probably the smallest jump in Rails history ever.</p>

  date_gmt: Thu Aug 02 15:55:39 +0000 2012
  author_email: bryan@larsen.st
  author_url: http://bryan.larsen.st
- author: Owen
  date: Sat Aug 04 17:09:03 +0000 2012
  id: 52432
  content: |
    <p>yes, we need some further discussion on future version numbering, but it is hard to satisfy everyone. : - 0</p>

  date_gmt: Sat Aug 04 17:09:03 +0000 2012
  author_email: ""
  author_url: http://barquin.com
- author: Owen
  date: Sat Aug 04 17:16:16 +0000 2012
  id: 52433
  content: |
    <p>Thanks much to Bryan, Paul, and Ignacio!</p>

  date_gmt: Sat Aug 04 17:16:16 +0000 2012
  author_email: ""
  author_url: http://barquin.com
- author: Betelgeuse
  date: Sat Aug 04 19:48:33 +0000 2012
  id: 52434
  content: |
    <p>Many ruby gems follow http://semver.org/ It gets my vote for Hobo as well.</p>

  date_gmt: Sat Aug 04 19:48:33 +0000 2012
  author_email: golffari@gmail.com
  author_url: ""
- author: Umuros
  date: Tue Aug 07 11:58:10 +0000 2012
  id: 52439
  content: |
    <p>To try this version, I had to learn how to install gems easily from github. Here is the summary:
    http://conceptspace.wikidot.com/blog:trying-hobo-for-rails-3-2-or-trying-an-unreleased-gem-d</p>
    
    <p>I have been looking forward to Hobo 1.4</p>

  date_gmt: Tue Aug 07 11:58:10 +0000 2012
  author_email: umur.ozkul@gmail.com
  author_url: http://conceptspace.wikidot.com/
author: Bryan Larsen
title: Hobo 1.4.0.pre8 released, master moving to Rails 3.2
published: true
tags: []

date: 2012-08-01 16:04:59 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=399
author_url: http://bryan.larsen.st
status: publish
---
I've pushed Hobo 1.4.0.pre8 to rubygems.org.  There's very little difference between 1.4.0.pre7 and 1.4.0.pre8.

- spinner fixes
- install_plugin generator fixed
- minor documentation updates
- IE7 fixes
- some tags have more param points for customization

Contributors to this release: Paul Sherwood, Ignacio Huerta and myself.

This will be the last release supporting Rails 3.1.   The master branch on github will be moving to Rails 3.2 presently.    Anybody currently using the rails-3.2 branch should move to master, as we will no longer be pushing to rails-3.2.
