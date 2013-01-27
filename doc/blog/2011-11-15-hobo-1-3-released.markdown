--- 
wordpress_id: 369
author_login: admin
layout: post
comments: 
- author: Vivek
  date: Tue Nov 15 23:12:57 +0000 2011
  id: 52207
  content: |
    <p>I cant wait for hobo 1.4 . Im dying find alternate fixes to downgrade my rails  3.1</p>

  date_gmt: Tue Nov 15 23:12:57 +0000 2011
  author_email: ravensnowbird@gmail.com
  author_url: http://ravensnowbird.tumblr.com
- author: Owen
  date: Wed Nov 16 15:50:43 +0000 2011
  id: 52208
  content: |
    <p>Yes, Rails 3.1 is our top priority right now...</p>
    
    <p>-Owen</p>

  date_gmt: Wed Nov 16 15:50:43 +0000 2011
  author_email: ""
  author_url: ""
- author: daVe
  date: Wed Nov 16 16:03:07 +0000 2011
  id: 52209
  content: |
    <p>could not agree with vivek more! :-4a7d3d609129a9296bf7ac0608c2097

  date_gmt: Wed Nov 16 16:03:07 +0000 2011
  author_email: hobocentral.koopje@spamgourmet.com
  author_url: ""
- author: Eddie
  date: Wed Nov 16 21:23:16 +0000 2011
  id: 52210
  content: |
    <p>Great news! congrats!</p>

  date_gmt: Wed Nov 16 21:23:16 +0000 2011
  author_email: erbecke@gmail.com
  author_url: http://www.tambero.com
- author: Quike
  date: Wed Nov 16 22:56:59 +0000 2011
  id: 52211
  content: |
    <p>Yea now updating! thanks great job!</p>

  date_gmt: Wed Nov 16 22:56:59 +0000 2011
  author_email: morefx@hotmail.com
  author_url: ""
- author: Dale Reagan
  date: Thu Nov 17 20:02:26 +0000 2011
  id: 52212
  content: |
    <p>Greetings,</p>
    
    <p>I'm exploring Rails 3(.x) and tried Hobo and of course it's a no-go.  It may save (some) folks a bit of time if you include a 'mini how-to run with Hobo' so all needed steps present.  </p>
    
    <p>Since I have installed gems for Rails 3.0 and 3.1 this should be an auto-magick item (IMO.)  The 2-minute post says, "You need at least version 3.0 of Rails:" - perhaps I am missing something?</p>
    
    <p>Perhaps building hobo to auto-configure as needed so explorers won't see:</p>
    
    <p>"Hobo Command Line Interface 1.3.0
    Bundler could not find compatible versions for gem "actionpack":
      In Gemfile:
        hobo (= 1.3.0) ruby depends on
          actionpack (~> 3.0.0) ruby
        rails (= 3.1.1) ruby depends on
          actionpack (3.1.1)"</p>
    
    <p>Looks really interesting so I'll keeping poking about until I get Hobo working...</p>
    
    <p>:)
    Dale</p>

  date_gmt: Thu Nov 17 20:02:26 +0000 2011
  author_email: coder@ga-usa.net
  author_url: http://web-tech.ga-usa.com/
- author: Drammy
  date: Sat Nov 19 20:27:38 +0000 2011
  id: 52214
  content: |
    <p>Dale,</p>
    
    <p>I have pulled my hair out over the last few week trying to get a working installation of hobo and found lots of resources detailing different approaches, none of which seem to work for my situation.</p>
    
    <p>Anyway I went through a process of trial and error and eventually had some success installing hobo 1.3.0pre2.  I documented the steps (only my own notes so hope they make sense to you) I went through to install on Windows 7 64 bit. After 2 weeks of playing with hobo though I do think its worth the effort and perseverance.</p>
    
    <p>The notes may need some slight amendments to get hobo 1.3 full release installed and working but at least you have a start...</p>
    
    <ol>
    <li>installed ruby 1.9.2 p290</li>
    <li>Downloaded and installed RubyGems 1.8.11 - ruby setup.rb</li>
    <li>Installed devkit - ruby dk.rb init &amp; ruby dk.rb install</li>
    <li>Installed Rails - gem install rails -v 3.0.10 --include-dependencies</li>
    <li>Made sure the only remote resource was rubygems.org</li>
    <li>Installed hobo - gem install hobo --pre  --no-ri --no-rdoc</li>
    <li>Installed sqlite3 - gem install sqlite3</li>
    <li>Copied sqlite dll and def files into C:ruby192bin</li>
    <li>Installed earlier version of will<em>paginate - gem install will</em>paginate -v 3.0.pre2
    10.Add gem dependency to sites gemfile - gem "will<em>paginate", "3.0.pre2"
    11.Unlock the bundle - bundle update will</em>paginate
    12.Do a Bundle Install on the site
    13.Uninstall will<em>paginate version 3.0.pre4 - gem uninstall will</em>paginate -v 3.0.pre4</li>
    </ol>
    
    <p>Hope it helps ;-)
    Drammy</p>

  date_gmt: Sat Nov 19 20:27:38 +0000 2011
  author_email: martynjreid@gmail.com
  author_url: ""
