--- 
wordpress_id: 325
author_login: admin
layout: post
comments: 
- author: fuyi
  date: Fri Oct 01 17:53:17 +0000 2010
  id: 52032
  content: |
    <p>good work!</p>
    
    <p>but: when i start server :</p>
    
    <p>No such taglib: /home/fuyi/rubyapp/tests/app/views {:src=>"taglibs/auto/rapid/cards", :type=>:include, :template_dir=>"app/views/taglibs"} /home/fuyi/rubyapp/tests/app/views/taglibs/auto/rapid/cards.dryml</p>
    
    <p>when i use:
       rake hobo:generate<em>taglibs
    rake aborted!
    Don't know how to build task 'hobo:generate</em>taglibs'</p>
    
    <p>why?</p>
    
    <p>i use ruby 1.9.2  &amp;  rails 3.0.0</p>

  date_gmt: Fri Oct 01 17:53:17 +0000 2010
  author_email: i.it@tom.com
  author_url: ""
- author: Owen
  date: Sun Oct 03 14:40:58 +0000 2010
  id: 52033
  content: |
    <p>Hobo appears to require Arel but it doesn't install as a dependency:</p>
    
    <p>http://screencast.com/t/MDc4MzhlM2Qt</p>

  date_gmt: Sun Oct 03 14:40:58 +0000 2010
  author_email: ""
  author_url: ""
- author: Owen
  date: Sun Oct 03 14:49:58 +0000 2010
  id: 52034
  content: |
    <p>OK. After I installed the Arel gem i get to create an app.  The wizard is very nice.</p>
    
    <p>I am able to bring up the app and create my user, but when I switch from "Guest" to my user using the selectorL</p>
    
    <p>No route matches "/dev/index/set<em>current</em>user"
    http://screencast.com/t/N2YwN2Yy</p>
    
    <p>I tested using Ruby 1.9.2RC2 and Rails 3.0.0</p>

  date_gmt: Sun Oct 03 14:49:58 +0000 2010
  author_email: ""
  author_url: ""
- author: Frode Marton Meling
  date: Sun Oct 03 16:37:28 +0000 2010
  id: 52035
  content: |
    <p>I got this error after testing this and adding the first user..</p>
    
    Any ideas?
    
    <p>Routing Error</p>
    
    No route matches {:controller=>"admin/users", :action=>"show"}

  date_gmt: Sun Oct 03 16:37:28 +0000 2010
  author_email: frode@meling.name
  author_url: ""
- author: Frode Marton Meling
  date: Sun Oct 03 17:00:34 +0000 2010
  id: 52036
  content: |
    <p>Just wantet to add that, the error happens if I choose a invite only site.</p>

  date_gmt: Sun Oct 03 17:00:34 +0000 2010
  author_email: frode@meling.name
  author_url: ""
- author: fresh
  date: Tue Oct 05 05:26:23 +0000 2010
  id: 52040
  content: |
    <p>Hobo Command Line Interface 1.3.0.pre8</p>
    
    <p>Error -> Row 47 initialise error in command.rb </p>
    
    <p>Error Type -> "No such file or directory - tmp/hobo<em>app</em>template (Errno: ENOENT)</p>

  date_gmt: Tue Oct 05 05:26:23 +0000 2010
  author_email: davos@davos.com
  author_url: ""
- author: Owen
  date: Fri Oct 08 19:53:19 +0000 2010
  id: 52043
  content: |
    <p>1.3.0pre9 appears to clear up most problems so far...</p>

  date_gmt: Fri Oct 08 19:53:19 +0000 2010
  author_email: ""
  author_url: ""
- author: Owen
  date: Mon Oct 18 00:09:00 +0000 2010
  id: 52048
  content: |
    <p>pre12 is looking great so far...</p>

  date_gmt: Mon Oct 18 00:09:00 +0000 2010
  author_email: ""
  author_url: ""
