--- 
wordpress_id: 142
author_login: admin
layout: post
comments: 
- author: Amr
  date: Thu Mar 22 14:46:50 +0000 2007
  id: 1011
  content: |
    <p>Heh, thanks to this post, I have rb-appscript isntalled and itunes-cli installed and controlling my iTunes from the commandline. </p>
    
    <p>I found this tutorial on rb-appscript in case anyone's interested.</p>
    
    <p>http://www.gemjack.com/gems/rb-appscript-0.3.0/appscript-manual/index.html</p>

  date_gmt: Thu Mar 22 14:46:50 +0000 2007
  author_email: ""
  author_url: ""
author: Tom
title: rb-appscript is cool
excerpt: |
  After a small typo in the Hobo manual was reported in the forum (thanks!), I decided I'd like to automate the process of updating the manual.
  
  I had two awkward bits that I was doing manually - conversion from Markdown to HTML, and conversion from Markdown to PDF.
  

published: true
tags: []

date: 2007-03-21 17:37:47 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/03/21/rb-appscript-is-cool/
author_url: http://www.hobocentral.net
status: publish
---
After a small typo in the Hobo manual was reported in the forum (thanks!), I decided I'd like to automate the process of updating the manual.

I had two awkward bits that I was doing manually - conversion from Markdown to HTML, and conversion from Markdown to PDF.

<a id="more"></a><a id="more-142"></a>

"Eh?" I hear you cry? Manually converting Markdown to HTML? Have you never heard of BlueCloth? Well, I chose not to use BlueCloth because it, er, didn't work. It choked on my markup, which looks fine to me, and converts just fine in Textmate. But today I somehow stumbled across [Maruku](http://maruku.rubyforge.org/) which works great, and even has some nifty markdown extensions which I'm sure I'll use.

One down, one to go - conversion to PDF. The trick here was that I really wanted a solution that allowed me to customise the style of the generated PDF. I really wanted to get to PDF via HTML+CSS. I thought I'd try and ask Safari to do the job for me via AppleScript. It worked!

Of course, I wouldn't dream of trying to actually code AppleScript. If you're on MacOS, go have a play with [rb-appscript](http://rb-appscript.rubyforge.org/index.html). It's good stuff. The cool part is that because it's all Ruby, you can fire it up in `irb` and make all your desktop apps jump around at your interactive command.

In order to get Safari to save a PDF at my slightest whim, there was one more trick required - I needed a "PDF File" printer (there's no way to access the "save a pdf file" feature from AppleScript). I eventually found [cups-pdf for Mac](http://www.codepoetry.net/projects/cups-pdf-for-mosx) which works great. All my apps now see "PDF File" as a virtual printer.

Here's the Ruby code that gets Safari to do the needful:

    require 'rubygems'
	require 'appscript'
	safari = Appscript.app('Safari')
	safari.open_location("file://#{Dir.getwd}/manual.html")
	safari.documents[0].print(:with_properties => {:target_printer => "PDF File"})
	safari.documents[0].close
	
That `documents[0]` looks a bit dodgy, but I couldn't figure out how to say "the document I just loaded".

So bring on your typos! I've so got it covered.