- author: Drammy
  date: Sat Nov 19 20:30:49 +0000 2011
  id: 52215
  content: |
    <p>Hmmm, will try that again as it seemed to get formatted strange...</p>
    
    <p>Dale,</p>
    
    <p>I have pulled my hair out over the last few week trying to get a working installation of hobo and found lots of resources detailing different approaches, none of which seem to work for my situation.</p>
    
    <p>Anyway I went through a process of trial and error and eventually had some success installing hobo 1.3.0pre2.  I documented the steps (only my own notes so hope they make sense to you) I went through to install on Windows 7 64 bit. After 2 weeks of playing with hobo though I do think its worth the effort and perseverance.</p>
    
    <p>The notes may need some slight amendments to get hobo 1.3 full release installed and working but at least you have a start...</p>
    
    <p><code>
    1.  Installed ruby 1.9.2 p290
    2.  Downloaded and installed RubyGems 1.8.11 - ruby setup.rb
    3.  Installed devkit - ruby dk.rb init &amp; ruby dk.rb install
    4.  Installed Rails - gem install rails -v 3.0.10 --include-dependencies
    5.  Made sure the only remote resource was rubygems.org
    6.  Installed hobo - gem install hobo --pre  --no-ri --no-rdoc
    7.  Installed sqlite3 - gem install sqlite3
    8.  Copied sqlite dll and def files into C:\ruby192\bin
    9.  Installed earlier version of will_paginate - gem install will_paginate -v 3.0.pre2
    10. Add gem dependency to sites gemfile - gem "will_paginate", "3.0.pre2"
    11. Unlock the bundle - bundle update will_paginate
    12. Do a Bundle Install on the site
    13. Uninstall will_paginate version 3.0.pre4 - gem uninstall will_paginate -v 3.0.pre4
    </code></p>
    
    <p>Hope it helps ;-)
    Drammy</p>

  date_gmt: Sat Nov 19 20:30:49 +0000 2011
  author_email: martynjreid@gmail.com
  author_url: ""
- author: Dale Reagan
  date: Mon Mar 26 15:58:50 +0000 2012
  id: 52240
  content: |
    <p>I'm back - after some diversions.  I was able to get Hobo running a few days after my post and I did create a web post about it.  </p>
    
    <p>http://web-tech.ga-usa.com/2011/11/hobo-fasssssssssstttt-rails-3-appssite/  </p>
    
    <p>I used 'rvm' to get things into a sensible state.  </p>
    
    Currently working through the large tutorial (nice job) but encountered a small issue with CH 3, tutorial 8 - model relationships part II.  Things work, however the 'category' display shows '#' instead of a post-related id number, i.e.  
    
    <pre><code>&laquo; Back to Recipe [#, #]
    </code></pre>
    
        Category Sweet
    
    <ul>
    <li>Relationships seem to work fine.  </li>
    <li>I did run a migration.  </li>
    <li>I did restart the server.  </li>
    </ul>
    
    <p>:)
    Dale</p>

  date_gmt: Mon Mar 26 15:58:50 +0000 2012
  author_email: rhobo@ga-usa.net
  author_url: http://web-tech.ga-usa.net
author: Tom
title: Hobo 1.3 Released!
published: true
tags: []

date: 2011-11-15 09:18:54 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/?p=369
author_url: http://www.hobocentral.net
status: publish
---
At long last, Hobo 1.3 is released.

The big news in 1.3, as most of you will know, is Rails 3 support. There are a bunch of other improvements as well. Read the details here:

[http://cookbook.hobocentral.net/manual/changes](http://cookbook.hobocentral.net/manual/changes)

To get Hobo 1.3 just `gem update hobo`.

The work behind Hobo 1.3 is mostly thanks to Domizio Demichelis, and as always Bryan Larsen and Matt Jones have made some great contributions. Thanks guys, and thanks to everyone in the Hobo community for your part, even if it's just being there on the forum for newcomers. And of course thanks to Owen Dall and [Barquin International](http://barquin.com) for their continued sponsorship, without which we wouldn't have got here.

We would like to have released Hobo 1.3 much sooner, so apologies that it has taken so long. Work has already begun on Hobo 1.4 and Rails 3.1 compatibility.