- author: Nir Leibovitch
  date: Thu Oct 21 17:48:42 +0000 2010
  id: 52052
  content: |
    <p>Windows users might find this useful:</p>
    
    <p>When running 'hobo new app_name' I've got the following error message:</p>
    
    <p>%ruby<em>install</em>path%/lib/ruby/gems/1.9.1/gems/hobo<em>support-1.3.0.pre13/lib/hobo</em>support/command.rb:53:in `initialize': No such file or directory - /tmp/hobo<em>app</em>template (Errno::ENOENT)</p>
    
    <p>I read command.rb and noticed that it tries to create a file hobo<em>app</em>template in /tmp, which us Windows users don't have.</p>
    
    <p>Changing line 52 to the following got hobo working for me:
    template<em>path = "c:/Temp/hobo</em>app_template"</p>
    
    <p>Hope this helps anyone who had trouble with it..</p>

  date_gmt: Thu Oct 21 17:48:42 +0000 2010
  author_email: nir.leibo@gmail.com
  author_url: ""
- author: Owen
  date: Tue Oct 26 22:11:54 +0000 2010
  id: 52061
  content: |
    <p>pre13 looks good so far for me.</p>

  date_gmt: Tue Oct 26 22:11:54 +0000 2010
  author_email: ""
  author_url: ""
- author: Quikin
  date: Wed Nov 03 00:50:23 +0000 2010
  id: 52063
  content: |
    <p>this error on create first register:</p>
    
    <p>super from singleton method that is defined to multiple classes is not supported; this will be fixed in 1.9.3 or later..</p>
    
    <p>env:
    win xp,512 kb ram
    rails 3.0.0
    ruby 1.9.2p0 (2010-08-18) [i386-mingw32]
    gem 1.3.7
    Hobo Command Line Interface 1.3.0.pre14</p>
    
    <p>switch to linux???</p>

  date_gmt: Wed Nov 03 00:50:23 +0000 2010
  author_email: morefx@hotmail.com
  author_url: ""
- author: jac
  date: Thu Nov 04 23:49:38 +0000 2010
  id: 52064
  content: |
    <p>Quikin: I saw a post on hobo users group on google. The problem seems to be on using ruby 1.9.2. Use ruby 1.8.7 instead! Cheers.</p>

  date_gmt: Thu Nov 04 23:49:38 +0000 2010
  author_email: javier.alejandro.castro@gmail.com
  author_url: ""
- author: Quikin
  date: Sat Nov 06 04:03:30 +0000 2010
  id: 52065
  content: |
    <p>thanks jac</p>

  date_gmt: Sat Nov 06 04:03:30 +0000 2010
  author_email: morefx@hotmail.com
  author_url: ""
- author: Owen
  date: Sat Nov 06 14:20:23 +0000 2010
  id: 52066
  content: |
    <p>pre15 looks great except for using app.en.yml for changing class and filed names.  Domizio has a patch which be released in the next version.</p>

  date_gmt: Sat Nov 06 14:20:23 +0000 2010
  author_email: ""
  author_url: ""
- author: Edmund Haselwanter
  date: Sat Nov 20 08:00:53 +0000 2010
  id: 52077
  content: |
    <p>pre16 looks great so far. Having some issues with STI so. auto<em>actions</em>for :assessment, [:create] does override routes. the first STI subclass controller wins the game and routes from the base class to the subclass controller :-( deleting the STI subclass controllers kills the views</p>

  date_gmt: Sat Nov 20 08:00:53 +0000 2010
  author_email: edmund@haselwanter.com
  author_url: http://www.iteh.at
- author: Kila
  date: Wed Dec 15 18:39:24 +0000 2010
  id: 52088
  content: |
    <p>FYI - I received an error after creating a new application and selecting y to run the wizard from a command line prompt on a windows machine -</p>
    
    <p>the procedure entry point sqllite3<em>backup</em>finish could not be located in the dynamic link library sqllite3.dll</p>
    
    <p>I haven't investigated it at all yet, but I did want to let you know about it.</p>

  date_gmt: Wed Dec 15 18:39:24 +0000 2010
  author_email: kelasings@gmail.com
  author_url: ""
- author: Kila
  date: Wed Dec 15 18:39:56 +0000 2010
  id: 52089
  content: |
    <p>FYI - I received an error after creating a new application and selecting y to run the wizard from a command line prompt on a windows machine -</p>
    
    <p>the procedure entry point sqlite3<em>backup</em>finish could not be located in the dynamic link library sqlite3.dll</p>
    
    <p>I haven't investigated it at all yet, but I did want to let you know about it.</p>

  date_gmt: Wed Dec 15 18:39:56 +0000 2010
  author_email: kelasings@gmail.com
  author_url: ""
- author: Kila
  date: Wed Dec 15 18:45:16 +0000 2010
  id: 52090
  content: |
    <p>Sorry about that double post. Anyway, I solved that error by installing Sqlite. Here is a link to the information for Windows users in case anyone else needs it.</p>
    
    <p>http://wiki.rubyonrails.org/database-support/sqlite</p>

  date_gmt: Wed Dec 15 18:45:16 +0000 2010
  author_email: kelasings@gmail.com
  author_url: ""
- author: lolomarx
  date: Sat Dec 18 08:36:00 +0000 2010
  id: 52091
  content: |
    <p>I just want to know when the 1.3 final version can be released ?</p>

  date_gmt: Sat Dec 18 08:36:00 +0000 2010
  author_email: jovemark@gmail.com
  author_url: http://www.bugutang.com
- author: Vadim
  date: Sun Jan 09 19:54:11 +0000 2011
  id: 52104
  content: |
    <p>I was trying to upload newly created app to Heroku (sqlite commented out from Gemfile) and got Error 500.
    Logs show:
    "....
    ActionView::Template::Error (undefined method `name' for nil:NilClass):
        13:
        14:         <% if User.count == 0 -%>
    ....."</p>
    
    <p>Any way to make it running at Heroku (it's ok locally)?</p>

  date_gmt: Sun Jan 09 19:54:11 +0000 2011
  author_email: vlazuko@gmail.com
  author_url: ""
- author: Quikin
  date: Wed Feb 02 14:15:34 +0000 2011
  id: 52138
  content: |
    <p>I run Hobo 1.3.0.pre26 with rails 3.0.3 very fine!! 
    begin a New Project using a excelent gem, when a final release ??? can develop a pro project now with this hobo version??</p>
    
    <p>My environment Ubuntu 10.10 gnome
    512 kb RAM
    i have a laptop ;)</p>

  date_gmt: Wed Feb 02 14:15:34 +0000 2011
  author_email: morefx@hotmail.com
  author_url: ""
