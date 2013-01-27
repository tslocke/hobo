--- 
wordpress_id: 199
author_login: admin
layout: post
comments: 
- author: Paul Davis
  date: Sun Apr 13 18:02:40 +0000 2008
  id: 31398
  content: |
    <p>Congratulations on the recent progress. Agility tutorial is very helpful and shows off Hobo well. Thanks so much for all the hard work.</p>
    
    <p>Pd</p>

  date_gmt: Sun Apr 13 18:02:40 +0000 2008
  author_email: paul@watermarktech.com
  author_url: ""
- author: Owen
  date: Sun Apr 13 18:15:57 +0000 2008
  id: 31401
  content: "<p>\"...An idea that came out of that IRC chat was to create a tutorial that starts with a full app, in &acirc;&euro;&oelig;normal Rails&acirc;&euro;\xC2\x9D style, and goes through how to gradually Hoboize it. In the view layer we could explain how to factor out all the HTML into layers of DRYML tags...\"</p>\n\n\
    <p>I think this is a great idea.</p>\n"
  date_gmt: Sun Apr 13 18:15:57 +0000 2008
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
- author: juan garcia
  date: Mon Apr 14 17:45:48 +0000 2008
  id: 31496
  content: |
    <p>The problems with the documentation are unfortunately long before DRYML. in fact the install instructions fail on win xp as you have been told in the forums.
    I tried to see what hobo is about a month ago, but it was a nigthmare of svn, plugins and paginations. Now in the promised new clean version it is just "Server error".</p>
    
    <p>Dont worry, I will try once more in a month or so...</p>

  date_gmt: Mon Apr 14 17:45:48 +0000 2008
  author_email: juangaga2@hotmail.com
  author_url: ""
- author: Tom
  date: Tue Apr 15 13:21:52 +0000 2008
  id: 31565
  content: |
    <p>juan, it seems that plenty of people have been able to get through the tutorials on Windows, but please do check the disclaimer on the front page. While many things have improved recently, we've been careful not to give the wrong impression that Hobo is now ready for beginners.</p>
    
    <p>As always, you are strongly encouraged to get confident with Rails before tackling Hobo.</p>

  date_gmt: Tue Apr 15 13:21:52 +0000 2008
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: cunha
  date: Thu May 01 14:12:28 +0000 2008
  id: 33075
  content: |
    <p>I was trying hobo and it was a very exciting experience. It is very powerfull and seems that Hobo's team are doing a great improviment on it. </p>
    
    <p>Trying it was a mix that wow this is hot, and where I must go? There is a docmentation, but it isn't enough to make an hobo app. I did a look at some hobo app and the final result is great.</p>
    
    <p>So, I think the advanced users could give a great contribuition as Owen said. In my little rails experience, rails become stronger just after some books like "Agile Web Development with Rails". </p>
    
    <p>This was my first impression. Hope this comment push those users to share their experiences.</p>
    
    <p>Thank you Tom, Hobo is great.</p>
    
    <p>Cunha.</p>

  date_gmt: Thu May 01 14:12:28 +0000 2008
  author_email: cunhajr@hotmail.com
  author_url: ""
author: Tom
title: The state of the documentation
excerpt: |+
  While chatting in the hobo IRC channel yesterday, I realised that I should probably do a blog post on the state of the documentation. We're far from done here. I don't want anyone to get the false impression that you're expected to figure out how to use Hobo from the tutorials and guides that we've posted already.
  
published: true
tags: []

date: 2008-04-12 15:56:23 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2008/04/12/the-state-of-the-documentation/
author_url: http://www.hobocentral.net
status: publish
---
While chatting in the hobo IRC channel yesterday, I realised that I should probably do a blog post on the state of the documentation. We're far from done here. I don't want anyone to get the false impression that you're expected to figure out how to use Hobo from the tutorials and guides that we've posted already.

<a id="more"></a><a id="more-199"></a>

If you wanted to use Hobo not so long ago, pretty much your only option was reading the source and asking questions. If you want to use Hobo now, you've got some reasonable docs to get you going, but you'll *still* need to read some source (especially the DRYML libraries in vendor/plugins/hobo/taglibs). Eventually, you'll be able to get by on the docs alone and everyone will be happy :-)

There's all sorts of details that we haven't documented at all, but there's two really big gaps: customising your controllers and the Rapid tag library. What I really wanted to talk about in this post is Rapid.

Rapid, in my opinion, is the best part of Hobo. You could say (and in fact I think I did somewhere or other) that everything else in Hobo exists to make Rapid possible. The combination of development speed and flexibility that Rapid brings is something I can't say I've seen anywhere else.

But there's a catch. You have to know it. And there's a lot to know: layers and layers of tags calling tags calling tags. If you know your way around it from top to bottom, you're singing. If you don't, you're probably writing way more view code than you need to. 

You should get a good sense of this from the [Agility tutorial](/agility-tutorial). Towards the end you're asked to code up bits and pieces of DRYML. These snippets seem to add functionality that far outweighs their size, but you must be thinking "how was I supposed to know *that*?!"

Some folk seem perfectly happy to read the DRYML taglibs and find their way around that way, but we really, *really* need docs for this stuff.

This is not meant as an apology, and it's not going to be a promise to deliver X by Y. It's just to let you know that those docs are very much on the to do list (and near the top), and please don't think that you're expected to just know what to do.

An idea that came out of that IRC chat was to create a tutorial that starts with a full app, in "normal Rails" style, and goes through how to gradually Hoboize it. In the view layer we could explain how to factor out all the HTML into layers of DRYML tags. That would not only show how to use bits and pieces from Rapid, but would also illustrate *why* Rapid is like it is. It would throw a lot of light on the whole of Hobo in fact. Could be a lot of work though, so don't hold your breath until it's ready :-)

p.s. On the subject of docs I just noticed that the HoboSupport docs are messed up -- there's a whole bunch of pages that aren't linked to. like [this one](/hobosupport/hobosupport/enumerable/) for example. Will fix!
