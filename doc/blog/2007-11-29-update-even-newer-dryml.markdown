--- 
wordpress_id: 185
author_login: admin
layout: post
comments: 
- author: BradfordW
  date: Thu Nov 29 16:00:44 +0000 2007
  id: 16905
  content: |
    <p>Get us your address, so we can send food, caffeine and a chair with an integrated toilet.  Keep up the fantastic work guys!</p>

  date_gmt: Thu Nov 29 16:00:44 +0000 2007
  author_email: bradswinfrey@yahoo.com
  author_url: ""
- author: yak
  date: Thu Nov 29 18:01:16 +0000 2007
  id: 16914
  content: |
    <p>hmmm...</p>
    
    <p>something about "write unit tests before code" comes to mind...</p>
    
    <p>and the older "write documentation before design".....
    (remember Donald Knuth &amp; literate programming?)</p>
    
    <p>well, this perhaps also comes to mind "do as I say, not as I do!"  :-)</p>

  date_gmt: Thu Nov 29 18:01:16 +0000 2007
  author_email: yarkot1@gmail.com
  author_url: http://hobocentral.net
- author: Tom
  date: Thu Nov 29 18:06:12 +0000 2007
  id: 16915
  content: |
    <p>Documentation before design?? Are you sure that's what the man meant? ;o)</p>

  date_gmt: Thu Nov 29 18:06:12 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Owen
  date: Thu Nov 29 21:17:18 +0000 2007
  id: 16929
  content: |
    <p>Awesome.  Keep up the great work!</p>

  date_gmt: Thu Nov 29 21:17:18 +0000 2007
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
author: Tom
title: Update - Even newer DRYML
published: true
tags: []

date: 2007-11-29 13:26:00 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/11/29/update-even-newer-dryml/
author_url: http://www.hobocentral.net
status: publish
---
The big feature back in Hobo 0.6 was "new DRYML" -- A substantial improvement to the mark-up language that introduced the idea of "templates" - tags that can be given multiple, named blocks of content instead of just a single "tagbody".

As I've mentioned a couple of times, we're now working on another improvement to DRYML that unifies template tags and "normal" tags, and we're switching to `<tags-with-dashes>` while we're at it.

I've got all the DRYML tests passing now, and I've written a Rake task that does a pretty good job of automatically updating all your existing DRYML source to the new style. I've now got to put this new stuff through the wringer by making sure the test suites of our existing Hobo apps are all still fully green. Then Hobo 0.7 will be released!

I'll then have my decks clear to move on to beta.hobocentral.net and you'll finally have some documentation so you can find out what on earth I'm talking about :-). Obviously I've not managed to put the time into documentation that I'd hoped to in November, but I'd still like to make good on my promise by getting *something* out. Looks like the deadline is tomorrow :-). Wish me luck!
