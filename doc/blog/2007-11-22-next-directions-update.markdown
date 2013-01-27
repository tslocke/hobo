--- 
wordpress_id: 184
author_login: admin
layout: post
comments: 
- author: Kwahu
  date: Thu Nov 22 14:21:11 +0000 2007
  id: 16118
  content: |
    <p>WOW. Im excited ho the makers of HOBO actually use HOBO. And how often they have to get around HOBOs features ;)</p>
    
    <p>HUGS to all HOBOs out there!!!</p>

  date_gmt: Thu Nov 22 14:21:11 +0000 2007
  author_email: kwahus@gmail.com
  author_url: ""
- author: solars
  date: Thu Nov 22 14:30:45 +0000 2007
  id: 16119
  content: |
    <p>Nice idea Tom! I think this will help a lot, understanding the "Hobo Way" :)</p>

  date_gmt: Thu Nov 22 14:30:45 +0000 2007
  author_email: cb@unused.at
  author_url: http://railsbased.org
- author: Tim
  date: Thu Nov 22 15:31:49 +0000 2007
  id: 16121
  content: |
    <p>That sounds good.</p>

  date_gmt: Thu Nov 22 15:31:49 +0000 2007
  author_email: tkeller.online@googlemail.com
  author_url: http://www.innoq.com/blog/tk
- author: ""
  date: Fri Nov 23 16:28:16 +0000 2007
  id: 16222
  content: |
    <p>Great idea.  Looking forward to it!</p>

  date_gmt: Fri Nov 23 16:28:16 +0000 2007
  author_email: odal@barquin.com
  author_url: http://www.barquin.com
- author: ""
  date: Mon Nov 26 04:07:31 +0000 2007
  id: 16465
  content: |
    <p>WONDERFUL news.  Simply WONDERFUL.  This is what we've needed all along.</p>

  date_gmt: Mon Nov 26 04:07:31 +0000 2007
  author_email: ""
  author_url: ""
- author: ""
  date: Wed Nov 28 04:41:47 +0000 2007
  id: 16725
  content: |
    <p>Any updates on that site... ?</p>

  date_gmt: Wed Nov 28 04:41:47 +0000 2007
  author_email: ""
  author_url: ""
author: Tom
title: Next directions - update
excerpt: |+
  A few days ago we announced our intention to break Hobo up into various self-contained sub-projects. I just though I'd give you an update on our plans.
  
published: true
tags: []

date: 2007-11-22 14:03:37 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/11/22/next-directions-update/
author_url: http://www.hobocentral.net
status: publish
---
A few days ago we announced our intention to break Hobo up into various self-contained sub-projects. I just though I'd give you an update on our plans.

<a id="more"></a><a id="more-184"></a>

The first plan was to get started with the big break-up ASAP. That would obviously push back the documentation I've been promising to do. The idea was to provide a reasonable level of documentation for each sub-project as it was released.

Slight change of plan :-) 

I'm not in the #hobo channel all that often, but James is, just 2 meters to my left. So I'm well aware that there are a bunch of you that are determined to keep making progress with Hobo with docs or without.

With that in mind, I've come around to the idea that getting at least *some* docs out there for you folk is really the top priority. I think the best way to address this issue quickly is with some example code.

With that goal in mind, we're announcing a new project today -- beta.hobocentral.net (don't go there now, there's nothing there yet!).

We're going to build a new version of hobocentral.net in Rails + Hobo. It will have the current features: blog, forums, documentation (*cough*) etc. In time we'll add a whole host of new features like the long-promised tag library, user-extensible documentation and more. This is going to be an open-source project, and it's going to serve a dual purpose. As well as getting us a better hobocentral.net, the code will be extensively commented and the whole thing will server as a decent real-world example of how to build a Hobo app. The documentation will be implemented by the documentation. It's all a bit meta-circular, which you gotta love :-)

The point of the beta.hobocentral.net domain is that we can whack this app up really soon, and continue using the existing Wordpress based site until the new one cuts the mustard.

There is one small hold-up I'm afraid (*groan*). We've got this little outstanding DRYML issue with `CamelCaseTags`. From James' experience trying to explain template tags on #hobo, it's clear that this needs to be cleaned up right now. So I'm going to work on that first (right now in fact), and then start on beta.hobocentral.net

You should see the first cut of beta.hobocentral.net go up next week, delivering on my promise to provide some documentation in November!
