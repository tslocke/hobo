--- 
wordpress_id: 154
author_login: admin
layout: post
comments: 
- author: Dr Nic
  date: Tue May 01 20:20:19 +0000 2007
  id: 2360
  content: |
    <p>Thanks for pointing out FileMerge, looks nice.</p>

  date_gmt: Tue May 01 20:20:19 +0000 2007
  author_email: drnicwilliams@gmail.com
  author_url: http://drnicwilliams.com
- author: Douglas Morato
  date: Wed May 02 03:20:28 +0000 2007
  id: 2370
  content: |
    <p>Great to let us know. And Thank you so much for this framework. Please, please... keep the excellent job !</p>

  date_gmt: Wed May 02 03:20:28 +0000 2007
  author_email: dfamorato@douglasmorato.com
  author_url: http://www.douglasmorato.com
author: Tom
title: Breaking change, and the ups and downs of FileMerge
excerpt: |+
  I forgot to mention -- there's a small breaking change in 0.5.3, `object_table@skip_fields` has been renamed to just `skip` (that's the `skip_fields` attribute of `<object_table>` using a syntax that just popped into my head). The reason being that you can now use that attribute to skip both fields and associations.
  
published: true
tags: []

date: 2007-05-01 16:38:53 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/05/01/breaking-change-and-the-ups-and-downs-of-filemerge/
author_url: http://www.hobocentral.net
status: publish
---
I forgot to mention -- there's a small breaking change in 0.5.3, `object_table@skip_fields` has been renamed to just `skip` (that's the `skip_fields` attribute of `<object_table>` using a syntax that just popped into my head). The reason being that you can now use that attribute to skip both fields and associations.

<a id="more"></a><a id="more-154"></a>

I blame FileMerge - it neglected to remind me about the change. If you're a Mac user and you've not discovered FileMerge (I didn't know about it for a good while), you're missing out. Once you've installed Xcode you'll find it in /Developer/Applications/Utilities. It's a diff/merge tool for both files and whole directory trees and, in a very Mac-like way, it just works. It's got the most readable display of any such tool I've used.

You can also launch it from the command line, where it goes by the name (somewhat strangely) of `opendiff`.

So I just do something like

    opendiff rel_0.5.2 rel_0.5.3

And document all the changes I see in the changelog.

So why was I not reminded of that breaking change? Well, one of the "just work" features of FileMerge is that it automatically ignores .svn directories -- very nice. A quick look in preferences shows that there's a pre-configured list of filename patterns the tool will ignore. And alas, in that list is "tags" (I believe that's a ctags thing). Sometimes "just works" just doesn't :-(.

I've removed 'tags' from that list now of course, but I've probably missed changes within Hobo's tags directory in several chapters of the changelog. I should go back and fix that I guess. Hmm... :-)

And finally, absolutely free of charge, here's a groovy FileMerge link for you :-)

 * [Amp up your subversionation with FileMerge](http://ssel.vub.ac.be/ssel/internal:fmdiff)
