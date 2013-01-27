--- 
wordpress_id: 308
author_login: bryanlarsen
layout: post
comments: 
- author: Owen
  date: Wed Jul 28 16:29:49 +0000 2010
  id: 51982
  content: |
    <p>Thanks, Bryan, very useful!</p>
    
    <p>-Owen</p>

  date_gmt: Wed Jul 28 16:29:49 +0000 2010
  author_email: odall@barquin.com
  author_url: ""
- author: Iain
  date: Fri Jul 30 01:08:35 +0000 2010
  id: 51984
  content: |
    <p>The url for subtree gives a "that page doesn't exist" error. Did you mean do link to http://github.com/apenwarr/git-subtree (rather than http://github.com/apenwarr/git-subtree.git?)</p>

  date_gmt: Fri Jul 30 01:08:35 +0000 2010
  author_email: iain.beeston@googlemail.com
  author_url: ""
- author: Andy Fillebrown
  date: Thu Nov 18 17:54:24 +0000 2010
  id: 52075
  content: |
    <p>Thank you, Bryan!  It works with msysgit, too.</p>

  date_gmt: Thu Nov 18 17:54:24 +0000 2010
  author_email: andy.fillebrown@gmail.com
  author_url: http://audiosculptures.com
author: Bryan Larsen
title: git subtree
published: true
tags: []

date: 2010-07-28 15:32:16 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=308
author_url: http://bryan.larsen.st
status: publish
---
Although the blog has been quiet of late, one only has to look at the <a href="http://groups.google.com/group/hobousers">mailing list</a> to see how busy the Hobo world is.   I'd like to give a shout-out to Matt and Kevin and everybody else who are patiently answering questions there.   The Hobo user community rocks!  But a quiet blog does give the wrong impression sometimes.

I've got a few other things Hobo related that I hoped to blog about but aren't ready yet, but there's nothing stopping me from using this blog to point out tools that will make your Hobo experience better, is there?

Most of the Hobo and Ruby on Rails community uses git for version control.  Git is awesome, but there are two common pain points:  its learning curve, and submodules.

I won't go into the problems with git submodules here.   If you've got a small project with only one developer and you never need to modify your submodules, you're unlikely to run into problems, but as you add developers and start modifying the modules, hassles quickly creep in.

In the past, when you added a plugin to your project, you basically had two options:  copy the files into your project with script/plugin or link the files in using git submodules.

Now you can get the best of both worlds.  With <a href="http://github.com/apenwarr/git-subtree.git">git subtree</a> you get the behaviour of a copy, but you can still easily update the plugin and even extract changes to the plugin to push the changes upstream.

For instance, to add Hobo as a plugin to your project:

    git subtree add --squash --prefix=vendor/plugins/hobo git://github.com/tablatom/hobo.git master

You can then update the plugin with:

    git subtree pull --squash --prefix=vendor/plugins/hobo git://github.com/tablatom/hobo.git master

If you make changes to the Hobo in your app, you can extract them and send them to us with:

    git subtree split --prefix=vendor/plugins/hobo --branch hobo-master
    git push git@github.com:someuser/hobo.git hobo-master:master

(Replace <i>someuser</i> with your github username).  And then send us a pull request.

Git subtree is not yet part of git itself, but hopefully it soon will be.  Even if it does not, it isn't doing anything crazy or unorthodox to your repository, so I wouldn't worry about using it.

Two other alternatives to git subtree are <a href="http://wiki.github.com/evilchelu/braid/">Braid</a> and <a href="http://piston.rubyforge.org/">Piston</a>.  They use similar strategies under the hood.  However, I've found git subtree to work better for me.
