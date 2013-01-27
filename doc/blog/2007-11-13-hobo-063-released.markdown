--- 
wordpress_id: 180
author_login: admin
layout: post
comments: 
- author: solars
  date: Tue Nov 13 17:53:30 +0000 2007
  id: 14909
  content: |
    <p>Sounds very nice! Can't wait to test it, thanks a lot! :)</p>

  date_gmt: Tue Nov 13 17:53:30 +0000 2007
  author_email: cb@tachium.at
  author_url: http://railsbased.org
- author: ylon
  date: Wed Nov 14 02:01:11 +0000 2007
  id: 14940
  content: |
    <p>Very exciting news Tom.  Thanks for your hard work.</p>
    
    <p>Now, with regards to the theme issues that will be addressed in .7, what type of counsel do you have for us with this release?  Should we be nervous that we will have to rewrite our themes once .7 comes around the corner or will those themes remain functional or should we simply steer clear of theming our apps until .7?</p>

  date_gmt: Wed Nov 14 02:01:11 +0000 2007
  author_email: lists@southernohio.net
  author_url: ""
author: Tom
title: Hobo 0.6.3 released
excerpt: |
  OK finally got it out there. Hobo 0.6.3 is mainly a whole load of small improvements. There are many breaking changes as always. Here's a quick heads up on some things to watch out for:
  

published: true
tags: []

date: 2007-11-13 17:21:16 +00:00
categories: 
- Releases
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/11/13/hobo-063-released/
author_url: http://www.hobocentral.net
status: publish
---
OK finally got it out there. Hobo 0.6.3 is mainly a whole load of small improvements. There are many breaking changes as always. Here's a quick heads up on some things to watch out for:

<a id="more"></a><a id="more-180"></a>

 * The page templates in rapid-pages have been improved a lot. If you use them you should study the new templates carefully to see how you need to update your own code.
 
 * If you were using the multiple-object create/update features in Hobo's controller, I'm afraid that feature has been deemed lame and is gone.
 
And a couple of teeny ones:

 * We no longer support the shortcut `hobo_user_model :email`. You need to explicitly call `set_login_attr :email`. You should do this *after* the fields declaration.
 
 * The css class `button_input` is now just `button`, which may mess with your beautiful design a tad.

There's a *ton* of other changes but those are my list of "things to mention in the blog post".

Go get it:

 * Either `gem update hobo`
 * or [download the gem from here](/gems/hobo-0.6.3.gem)
 * Subversion: `svn://hobocentral.net/hobo/trunk/hobo`
 * [CHANGELOG](/gems/CHANGES.txt)
 
Now I just have one little feature I need to implement and I can get stuck in to the ... drum-roll ... documentation!