- author: Quikin
  date: Wed Feb 02 14:16:44 +0000 2011
  id: 52139
  content: |
    <p>I run Hobo 1.3.0.pre26 with rails 3.0.3 very fine!! 
    begin a New Project using a excelent gem, when a final release ??? can develop a pro project now with this hobo version??</p>
    
    <p>My environment Ubuntu 10.10 gnome
    512 kb RAM
    i have a laptop ;)</p>
    
    <p>excelent!! Hobo team!</p>
    
    <p>P.d. oh my poor english language ( i m from Bolivia)</p>

  date_gmt: Wed Feb 02 14:16:44 +0000 2011
  author_email: morefx@hotmail.com
  author_url: ""
- author: Quiliro Ord&oacute;&ntilde;ez
  date: Thu Feb 17 16:37:03 +0000 2011
  id: 52156
  content: |
    <p>This is the proceedure I followed:</p>
    
    <p>wget -c ftp://ftp.ruby-lang.org//pub/ruby/1.9/ruby-1.9.2-p0.tar.gz
    tar xvzf ruby-1.9.2-p0.tar.gz
    cd ruby-1.9.2-p0/
    ./configure
    make
    sudo make install
    cd ext/openssl/
    ruby extconf.rb &amp;&amp; make &amp;&amp; sudo make install
    sudo apt-get install libssl-dev libopenssl-ruby1.9
    ruby -v
    wget -c http://production.cf.rubygems.org/rubygems/rubygems-1.5.2.tgz
    tar xvzf rubygems-1.5.2.tgz 
    cd ../rubygems-1.5.2/
    sudo ruby setup.rb
    sudo gem update
    sudo aptitude install libsqlite3-dev
    sudo gem install sqlite3
    sudo gem install hobo --pre
    hobo new my_app</p>
    
    <p><em><strong></em>Start output and responses*</strong>
    [...]</p>
    
    <p>Hobo Setup Wizard 
      Do you want to start the Setup Wizard now?
    (Choose 'n' if you need to manually customize any file before running the Wizard.
    You can run it later with <code>hobo g setup_wizard</code> from the application root dir.) [y|n] y
        => "y"</p>
    
    <p>[...]</p>
    
    <p>Test Framework 
    Do you want to customize the test_framework? [y|n] n
      => "n"</p>
    
    <p>User Resource 
    Choose a name for the user resource: [=user|] 
      => "user"
    Do you want to send an activation email to activate the user? [y|n] n
      => "n"</p>
    
    <p>Invite Only Option 
    Do you want to add the features for an invite only website? [y|n] n
      => "n"</p>
    
    <p>Templates Option 
    Will your application use only hobo/dryml web page templates?
    (Choose 'n' only if you also plan to use plain rails/erb web page templates) [y|n] y
      => "y"</p>
    
    <p>[...]</p>
    
    <p>Front Controller 
    Choose a name for the front controller: [=front|] 
      => "front"</p>
    
    <p>[...]</p>
    
    <p>DB Migration 
    Initial Migration: [s]kip, [g]enerate migration file only, generate and [m]igrate: [s|g|m] m
      => "m"</p>
    
    <p>[...]</p>
    
    <p>I18n 
    The Hobo supported locales are it pt-PT en es ru de (please, contribute to more translations)
    Type the locales (space separated) you want to add to your application or  for 'en': 
      => "en"
          create  config/locales/hobo.en.yml
          create  config/locales/app.en.yml
          remove  config/locales/en.yml</p>
    
    <p>Git Repository 
    Do you want to initialize a git repository now? [y|n] n
      => "n"</p>
    
    <p>Process completed! 
    You can start your application with <code>rails server</code>
    (run with --help for options). Then point your browser to
    http://localhost:3000/</p>
    
    <p>Follow the guidelines to start developing your application.
    You can find the following resources handy:</p>
    
    <ul>
    <li>The Getting Started Guide: http://guides.rubyonrails.org/getting_started.html</li>
    <li>Ruby on Rails Tutorial Book: http://www.railstutorial.org/</li>
    </ul>
    
    <p><em><strong></em>End output and responses*</strong></p>
    
    <p>cd my_app
    rails server</p>
    
    <p>Done! :-)</p>

  date_gmt: Thu Feb 17 16:37:03 +0000 2011
  author_email: quiliro@fsfla.org
  author_url: http://congresolibre.org
