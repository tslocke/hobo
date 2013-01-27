--- 
wordpress_id: 205
author_login: admin
layout: post
comments: 
- author: solars
  date: Thu Sep 04 07:35:57 +0000 2008
  id: 47416
  content: |
    <p>Thanks a lot Tom (&amp; others), good work as usual :)</p>

  date_gmt: Thu Sep 04 07:35:57 +0000 2008
  author_email: cb@tachium.at
  author_url: http://railsbased.org
- author: "A Fresh Cup &raquo; Blog Archive &raquo; Double Shot #284"
  date: Thu Sep 04 11:03:12 +0000 2008
  id: 47430
  content: |
    <p>[...] Hobo 0.8 Released - Still moving on towards a 1.0 release. [...]</p>

  date_gmt: Thu Sep 04 11:03:12 +0000 2008
  author_email: ""
  author_url: http://afreshcup.com/?p=936
author: Tom
title: Hobo 0.8 Released
published: true
tags: []

date: 2008-09-03 15:05:50 +00:00
categories: 
- Releases
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2008/09/03/hobo-08-released/
author_url: http://www.hobocentral.net
status: publish
---
I've just tagged v0.8 in the git repo, and released the 0.8 gems on rubyforge.

 - [Change Log](http://hobocentral.net/gems/CHANGES.txt)

Enjoy!

Expect breaking changes as always (until we get to 1.0 of course), and expect more than normal, because this is a fairly big release.

I've created a page on the github wiki to collect advice for [upgrading your existing apps](http://github.com/tablatom/hobo/wikis/upgrading-to-08). That page will grow over the next few days, but to get you started, here are the main things you definitely need to do.

### First, Hobo in general:

Upgrade gem to 1.2 (you don't *have* to do this but it's so much faster)
 
    $ gem update --system
    
Add the github gem server as a source (so you get `will_paginate`)
 
    $ gem sources -a http://gems.github.com
    
Now you can upgrade Hobo
 
    $ gem update hobo
    
### Then, for your app:

You need to run some generators again. Be careful not to overwrite your code! The 'd' option to see the differences is useful. You might want (with the user model in particular) to just create a new blank Hobo app with the `hobo` command and compare the files manually. Run these generators:
 
 - `hobo`
 - `hobo_rapid`
 - `hobo_user_model`
 - `hobo_front_controller`
    
From there, go check out [the page on the wiki](http://github.com/tablatom/hobo/wikis/upgrading-to-08)

I'll follow-up shortly (heh) with a post about what's new in 0.8.
