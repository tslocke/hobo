--- 
wordpress_id: 5
author_login: admin
layout: post
comments: 
- author: Dave
  date: Mon Mar 19 09:43:30 +0000 2007
  id: 946
  content: |
    <p>Awesome. Love it when a tutorial works as expected.</p>
    
    <p>Hopefully I can wrap my head around all this soon.</p>
    
    <p>Dave</p>

  date_gmt: Mon Mar 19 09:43:30 +0000 2007
  author_email: wheresdave@gmail.com
  author_url: http://www.unburdenus.org
- author: Logan Koester
  date: Tue Apr 10 23:17:00 +0000 2007
  id: 1512
  content: |
    <p>I don't think I've enjoyed writing a Hello World this much since my first (I think it was Qbasic)</p>
    
    <p>:D</p>

  date_gmt: Tue Apr 10 23:17:00 +0000 2007
  author_email: logan@logankoester.com
  author_url: http://logankoester.com
- author: Euaggelos
  date: Wed Apr 18 14:39:04 +0000 2007
  id: 1924
  content: |
    <p>Nice</p>

  date_gmt: Wed Apr 18 14:39:04 +0000 2007
  author_email: vbaimg@mail.com
  author_url: http://suzuki-philosophy.theauto100.info/alyssa-bentley.htm
- author: pietro
  date: Thu Jul 05 13:59:27 +0000 2007
  id: 6885
  content: |
    <p>i'm thinking about using hobo for a project at work. is there any example showing how to output xml with DRYML?</p>

  date_gmt: Thu Jul 05 13:59:27 +0000 2007
  author_email: pietro.ferrari@gmail.com
  author_url: ""
- author: michael
  date: Thu Jul 26 09:11:33 +0000 2007
  id: 7984
  content: |
    <p>I was not able to install the hobo-stuff with 'ruby script/plugin install ...'.
    After typing and confirming with enter, the system works for a while and then i see the cursor again (no failure message, or anything else).
    Is there any special HINT i am not aware of?</p>

  date_gmt: Thu Jul 26 09:11:33 +0000 2007
  author_email: yarrick@web.de
  author_url: ""
- author: Dan Bikle
  date: Fri Aug 10 22:57:27 +0000 2007
  id: 8944
  content: |
    <p>Michael,
        to make it through the tutorial,
        I'd suggest you use the gem instead of the plugin.</p>
    
    <pre><code>1st download the gem
    http://hobocentral.net/gems/hobo-0.5.3.gem
    
    then...
    7 simple shell commands:
    
    gem install hobo-0.5.3.gem
    cd /tmp/
    hobo myhoboapp
    cd myhoboapp
    script/generate controller hello
    vi app/views/hello/hello_world.dryml
    script/server
    
    Then browse URL:
    http://localhost:3000/hello/hello_world.dryml
    
    -Dan
    </code></pre>

  date_gmt: Fri Aug 10 22:57:27 +0000 2007
  author_email: DAN.BIKLE@GMAIL.COM
  author_url: http://bikle.com
- author: michael
  date: Mon Aug 13 07:11:18 +0000 2007
  id: 9092
  content: |
    <p>Hi Dan,</p>
    
    <p>thank you very much for your suggestion.
    With gem it works fine. Now I can enter the Hobo.</p>
    
    <p>With kind regards,</p>
    
    <p>Michael</p>

  date_gmt: Mon Aug 13 07:11:18 +0000 2007
  author_email: yarrick@web.de
  author_url: ""
- author: Stevo
  date: Mon Sep 03 11:40:09 +0000 2007
  id: 10046
  content: |
    <p>Michael, check if You have SVN command line tool for windows installed. I had the same problem so I've downloaded app from http://svn1clicksetup.tigris.org/, installed it, rebooted system and voila - it works :)</p>

  date_gmt: Mon Sep 03 11:40:09 +0000 2007
  author_email: blazejek@gmail.com
  author_url: http://www.selleo.com
author: Tom
title: "Getting Started: Hello World in DRYML"
excerpt: |
  Hello World will never get old for me. What more could you need to
  get yourself oriented in a new technology? I remember the first time
  I managed to string the whole J2EE stack together. All that technology
  -- JNDI, RMI, EJB... All just to get "Hello World" on the
  screen. Hmmm. Can't say I miss *that* too much.
  
  Where was I?
  

published: true
tags: []

date: 2006-11-10 16:00:04 +00:00
categories: 
- Documentation
author_email: tom@hobocentral.net
wordpress_url: http://hobotek.net/blog/?p=5
author_url: http://www.hobocentral.net
status: publish
---
Hello World will never get old for me. What more could you need to
get yourself oriented in a new technology? I remember the first time
I managed to string the whole J2EE stack together. All that technology
-- JNDI, RMI, EJB... All just to get "Hello World" on the
screen. Hmmm. Can't say I miss *that* too much.

Where was I?

<a id="more"></a><a id="more-5"></a>

Oh yes. One of the main features of Hobo is DRYML - an new template
engine that extends ERB with user-defined tags. Thats right: *extends*.
 DRYML templates can use erb scriptlets just like regular RHTML
templates.

We're going to create a custom tag `<hello>` which will render - you
guessed it - "Hello World" on the page. Obviously, the real goal here is to get
Hobo installed and verify that it's running.

To run Hobo you need Rails 1.2, which at the time of writing is available as release-candidate 1. Install it like this:

    gem install rails --source http://gems.rubyonrails.org -y

To install Hobo into a new Rails app, simply:

    $ rails hobo_hello_world
    $ cd hobo_hello_world
    $ ./script/plugin install svn://hobocentral.net/hobo/trunk

Next, there are one or two directories and files that Hobo expects to
find. Create these with the handy generator:

    $ ./script/generate hobo
      create  app/views/hobolib
      create  app/views/hobolib/themes
      create  app/views/hobolib/application.dryml

OK, Hobo is now at your service! Before we can have a Hello World view, of
course, we'll need a controller:

    $ ./script/generate controller hello

No need to edit that. We'll just go straight for the view.

#### File: app/views/hello/hello_world.dryml

    <def tag="hello">Hello World!</def>

    <p>Here it comes... Can you stand it??!</p>
  
    <p style="font-size: 500%"> <hello/> </p>

That's it. Start your engines:

    $ ./script/server

And browse yourself over to `localhost:3000/hello/hello_world`

Outstanding work people. If that has whet your appetite and you want
more, I suggest you haul your digital assets over to either [Why
DRYML?](/blog/2006/11/10/why-dryml/) or [A Quick Guide to DRYML](/blog/2006/11/10/guide-to-dryml/).