- author: Quiliro Ord&oacute;&ntilde;ez
  date: Thu Feb 17 22:41:36 +0000 2011
  id: 52157
  content: |
    <p>These are simple steps for installation of Hobo 1.3 on Trisquel GNU.-</p>
    
    <p>sudo aptitude install ruby-full build-essential
    ruby -v
    wget -c http://production.cf.rubygems.org/rubygems/rubygems-1.5.2.tgz
    tar xvzf rubygems-1.5.2.tgz 
    cd ../rubygems-1.5.2/
    sudo ruby setup.rb 
    sudo aptitude install sqlite3 libsqlite3-dev 
    sudo gem install sqlite3
    hobo new my<em>app
    cd my</em>app/
    rails server</p>

  date_gmt: Thu Feb 17 22:41:36 +0000 2011
  author_email: quiliro@fsfla.org
  author_url: http://congresolibre.org
- author: Walter Davis
  date: Thu Feb 17 23:15:50 +0000 2011
  id: 52158
  content: |
    <p>Interesting problem. Using pre26, I hit the following logical problem:</p>
    
    <ol>
    <li><p>Create a new test app using this set of instructions, running on my laptop. I followed all the way through the weezard, and selected "completely private site" and "e-mail confirmation" options. </p></li>
    <li><p>Created the admin user.</p></li>
    <li><p>Invited a new user. Logged out.</p></li>
    <li><p>Copied the accept link out of the Terminal (since I'm not able to send mail here) and pasted it into the browser. Got redirected to the login screen.</p></li>
    <li><p>Tried to log in as the new user, but that failed since I don't have a password yet as that user.</p></li>
    <li><p>Logged in as admin, and was immediately redirected to the Accept Invitation page.</p></li>
    </ol>
    
    <p>So clearly, the accept action needs to be more lenient, it can't be (by default) restricted to logged in users only, or else there's no way to confirm an invitation. I'm digging through the source to fix that now, but you might want to change that for the defaults.</p>
    
    <p>Thanks, and really excited to try this out and see how it works for me.</p>

  date_gmt: Thu Feb 17 23:15:50 +0000 2011
  author_email: waltd@wdstudio.com
  author_url: ""
- author: Raymond Gao
  date: Thu Feb 24 00:56:12 +0000 2011
  id: 52162
  content: |
    <p>Hi, I tried to install hobo 1.3 pre version. 
    I typed 
       $ gem install hobo --pre</p>
    
    <p>But, I get the following:
       ERROR:  Could not find a valid gem 'hobo' (>= 0) in any repository
       ERROR:  Possible alternatives: hobo</p>
    
    <p>Does anyone know where is the new repo for hobo 1.3 pre?
    thanks,</p>

  date_gmt: Thu Feb 24 00:56:12 +0000 2011
  author_email: raygao@verizon.net
  author_url: http://are4.us
- author: GG
  date: Thu Apr 14 00:12:51 +0000 2011
  id: 52175
  content: |
    <p>Hi Raymond,
    I think you need --pre (with 2 - )</p>
    
    <p>$gem install hobo --pre</p>
    
    <p>(it works for me with RVM on Mac )</p>

  date_gmt: Thu Apr 14 00:12:51 +0000 2011
  author_email: ""
  author_url: ""
- author: Drammy
  date: Thu Nov 03 11:11:22 +0000 2011
  id: 52204
  content: |
    <p>I had the same problem as Raymond - "Could not find a valid gem 'hobo' (>=0) in any repository" and found a fix...</p>
    
    <p>I removed all gem remote sources other than rubygems...</p>
    
    <p>This worked for me on Windows 7 (x64).</p>

  date_gmt: Thu Nov 03 11:11:22 +0000 2011
  author_email: martynjreid@gmail.com
  author_url: ""
- author: Genaro Myatt
  date: Thu Aug 16 18:24:43 +0000 2012
  id: 52457
  content: |
    <p>Hmm it looks like your site ate my first comment (it was super long) so I guess I'll just sum it up what I wrote and say, I'm thoroughly enjoying your blog. I as well am an aspiring blog writer but I'm still new to the whole thing. Do you have any points for beginner blog writers? I'd really appreciate it.</p>

  date_gmt: Thu Aug 16 18:24:43 +0000 2012
  author_email: Organ4026@yahoo.com
  author_url: http://kredyt-bankowy.eblog.pl/glowna.php
- author: Jefferson Ostenberg
  date: Thu Aug 16 18:34:42 +0000 2012
  id: 52458
  content: |
    <p>What i do not realize is in reality how you are now not really much more neatly-liked than you may be right now. You are very intelligent. You recognize thus significantly relating to this topic, produced me for my part consider it from so many numerous angles. Its like men and women are not fascinated until it is something to accomplish with Woman gaga! Your individual stuffs outstanding. All the time handle it up!</p>

  date_gmt: Thu Aug 16 18:34:42 +0000 2012
  author_email: Mundschenk496@hotmail.com
  author_url: http://chwilowki.mblog.pl/
- author: christian leather bracelets for men
  date: Fri Aug 31 18:10:40 +0000 2012
  id: 52473
  content: |
    <p>I gotta bookmark  this  internet site  it seems  invaluable   invaluable</p>

  date_gmt: Fri Aug 31 18:10:40 +0000 2012
  author_email: Stranahan@yahoo.com
  author_url: http://rhizome.org/discuss/thanks/?c=208788
author: Tom
title: Hobo 1.3 for Rails 3 pre-release
excerpt: |
  Anyone wanting to have a play with Hobo + Rails 3, now is the moment!
  
  We have started releasing some pre-release gems, so that anyone who wants to can help us find any last bugs so that we can release Hobo 1.3 final. You can install the latest pre-release with
  
      gem install hobo --pre
  

published: true
tags: []

date: 2010-09-30 20:58:21 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/?p=325
author_url: http://www.hobocentral.net
status: publish
---
Anyone wanting to have a play with Hobo + Rails 3, now is the moment!

We have started releasing some pre-release gems, so that anyone who wants to can help us find any last bugs so that we can release Hobo 1.3 final. You can install the latest pre-release with

    gem install hobo --pre

<a id="more"></a><a id="more-325"></a>

I'll take this chance to show off a nice new feature that Domizio has added - the new app wizard.

The `hobo` command now has the same style as the new `rails` command in Rails 3, so to create a new app:

    hobo new my_app

The underlying `rails` command will run as always, but then you'll see something new:

     Hobo Setup Wizard 
      Do you want to start the Setup Wizard now?
    (Choose 'no' if you need to manually customize any file before running the Wizard.
    You can rerun it at any time with `hobo g setup_wizard` from the application root dir.) [y|n]

(btw it's actually in colour too, but you'll have to install the gems to see for yourself!)

Check out some of the customisations you can do with some simple prompts:

         Test Framework 
    Do you want to customize the test_framework? [y|n] n

     Invite Only Option 
    Do you want to add the features for an invite only website? [y|n] n

     User Resource 
    Choose a name for the user resource [<enter>=user|<custom_name>]: 

    Do you want to send an activation email to activate the user? [y|n] y

     Front Controller 
    Choose a name for the front controller [<enter>=front|<custom_name>]: 

     Admin Subsite 
    Do you want to add an admin subsite? [y|n] n
      => "n"

     DB Migration 
    Initial Migration: [s]kip, [g]enerate migration file only, generate and [m]igrate [s|g|m]: m

     I18n 
    The available Hobo internal locales are :en, :"es-DO", :it (please, contribute to more translations)
    Do you want to set a default locale? Type the locale or <enter> to skip: 

     Git Repository 
    Do you want to initialize a git repository now? [y|n] n

It'll even do `git init` for you - aint that nice : )

There's a much nicer one in there though - "Do you want to send an activation email to activate the user?". That's right, Hobo 1.3 has the much requested email activation built in, so now you just have to type a y instead of an n, and you're done. Good times!
