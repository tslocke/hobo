--- 
wordpress_id: 18
author_login: admin
layout: post
comments: 
- author: Joshua
  date: Tue Dec 26 07:54:49 +0000 2006
  id: 32
  content: |
    <p>Hobo is very interesting! Please post the screencast either in other formats or up on Google Video / YouTube so people without software to play .MOVs can enjoy. Looking forward to more documentation soon / in the new year.</p>

  date_gmt: Tue Dec 26 07:54:49 +0000 2006
  author_email: jwarchol@gmail.com
  author_url: ""
- author: Tom
  date: Tue Dec 26 08:42:14 +0000 2006
  id: 33
  content: |
    <p>The trouble with Google Video is that the resolution is very poor for a screencast, but <a href="http://video.google.co.uk/videoplay?docid=2527153840941403688" rel="nofollow">here it is</a> anyway -- better than nothing if you can't view QuickTime.</p>

  date_gmt: Tue Dec 26 08:42:14 +0000 2006
  author_email: tom@livelogix.com
  author_url: http://
- author: nap
  date: Tue Dec 26 15:14:05 +0000 2006
  id: 35
  content: |
    <p>Wow guys this is excellent. Really excellent. AAA and everything, baked right in.</p>

  date_gmt: Tue Dec 26 15:14:05 +0000 2006
  author_email: nap@zerosum.org
  author_url: http://blog.zerosum.org
- author: J&Atilde;&cedil;rgen Bang Erichsen
  date: Tue Dec 26 20:11:31 +0000 2006
  id: 37
  content: |
    <p>How did you use the S3 service to serve the file from your web site?</p>

  date_gmt: Tue Dec 26 20:11:31 +0000 2006
  author_email: ""
  author_url: ""
- author: Tom
  date: Tue Dec 26 20:26:39 +0000 2006
  id: 38
  content: |
    <p><code>screencasts.hobocentral.net</code> is aliased to <code>static.s3.amazonaws.com</code> using a CNAME directive. There's a guide <a href="http://overstimulate.com/articles/2006/11/19/userscripts-and-s3.html" rel="nofollow">here</a>.</p>

  date_gmt: Tue Dec 26 20:26:39 +0000 2006
  author_email: tom@livelogix.com
  author_url: http://
- author: Amr
  date: Thu Dec 28 01:55:08 +0000 2006
  id: 42
  content: |
    <p>Congratulations on an excellent product. Looks pretty good. Maybe I <em>will</em> spend some more time with rails after all :)</p>

  date_gmt: Thu Dec 28 01:55:08 +0000 2006
  author_email: ""
  author_url: ""
- author: Tim Lossen
  date: Fri Dec 29 15:37:59 +0000 2006
  id: 52
  content: |
    <p>congratulations, hobo looks very promising ... especially the DRYML part. would you perhaps consider releasing DRYML separately?</p>
    
    <p>i am currently working on a portal project which could certainly benefit from extracting some stuff into taglibs.</p>

  date_gmt: Fri Dec 29 15:37:59 +0000 2006
  author_email: tim.lossen@infopark.de
  author_url: ""
- author: Tom
  date: Wed Jan 03 10:05:14 +0000 2007
  id: 57
  content: |
    <p>Tim - I've been careful to set things up so you can use DRYML without any other Hobo feature getting in the way. If you just install Hobo as a plugin and create app/views/hobolib/application.dryml (can just be a blank file), DRYML should be working and everything else should be normal.</p>
    
    <p>Let me know if you have any trouble.</p>

  date_gmt: Wed Jan 03 10:05:14 +0000 2007
  author_email: tom@livelogix.com
  author_url: http://
- author: Tim Lossen
  date: Wed Jan 03 13:37:46 +0000 2007
  id: 58
  content: |
    <p>as far as i remember, that didn't quite work out for us ...
    we had clashes with helper functions like 'current<em>user' and 'logged</em>in?' which we use as well. but i will try it again.</p>
    
    <p>anyway, if you were to release DRYML as a separate plugin, it
    could prove immensely popular .... because this is really a
    brilliant idea. think of it like releasing a hit single. later some people will go on and buy the whole album. ;)</p>

  date_gmt: Wed Jan 03 13:37:46 +0000 2007
  author_email: ""
  author_url: ""
