--- 
wordpress_id: 24
author_login: admin
layout: post
comments: 
- author: john
  date: Tue Jan 09 20:58:56 +0000 2007
  id: 93
  content: |
    <p>Has the fix for sqlite made it to the gem or is it just in subversion? I tried to follow along in the podcast suing sqllite 3 instead of mysql and there were blank inserts.</p>

  date_gmt: Tue Jan 09 20:58:56 +0000 2007
  author_email: vapidbabble@gmail.com
  author_url: ""
- author: Neville Franks
  date: Thu Jan 11 04:11:18 +0000 2007
  id: 102
  content: |
    <p>www.hobocentral.net displays a blank page in IE6 and IE7 which is somewhat troublesome for me. Is this deliberate?</p>

  date_gmt: Thu Jan 11 04:11:18 +0000 2007
  author_email: subs@surfulater.com
  author_url: http://www.surfulater.com
- author: Tom
  date: Thu Jan 11 11:05:25 +0000 2007
  id: 106
  content: |
    <p>No not deliberate! I recently changed the site title and messed up the close-tag on the title. Firefox obviously didn't mind but IE lost it completely :-). Sorry about that. (Fixed now)</p>
    
    <p>Clearly I'm pretty slack at testing the site in IE - now that I look there's all sorts of glitches. </p>
    
    <p>There's actually a new design on the way, so I'll make sure that works well in IE too. Sorry for any inconvenience.</p>

  date_gmt: Thu Jan 11 11:05:25 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Bill
  date: Thu Jan 11 19:36:07 +0000 2007
  id: 107
  content: |
    <p>Bug appeared in Safari too.  </p>
    
    <p>Keep up the good work on your project.</p>

  date_gmt: Thu Jan 11 19:36:07 +0000 2007
  author_email: ""
  author_url: ""
author: Tom
title: Hobo development site
excerpt: |+
  It's really tremendous news that we're starting to get a bit of a community feel going. We've had a fix for sqlite, a little [rakefile](http://hobocentral.net/forum/viewtopic.php?t=30) contributed to handle rdoc, plus some syntax fixes for that. We've had the first proper code contribution from [simondo](http://hobocentral.net/forum/viewtopic.php?t=35). And we've even had our first discussion thread where the question answerer was not me :-) Not to mention a ton of ideas and suggestions. A very big thank-you indeed to you all!
  
published: true
tags: []

date: 2007-01-08 21:19:13 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/01/08/hobo-development-site/
author_url: http://www.hobocentral.net
status: publish
---
It's really tremendous news that we're starting to get a bit of a community feel going. We've had a fix for sqlite, a little [rakefile](http://hobocentral.net/forum/viewtopic.php?t=30) contributed to handle rdoc, plus some syntax fixes for that. We've had the first proper code contribution from [simondo](http://hobocentral.net/forum/viewtopic.php?t=35). And we've even had our first discussion thread where the question answerer was not me :-) Not to mention a ton of ideas and suggestions. A very big thank-you indeed to you all!

<a id="more"></a><a id="more-24"></a>

Not to mention more than 5,000 visitors to the site in this first week of January.

So to kick-off the community involvement, I've put the development site together at [dev.hobocentral.net](http://dev.hobocentral.net).

I've got a text-file where I've been keeping notes of things that need fixing / extending, and questions that need answering, and I've started posting tickets for these. I've just done the first 17. I think there'll be about 50 all together, and that's just for starters of course.

I'm using [trac](http://trac.edgewall.com) so there's a wiki too, although I dislike the wiki-markup. I'm trying to figure out how to get it to use Markdown -- if anyone can help with that I'd much appreciate it.
