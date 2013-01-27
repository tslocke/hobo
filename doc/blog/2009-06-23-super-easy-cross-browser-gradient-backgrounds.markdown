--- 
wordpress_id: 248
author_login: admin
layout: post
comments: 
- author: Me
  date: Wed Jun 24 14:12:19 +0000 2009
  id: 51692
  content: |
    <p>V. cool!</p>

  date_gmt: Wed Jun 24 14:12:19 +0000 2009
  author_email: me@blah.com
  author_url: ""
- author: Flow &raquo; Blog Archive &raquo; Daily Digest for June 26th - The zeitgeist daily
  date: Fri Jun 26 03:22:54 +0000 2009
  id: 51693
  content: |
    <p>[...] Hobo - The web app builder for Rails &mdash; 9:21am via [...]</p>

  date_gmt: Fri Jun 26 03:22:54 +0000 2009
  author_email: ""
  author_url: http://clair.ro/flow/2009/06/26/daily-digest-for-june-26th/
- author: Owen
  date: Sun Jun 28 16:08:14 +0000 2009
  id: 51695
  content: |
    <p>Slick!  Seems like a small thing, but makes the apps out-of-the-box look very cool.</p>

  date_gmt: Sun Jun 28 16:08:14 +0000 2009
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
author: Tom
title: Super-easy cross-browser gradient backgrounds
published: true
tags: []

date: 2009-06-23 22:30:24 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2009/06/23/super-easy-cross-browser-gradient-backgrounds/
author_url: http://www.hobocentral.net
status: publish
---
![screen shot](http://img.skitch.com/20090624-mkn8q4q4qpg74b54jfacmgbnie.jpg)

Hobo 0.8.8 is coming very soon, consisting mostly of bug fixes and bringing us that bit closer to the hallowed version 1.0. While we're waiting, I though I'd quickly let you know about a very simple Rails plugin I knocked up that makes it extremely easy to add gradient background images to your stylesheets. (If you follow the hobousers group you've already seen a mention of this.)

For example:

    div.featured { background: url(/gradient_images/50:aaa:fff.png) repeat-x white; }

All that's happening is that the plugin is rendering a PNG image on the fly; 1 pixel wide, 50 high, with a gradient from a light grey (`#aaa`) to white. It renders the image you would otherwise have to make yourself in Photoshop or whatever.

The general pattern for the image URL is:

    /gradient_images/<height>:<start-color>:<end-color>.<format>
    
Colours are 3 or 6 digit hex values, as in CSS. The format can be anything supported by ImageMagick (e.g. `png` or `jpg`).

You can also do multiple gradients in the same image, like this

    div.featured {
      height: 100px;
      background: url(/gradient_images/50:aaa:fff::50:fff:aaa.png) repeat-x 
    }

That will give an image 100 pixels high fading from grey to white and back to grey.

Note that you only take the performance hit on the first request, after that the images will be served up directly by your web server thanks to Rails' page caching. You'll see a bunch of image files in `public/gradient_images`.

Requires Rails 2.3 and RMagick.

The plugin is [available on github](http://github.com/tablatom/gradient_server).

UPDATE: We just threw up a [quick example app on github](http://github.com/Barquin/hobo-gradient-demo/tree/master). It's great to see how much nicer you can make the default Hobo app look with [just three CSS declarations](http://github.com/Barquin/hobo-gradient-demo/blob/6e992076824d243f22a6c8d0aa73c997447050bf/public/stylesheets/application.css).