- author: Tom
  date: Thu Jan 04 09:40:56 +0000 2007
  id: 59
  content: |
    <p>Tim - did you include</p>
    
    <pre><code>hobo_controller
    </code></pre>
    
    <p>In your controller? You don't need to. DRYML will be installed as a template handler without that, and you shouldn't get all those Hobo helper methods.</p>
    
    <p>In fact DRYML started out as a separate plugin, but I just wanted to avoid the extra house-keeping. If Hobo really does stay completely out of the way then this is really just a "branding" issue I guess. But branding is important, so maybe you're right.</p>

  date_gmt: Thu Jan 04 09:40:56 +0000 2007
  author_email: tom@livelogix.com
  author_url: http://
- author: UnTalDouglas
  date: Sun Jan 07 08:33:08 +0000 2007
  id: 81
  content: |
    <p>There is this aplication for watching the Posts in the .MOV format without problem
    http://www.videolan.org/
    It's Open Source, and runs on Windows and Linux and believe even on Mac(I have not test it )</p>

  date_gmt: Sun Jan 07 08:33:08 +0000 2007
  author_email: douglasag@yahoo.com
  author_url: http://www.tecnoforo.com
- author: Tim
  date: Mon Jan 08 21:29:03 +0000 2007
  id: 89
  content: |
    <p>Tom - "DRYML only" works like a charm, just like you said. </p>
    
    <p>still i think you should advertise this fact more prominently - the barrier to adoption is really quite low.</p>

  date_gmt: Mon Jan 08 21:29:03 +0000 2007
  author_email: tim.lossen@infopark.de
  author_url: ""
author: Tom
title: Release Reflections
excerpt: |
  Well it feels great to finally have Hobo out there. We've had about 800-900 visits to the site since the launch, 32 downloads of the gem, and who-knows-how-many downloads from the subversion repository because svnserve doesn't seem to log anything :-)
  

published: true
tags: []

date: 2006-12-24 11:11:10 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobotek.net/blog/2006/12/24/release-reflections/
author_url: http://www.hobocentral.net
status: publish
---
Well it feels great to finally have Hobo out there. We've had about 800-900 visits to the site since the launch, 32 downloads of the gem, and who-knows-how-many downloads from the subversion repository because svnserve doesn't seem to log anything :-)

<a id="more"></a><a id="more-18"></a>

Oh and around 4.5GB of traffic on the screencast, which is about 360 views assuming everyone downloaded the whole thing (which I'm sure they didn't!). All of which has cost us a little over a dollar thanks to the incomparable [Amazon S3](http://aws.amazon.com/s3) service. Just awesome.

We had one slip-up in that I completely forgot to mention the dependency on Rails 1.2, so don't forget to:

    gem install rails --source http://gems.rubyonrails.org -y

(and don't worry when the version it reports back isn't 1.2)

We've had some nice feedback - thanks very much to you all! The one comment I was waiting for turned up on reddit:

> It's the Django admin site/TurboGears Catwalk for Rails?

I'd say no - that would be [Streamlined](http://streamlined.relevancellc.com). I was expecting this because we've all seen a site pop-up from nowhere with these great tools. What's different about Hobo is that the resulting site is *not* just for admins. In fact you can sorta-kinda already see that in the screencast. Thanks to the permission system Hobo is creating different views (with different capabilities) for the guest user, a registered user and "admin".

But the real eye-opener will hopefully come with the next screencast - where POD will be transformed in no-time-flat into a clean, easy to use, ready to rock-and-roll site. I'm really looking forward to putting that out, but there's a couple of extra bells and whistles I'm going to attach to Hobo first, just to make the process oh-so-smooth :-)

First up though - I think it's time for some cheer and merriment. Happy Christmas, Happy Holidays or just Happy Happy - take your pick :-)
