--- 
wordpress_id: 23
author_login: admin
layout: post
comments: 
- author: John
  date: Fri Jan 05 16:37:24 +0000 2007
  id: 72
  content: |
    <p>Tom, </p>
    
    <p>great stuff. Give us an email or a paypal account so we can donate if we like, ok?</p>
    
    <p>Thanks,
    John</p>

  date_gmt: Fri Jan 05 16:37:24 +0000 2007
  author_email: acheekymonkey@mac.com
  author_url: ""
- author: Tom
  date: Fri Jan 05 16:42:55 +0000 2007
  id: 73
  content: |
    <p>Um. Gosh :-) I have a paypal account at tom@livelogix.com. Thanks very much!</p>

  date_gmt: Fri Jan 05 16:42:55 +0000 2007
  author_email: tom@livelogix.com
  author_url: http://
- author: shaggy
  date: Sat Jan 06 03:45:09 +0000 2007
  id: 75
  content: |
    <p>very nice! i suppose you've seen CSS dryer => http://blog.airbladesoftware.com/2006/12/11/cssdryer-dry-up-your-css
    anyway i'm a designer learning ruby and rails and the dryml looks great. unarguably cleaner.</p>
    
    <p>there is also HAML => http://unspace.ca/discover/haml/ where whitespace and indentions count. but this may be to minimal... is that possible?</p>

  date_gmt: Sat Jan 06 03:45:09 +0000 2007
  author_email: scott@romack.net
  author_url: http://www.romack.net
- author: Tom
  date: Sat Jan 06 09:40:26 +0000 2007
  id: 76
  content: |
    <p>shaggy - no I hadn't come across CSS dryer. AWESOME! I totally love it. This is definitely going into my standard toolkit. Hmmm, if I start using this for Hobo themes then Hobo will have a dependency on the CSS Dryer plugin. No big deal.</p>
    
    <p>HAML I have seen and I'm not convinced to be honest. I find it rather unreadable.</p>

  date_gmt: Sat Jan 06 09:40:26 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: UnTalDouglas
  date: Sun Jan 07 08:05:46 +0000 2007
  id: 80
  content: |
    <p>Great Application,</p>
    
    <p>My two cents for the paypal account; you should also have a wish list from Amazon, 'couse there are some countries were donations can not be done by paypal(El Salvador for example).</p>
    
    <p>I would like to help maybe in traslating some how your app.
    I've trying other alternatives over RoR, buy yours is ahead of time.</p>
    
    <p>Felicitaciones</p>

  date_gmt: Sun Jan 07 08:05:46 +0000 2007
  author_email: douglasag@yahoo.com
  author_url: http://www.tecnoforo.com
- author: Amr
  date: Sun Jan 07 23:35:21 +0000 2007
  id: 85
  content: |
    <p>It would be great when you are able to opensource that example app. I'm very impressed by hobo so far. Best wishes in the new year with hobo, and I agree with UnTalDouglas that amazon list would be another option for some folks who would like to show their appreciation.</p>

  date_gmt: Sun Jan 07 23:35:21 +0000 2007
  author_email: ""
  author_url: http://oneless.blogspot.com
- author: Daniel Fischer
  date: Mon Jan 08 03:57:13 +0000 2007
  id: 86
  content: |
    <p>I'd just like to say you're doing a great job.</p>
    
    <p>Can't wait to see more releases :)</p>

  date_gmt: Mon Jan 08 03:57:13 +0000 2007
  author_email: daniel@danielfischer.com
  author_url: http://www.danielfischer.com
- author: Pssst&#8230;.Hobo rocks!! - The Red Ferret Journal
  date: Wed Feb 07 10:51:39 +0000 2007
  id: 276
  content: |
    <p>[...] Hmm&hellip;don&rsquo;t want to get boring or over-blown or anything, but Hobo rocks. No, really. We&rsquo;re starting to get a bit excited.  Related Entries: [...]</p>

  date_gmt: Wed Feb 07 10:51:39 +0000 2007
  author_email: ""
  author_url: http://www.redferret.net/?p=8098
author: Tom
title: Putting Hobo through its paces
excerpt: |+
  To many balls in the air at once, that's my problem. There's Hobo the open source project -- keeping updates flowing, responding to problems you folks are hitting, documentation, and on and on and on. Then there's paying the rent, and right now that means working on a least two, maybe three or four commercial web-sites. The good news is that all of these projects are being built using Hobo, so I'm getting to put Hobo through its paces and I'm *really* enjoying what I'm seeing. 
  
published: true
tags: []

date: 2007-01-05 08:01:22 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/01/05/putting-hobo-through-its-paces/
author_url: http://www.hobocentral.net
status: publish
---
To many balls in the air at once, that's my problem. There's Hobo the open source project -- keeping updates flowing, responding to problems you folks are hitting, documentation, and on and on and on. Then there's paying the rent, and right now that means working on a least two, maybe three or four commercial web-sites. The good news is that all of these projects are being built using Hobo, so I'm getting to put Hobo through its paces and I'm *really* enjoying what I'm seeing. 

<a id="more"></a><a id="more-23"></a>

Yesterday, for example, I was working on one app and noticed that a particular class of user was able to edit something that should have been read-only. I made a quick change to the `updateable_by?` method on the model in question, and refreshed the browser. All the in-place-editors changed to read-only text. On every page in the site. I made a similar change to `deleteable_by?`, and a whole bunch of "Remove" buttons vanished. Unless I logged in as an administrator -- then they all came back again.

In another story, I was editing a view of a person. People in this app have many discussions. There is a preview of some recent discussions on the person's home page, but I realised I needed a place where they could see *all* of their ongoing discussions. I added a quick `<object_link attr="discussions"/>` and then, er, refreshed the browser. Job done - the page in question was built entirely automatically by Hobo. OK to be honest I'll probably have to customise that page a little, but that will be a quick and painless task.

All in all it's kind of a jaw-dropping experience. Right now things are still at the stage where I frequently find myself dipping into the Hobo source to add a small feature or to tweak something to be a bit more flexible, or implement some corner case. But the need to do that is diminishing rapidly. Once Hobo really matures, I really think it's going to set a new bar for how much work it takes to build a web app.

The app I've talked about is a fairly sophisticated group collaboration application, with discussions, events and calendaring, classified adverts and a bunch of other stuff. At some point I'll host it for the public as a demo of the capabilities of Hobo. For one thing that should help dispel the misconception I've seen in some places that Hobo is only for building prototypes. Hobo is for that, and for real applications too.
