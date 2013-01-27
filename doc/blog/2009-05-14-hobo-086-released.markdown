--- 
wordpress_id: 243
author_login: bryanlarsen
layout: post
comments: 
- author: Bryan Larsen
  date: Thu May 14 17:07:28 +0000 2009
  id: 51628
  content: |
    <p>Again, I forgot to mention where to get the update.</p>
    
    <p>The gem has been pushed to rubyforge, so a <code>gem install hobo</code> should install version 0.8.6.  You may have to wait a day or so for rubyforge to catch up.</p>
    
    <p>For the impatient, you can install from github:  <code>gem install tablatom-hobo</code> after <code>gem sources -a http://gems.github.com</code>.</p>
    
    <p>As always, the <a href="http://github.com/tablatom/hobo" rel="nofollow">source is on github</a>.</p>

  date_gmt: Thu May 14 17:07:28 +0000 2009
  author_email: bryan@larsen.st
  author_url: http://bryan.larsen.st
- author: Bryan Larsen
  date: Thu May 14 18:18:22 +0000 2009
  id: 51630
  content: |
    <p>As some of you've noticed by now, I forgot to refresh the manifest before releasing 0.8.6.  I've pushed a 0.8.7 to github but we'll have to wait for Tom to push it to Rubyforge.</p>
    
    <p>And it turns out that github won't automatically build the gem -- Hobo is actually three gems and it doesn't understand that.</p>

  date_gmt: Thu May 14 18:18:22 +0000 2009
  author_email: bryan@larsen.st
  author_url: http://bryan.larsen.st
- author: Bryan Larsen
  date: Fri May 15 00:26:39 +0000 2009
  id: 51633
  content: |
    <p>Hobo 0.8.7 has made it to rubyforge.  Enjoy!</p>

  date_gmt: Fri May 15 00:26:39 +0000 2009
  author_email: bryan@larsen.st
  author_url: http://bryan.larsen.st
- author: Adam Wilson
  date: Fri May 15 14:05:01 +0000 2009
  id: 51634
  content: |
    <p>Many thanks for all your hard work, Tom, Bryan and co. Very good stuff!</p>

  date_gmt: Fri May 15 14:05:01 +0000 2009
  author_email: adam@codegarden.co.uk
  author_url: http://www.codegarden.co.uk
- author: Owen
  date: Fri May 15 18:36:14 +0000 2009
  id: 51638
  content: |
    <p>Many thanks to Tom and Bryan! On a roll!</p>

  date_gmt: Fri May 15 18:36:14 +0000 2009
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
- author: Owen
  date: Mon May 18 15:09:56 +0000 2009
  id: 51648
  content: |
    <p>Tested a complete install of Hobo 0.8.7 on Windows XP starting with Ruby, then adding Rails 2.3.2 etc.  Worked fine!</p>
    
    <p>Thanks,</p>
    
    <p>Owen</p>

  date_gmt: Mon May 18 15:09:56 +0000 2009
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
- author: Hobo The web app builder for Rails | bean bag chairs
  date: Sun Jun 14 00:44:59 +0000 2009
  id: 51689
  content: |
    <p>[...] Hobo The web app builder for Rails   Posted by root 12 minutes ago (http://hobocentral.net)        Reader comments add your comment comment number 1 written by bryan larsen powered by wordpress middot design by fulspectrum media        Discuss&nbsp;  |&nbsp; Bury |&nbsp;    News | Hobo The web app builder for Rails [...]</p>

  date_gmt: Sun Jun 14 00:44:59 +0000 2009
  author_email: ""
  author_url: http://ebeanbagchair.info/story.php?id=5909
author: Bryan Larsen
title: Hobo 0.8.6 Released!
published: true
tags: []

date: 2009-05-14 16:53:37 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=243
author_url: http://bryan.larsen.st
status: publish
---
We're pleased to announce the release of Hobo 0.8.6.

[Hobo 0.8.6 includes Rails 2.3 support.](http://hobocentral.net/blog/2009/04/27/support-for-rails-23/)&nbsp; Rails 2.2 support has been maintained.&nbsp;&nbsp; Rails 2.1 support was dropped in 0.8.5.

[Significant effort was put into unit and integration tests in this
release.](http://hobocentral.net/blog/2009/04/24/automated-tests-for-hobo/)

Some small changes were made to item order and positioning to fix bugs with IE6.
This may require updates in custom stylesheets.&nbsp; The most likely problem is the positioning of <`account-nav`>.

Previously, the lifecycle transitions had a parameter called `:params`
in the documentation and `:update` in the code.&nbsp; The code has been
updated to match the documentation.

Support for `big_integer` in HoboFields has been dropped.&nbsp; It appears
that this has never worked correctly.

<`input-many`> is now a polymorphic tag and the default tag for <`has_many`>
inputs.

The `content` parameter has been renamed to `description` for
generated cards.

<`input-many`> and <`sortable-collection`> have been improved.

Many tags have had parameters and attributes added to improve
customization.

Many bugs have been fixed.&nbsp; See the [lighthouse](
http://hobo.lighthouseapp.com) or the [git commit
history](http://github.com/tablatom/hobo/commits/master/) for more
details.

0.8.6 is a release candidate for Hobo 1.0.&nbsp; At this point we do not
believe that there are any outstanding bugs on Hobo that do not have
workarounds.&nbsp;&nbsp; The
[lighthouse](https://hobo.lighthouseapp.com/projects/8324-hobo/tickets/bins/8323)
shows the remaining tickets scheduled for 1.0
