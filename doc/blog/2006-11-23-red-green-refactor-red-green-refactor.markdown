--- 
wordpress_id: 13
author_login: admin
layout: post
comments: 
- author: mathie
  date: Thu Nov 23 15:47:24 +0000 2006
  id: 3
  content: |
    <p>Can you still say red/green when you run your tests on the command line?</p>
    
    <p>Yep. :-)  Check out ZenTest and redgreen (1.1 or later) gems.  I've then added the following to <code>~/.autotest</code>:</p>
    
    <pre><code>Autotest.send(:alias_method, :real_make_test_cmd, :make_test_cmd)
    Autotest.send(:define_method, :make_test_cmd) do |*args|
      real_make_test_cmd(*args).sub('test/unit',
                                    %[rubygems -e "require 'redgreen'"])
    end
    </code></pre>
    
    <p>Run <code>autotest</code> in your rails root and it'll automatically run your test suite as required when you save files.  And, for bonus points, it'll be colourised as red/green. :)</p>

  date_gmt: Thu Nov 23 15:47:24 +0000 2006
  author_email: mathie@woss.name
  author_url: http://woss.name/
author: Tom
title: Red, green, refactor. Red, green, refactor
excerpt: |+
  That title is pinched blatantly from the excellent Test Driven Development course by fellow [Skills Matter](http://skillsmatter.com) instructor and agile programming luminary [Craig Larman](http://craiglarman.com). Can you still say red/green when you run your tests on the command line? [grin] (Correction: when you run them from Emacs -- a very big thanks to [this chap](http://lathi.net/twiki-bin/view/Main/EmacsAndRuby)).
  
  Yes it's test-driven-development week here at Hobo central (the above banner, btw, is the tranquil view from Hobo HQ).
  
published: true
tags: []

date: 2006-11-23 09:39:12 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobotek.net/blog/2006/11/23/red-green-refactor-red-green-refactor/
author_url: http://www.hobocentral.net
status: publish
---
That title is pinched blatantly from the excellent Test Driven Development course by fellow [Skills Matter](http://skillsmatter.com) instructor and agile programming luminary [Craig Larman](http://craiglarman.com). Can you still say red/green when you run your tests on the command line? [grin] (Correction: when you run them from Emacs -- a very big thanks to [this chap](http://lathi.net/twiki-bin/view/Main/EmacsAndRuby)).

Yes it's test-driven-development week here at Hobo central (the above banner, btw, is the tranquil view from Hobo HQ).

<a id="more"></a><a id="more-13"></a>

After lots of little projects where I've been, shall we say, relaxed about my approach to testing, I'm getting back into the swing of a strict test-first approach. My initial reaction -- boy does it slow you down! I know without a doubt though, that the perceived slow-down is a temporary thing. The double-whammy of keeping bugs at bay, and giving me the confidence to refactor properly, means the quality-bar stays way-up. Without that it wouldn't be long before development would simply grind to halt - collapsing under the weight of it's own unchecked complexity.

So patience is the order of the day -- slow but steady wins the race :-)

All this is a rather long-winded way of saying that I haven't yet put together a simple ajax demo to blog about. I tend to get kinda single-minded when development isn't going as fast as I'd like it to (it never is!). Fortunately there's a [small rodent with sharp teeth](http://redferret.net) reminding me that there's more to a project than just coding :-).

Let's see how things go today. I'm working on the standard tag-library which needs to be as generic as it possibly can be. It turns out I'm not so much building it out (adding tags) as building it "in" (getting the basic set of tags just right). If I make good progress today I'll see if I can't knock up that ajax demo for you.
