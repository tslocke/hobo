--- 
wordpress_id: 170
author_login: admin
layout: post
comments: 
- author: Keith
  date: Sun Aug 26 08:29:07 +0000 2007
  id: 9665
  content: |
    <p>Thanks for the great software. I am trying to figure out how to use the new user authentication system in 0.6.1. Is it documented anywhere yet? If not, I guess I'll have to brew my own pot of Darjeeling...</p>

  date_gmt: Sun Aug 26 08:29:07 +0000 2007
  author_email: keith@sitara.co.za
  author_url: ""
- author: Andy
  date: Sun Aug 26 10:12:02 +0000 2007
  id: 9673
  content: |
    <p>Great news the multiple user security is just what I wanted. Thank you tom that has saved me some work :)</p>

  date_gmt: Sun Aug 26 10:12:02 +0000 2007
  author_email: andystannard@hotmail.com
  author_url: http://www.MADM0nk3y.com
- author: Tom
  date: Sun Aug 26 10:30:14 +0000 2007
  id: 9675
  content: |
    <p>Keith - first check out the <a href="/gems/CHANGES.txt" rel="nofollow">changelog</a>.</p>
    
    <p>You could also try something like this:</p>
    
    <ul>
    <li>Create a new app with the <code>hobo</code> command</li>
    <li><code>ruby script/generate hobo_user_model administrator</code></li>
    <li><code>ruby script/generate hobo_user_controller administrator</code></li>
    </ul>
    
    <p>It's worth having a look at user.rb and administrator.rb in app/models.</p>
    
    <p>Then fire up the server and have a look at</p>
    
    <ul>
    <li>/user_signup</li>
    <li>/user_login</li>
    <li>/admin_signup</li>
    <li>/admin_login</li>
    </ul>

  date_gmt: Sun Aug 26 10:30:14 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Keith
  date: Mon Aug 27 07:31:57 +0000 2007
  id: 9714
  content: |
    <p>Hi Tom,</p>
    
    <p>Maybe I'm missing something, but the user tables don't appear to be created. Is there a migration missing? After some trial and error, I created a user table with 'username', 'password', 'crypted_password' and 'salt' fields and was then able to create users.</p>
    
    <p>I then found that the 'show' controller action was not working, apparently because of a missing 'human<em>type' method. I changed 'human</em>type' on line 4 of 'generators/hobo<em>rapid/templates/themes/default/views' to 'type</em>name'. That seems to work.</p>
    
    <p>Now I seem to be back on the track.</p>
    
    <p>Keith</p>

  date_gmt: Mon Aug 27 07:31:57 +0000 2007
  author_email: keith@sitara.co.za
  author_url: ""
- author: Tom
  date: Mon Aug 27 10:29:09 +0000 2007
  id: 9718
  content: |
    <p>Keith - we used to generate a migration <em>stub</em> which you could modify to add your own fields. We don't do that anymore because we now generate the whole migration for you. Add your app specific user fields to the <code>fields do</code> block in user.rb, then run <code>script/generate hobo_migration</code></p>

  date_gmt: Mon Aug 27 10:29:09 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Tom
  date: Mon Aug 27 10:30:48 +0000 2007
  id: 9719
  content: |
    <p>Oh - and the other one was indeed a bug. I could have <em>sworn</em> I checked that was working :-)</p>

  date_gmt: Mon Aug 27 10:30:48 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
author: Tom
title: Hobo 0.6.1 released
published: true
tags: []

date: 2007-08-25 10:11:47 +00:00
categories: 
- Releases
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/08/25/hobo-061-released/
author_url: http://www.hobocentral.net
status: publish
---
Not too bad -- only one day later than advertised :-) It's time to

    gem update hobo
    
or

    svn up vendor/plugins/hobo

Not content to fix a few of the problems in 0.6, we've added some major new features in 0.6.1

There's a major overhaul to the Ajax part update mechanism. It's now more secure and can cope with parts that need access to local variables.

Hobo now supports multiple user models, so you could for example have a separate model for regular users and administrators. Each has its own login and signup pages.

As always, see the [changelog](/gems/CHANGES.txt) for the nitty gritty.
