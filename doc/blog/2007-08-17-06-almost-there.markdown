--- 
wordpress_id: 167
author_login: admin
layout: post
comments: 
- author: untaldouglas
  date: Fri Aug 17 23:45:16 +0000 2007
  id: 9273
  content: |
    <p>All that I can say is :</p>
    
    <p>Muchas Gracias !</p>
    
    <p>....</p>

  date_gmt: Fri Aug 17 23:45:16 +0000 2007
  author_email: douglasag@gmail.com
  author_url: http://startya.blogspot.com/
- author: ylon
  date: Sat Aug 18 05:52:19 +0000 2007
  id: 9290
  content: |
    <p>Great news Tom.  Do let me know if you need some help on the video front as I'd mentioned before.  I'd be happy to help massage and refine anything as per your liking.</p>

  date_gmt: Sat Aug 18 05:52:19 +0000 2007
  author_email: ""
  author_url: ""
- author: Hendy Irawan
  date: Wed Aug 22 05:17:58 +0000 2007
  id: 9458
  content: |
    <p>Tom I think it'd be great if on the next version Hobo can be sliced into tinier pieces, almost the same way that Rails is.</p>
    
    <p>People wary of thinking about the size of complexity of Hobo (internally) can use Hobo individual components (e.g. just DRYML, or just the model controller, just the auth.. etc.)</p>

  date_gmt: Wed Aug 22 05:17:58 +0000 2007
  author_email: hendy@rainbowpurple.com
  author_url: http://www.hendyirawan.com/
- author: Tom
  date: Wed Aug 22 07:26:43 +0000 2007
  id: 9462
  content: |
    <p>Hendy - that's a popular request. It's something we're considering doing post 1.0. Right now it would only make for more work for us and we don't really have the resources. Having said that, it is possible right now to <em>install</em> all of Hobo but only <em>use</em> some bits.</p>

  date_gmt: Wed Aug 22 07:26:43 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
author: Tom
title: 0.6 almost there
published: true
tags: []

date: 2007-08-17 16:39:25 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/08/17/06-almost-there/
author_url: http://www.hobocentral.net
status: publish
---
Wow -- getting all our tests upgraded to the new DRYML, not to mention getting them all to pass, has been a real slog, but we just crossed the finish line. All the tests are green. We now have to make sure things like Pod and the to-do demo are working, and that fresh Hobo apps with all the Rapid pages work too. Then there's the changelog, and we'll be ready for take-off. 

This has been a huge effort to get working, as we've had three major upheavals: new DRYML, much improved standard tag libraries, and a move from Rails 1.2 to Edge Rails (don't forget to rake rails:freeze:edge -- that's required now, and will be until we hit 1.0).

Almost there!
