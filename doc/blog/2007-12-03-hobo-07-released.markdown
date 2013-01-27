--- 
wordpress_id: 187
author_login: admin
layout: post
comments: 
- author: solars
  date: Mon Dec 03 18:51:51 +0000 2007
  id: 17319
  content: |
    <p>Woho! Great work guys! :)</p>
    
    <p>I love hobo! ..but you already know that.</p>

  date_gmt: Mon Dec 03 18:51:51 +0000 2007
  author_email: cb@unused.at
  author_url: http://railsbased.org
- author: Owen
  date: Mon Dec 03 23:23:52 +0000 2007
  id: 17334
  content: |
    <p>Awesome! You are on a roll.  Can't wait to see beta.hobocentral.net.  That will make a HUGE impact.</p>

  date_gmt: Mon Dec 03 23:23:52 +0000 2007
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
- author: misuba
  date: Tue Dec 04 19:27:51 +0000 2007
  id: 17397
  content: |
    <p>Is there any way the community could help out with beta.HC.net?</p>

  date_gmt: Tue Dec 04 19:27:51 +0000 2007
  author_email: misuba@gmail.com
  author_url: http://www.gibberish.com/
- author: Ruby on Rails at Hobo Speed
  date: Wed Dec 12 15:42:11 +0000 2007
  id: 18219
  content: |
    <p>[...] Hobo Updates Posted on December 12th, 2007 by george. Categories: Rails, Hobo.Well, we&#8217;re getting excited about Hobo again. [...]</p>

  date_gmt: Wed Dec 12 15:42:11 +0000 2007
  author_email: ""
  author_url: http://george.southernohio.net/2007/12/12/hobo-updates/
- author: Andy
  date: Thu Dec 20 21:34:33 +0000 2007
  id: 18902
  content: |
    <p>How is the beta site coming along? I cannot wait :) will be having a long hobo coding effort between Christmas and new year to get some websites done, I think Hobo looks great!</p>

  date_gmt: Thu Dec 20 21:34:33 +0000 2007
  author_email: andystannard@hotmail.com
  author_url: ""
- author: Steve
  date: Fri Dec 21 03:07:22 +0000 2007
  id: 18915
  content: |
    <p>I am anxious to hear about the progress as well.  I will be at the in-laws over Christmas...a good time to work on a new website :)</p>

  date_gmt: Fri Dec 21 03:07:22 +0000 2007
  author_email: steve.stava@gmail.com
  author_url: ""
- author: "A Fresh Cup &raquo; Blog Archive &raquo; Double Shot #96"
  date: Sun Dec 23 14:21:57 +0000 2007
  id: 19042
  content: |
    <p>[...] Hobo 0.7 released - Another round of this rapid design extension to Rails. [...]</p>

  date_gmt: Sun Dec 23 14:21:57 +0000 2007
  author_email: ""
  author_url: http://afreshcup.com/?p=516
author: Tom
title: Hobo 0.7 released
excerpt: |
  **Update:** 
  
  I said you can pass `CSS=y` to the `rake hobo:fixdryml` task to instruct the script to 'dasherize' CSS class names. That should have been `CLASS=y`.
  
  ...
  
  Hobo 0.7 is now available, both as a gem on rubyforge, and in via the repo trunk. 
  
   * [CHANGELOG](/gems/CHANGES.txt)
  
  Template tags and non-template tags are now unified. This is really a huge improvement to DRYML. We've also switched to dashes instead of underscores for tag and attribute names.
  
  

published: true
tags: []

date: 2007-12-03 18:04:48 +00:00
categories: 
- Releases
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/12/03/hobo-07-released/
author_url: http://www.hobocentral.net
status: publish
---
**Update:** 

I said you can pass `CSS=y` to the `rake hobo:fixdryml` task to instruct the script to 'dasherize' CSS class names. That should have been `CLASS=y`.

...

Hobo 0.7 is now available, both as a gem on rubyforge, and in via the repo trunk. 

 * [CHANGELOG](/gems/CHANGES.txt)

Template tags and non-template tags are now unified. This is really a huge improvement to DRYML. We've also switched to dashes instead of underscores for tag and attribute names.


<a id="more"></a><a id="more-187"></a>

Got any existing DRYML code? It doesn't work any more. At all :-)

Fortunately, happiness is only a rake task away:

    rake hobo:fixdryml
    
From the changelog:

> A rake task hobo:fixdryml has been added which does a pretty good
job of converting Hobo 0.6 DRYML source-code to the new style. It
will change every file in app/views/**/*.dryml, and keeps a backup
copy of app/views in app_views_before_fixdryml. If you pass it CLASS=y
and ID=y it will 'dasherize' css classes and IDs too, which is the
new Hobo convention. You can also pass DIR=... if you want to point
it somewhere other than app/views. It won't fix anything in erb
scriptlets, e.g. use of the tagbody local variable. Expect to do
some manual fixes after running the task (good job you've got that
thorough test suite eh?)

We've switched to Rails 2.0 RC2 for our testing. Be warned - there's a breaking change in Rails that might absorb some of your time as it did mine. It's a change to fixtures - the default if you don't give a value for a `created_at` or `updated_at` field, is now `Time.now`. It used to be nil like any other field.

There's now only one significant feature that I want to add -- fixing themes and CSS -- before the push to 1.0 begins.

But before that, next up is beta.hobocentral.net!
