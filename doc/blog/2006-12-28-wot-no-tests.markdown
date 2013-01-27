--- 
wordpress_id: 21
author_login: admin
layout: post
comments: 
- author: Zaheed Haque
  date: Fri Dec 29 09:03:41 +0000 2006
  id: 47
  content: |
    <p>Have you looked at this?</p>
    
    <p>http://www.kuwata-lab.com/kwartz/
    or this?
    http://masterview.org/</p>
    
    <p>your view regarding differences?</p>
    
    <p>Regards</p>

  date_gmt: Fri Dec 29 09:03:41 +0000 2006
  author_email: zaheed.haque@gmail.com
  author_url: ""
- author: Tom
  date: Fri Dec 29 09:53:02 +0000 2006
  id: 48
  content: |
    <p>The purpose of masterview is to allow you to edit your Rails pages in an editor like Dreamweaver and still be able to use layouts and partials.</p>
    
    <p>There is some overlap, in that both DRYML and Masterview allow you to move partials back into the main template, but the overall goal of Masterview is almost the opposite of what Hobo is about. Hobo takes the view that a huge part of the development effort takes place in the view layer so we should use the techniques of agile software engineering to make life easier. DRYML makes it a lot easier to re-use view code. Your views become little "programs" which you could never edit in Dreamweaver, but are <em>dramatically</em> less work than struggling in a point-and-click editor.</p>
    
    <p>I hadn't seen Kwartz before -- just read up on it and I'm not buying it. They're separating "presentation data" from "presentation logic" which means the HTML file has no embedded looping or branching logic. This means all the logic has to be indirected using id attributes which is going to make the things very tedious to edit. The benefit is that your HTML gets to be just plain HTML, so again you can use Dreamweaver. If that's important to you, well and good, but it's going to make you a lot less agile.</p>
    
    <p>If you want to be agile, you need to use agile techniques in your views just as you do everywhere else -- this is software engineering, not word-processing. What I'd <em>really</em> like to see is a new kind of WYSIWYG editor, that lets designers work in an agile way, with a high degree of re-use, but gets as close as possible to the ease-of-use that today's editors have. That's a whole different project though :-)</p>

  date_gmt: Fri Dec 29 09:53:02 +0000 2006
  author_email: tom@livelogix.com
  author_url: http://
- author: Zaheed Haque
  date: Fri Dec 29 10:26:56 +0000 2006
  id: 49
  content: |
    <p>Good explanation! I buy it :=) Actually the purpose of the posting was to get your opinions. I am in the process of developing an application and I find hobo rather exciting. However I need evaluate whats out there and the status of such project. I see that you are against categorizing Hobo and Streamlined in one group. Although it would be interesting to see "Hobo Admin" right out of the box. Now regarding production readiness of hobo any time line? I need to use it for a commercial projects and would be nice to know a bit of the roadmap</p>
    
    <p>Cheers</p>

  date_gmt: Fri Dec 29 10:26:56 +0000 2006
  author_email: zaheed.haque@gmail.com
  author_url: ""
- author: Tom
  date: Fri Dec 29 11:14:18 +0000 2006
  id: 50
  content: |
    <p>Hobo will definitely provide admin functionality out of the box. In fact it does already, but it's kind of early-stage. I'm experimenting with the idea of blending admin functionality right into the app, so if you're logged in as admin, you can edit things in-place that other people can't, you see options to create things that other people don't (e.g. "New Category") in the POD demo, and so on.</p>
    
    <p>I guess this idea is kind of experimental. If we find, in the context of a real app, that we do need a separate admin area of  the site, support for that will get added to Hobo.</p>
    
    <p>I'm intending to get Hobo "production ready" in just a few  weeks time. I have one site in particular that I want to release to a beta audience as early as next week.</p>
    
    <p>"Production ready" might not mean "highly scalable" for a while (see the Status page), but we should be able to nail any security concerns pretty soon (Hobo will not come with any guarantees though of course!).</p>

  date_gmt: Fri Dec 29 11:14:18 +0000 2006
  author_email: tom@livelogix.com
  author_url: http://
- author: Zaheed Haque
  date: Fri Dec 29 12:07:09 +0000 2006
  id: 51
  content: |
    <p>Some random ideas regarding "admin" :=)</p>
    
    <ol>
    <li><p>There are some general concepts to all web applications, i.e. managing users, adding new language, live editing DRYML/HTML for quick corrections, selecting, uploading themes etc bottom line the basics. These features always repeat almost in every web applications. It would be nice if Hobo admin could do that right out of box. Furthermore I would like to add that "admin" should be separate rails app. However I like your context/admin aprroach with "Extra Navigation" bar with extra stuff. Ajax. </p></li>
    <li><p>Application specific admin. I believe it is very hard to do cos every application has its own twist. However one could provide some boiler plate for modifications. For example lets say if you are building an RSS reader you will need to add RSS feeds, verify the feeds are correct, categorize the feeds etc.. and it is really difficult for Hobo to know all of the above use case in advance but providing some custom sort of starter guide for further development would be nice.</p></li>
    <li><p>I have also thought about that what one can also do is run hobo in "web mode". What I mean is that </p></li>
    </ol>
    
    <blockquote>
      <p>hobo</p>
    </blockquote>
    
    <p>kick start a web application builder in the browser and you use the web to name your app, database, select themes, language what not and push the button "create my app" it will then create your app stop the builder app and load the new app in the browser...</p>
    
    <p>I think the above is possible and it would really cool!</p>
    
    <p>just some random thoughts!</p>
    
    <p>Cheers</p>

  date_gmt: Fri Dec 29 12:07:09 +0000 2006
  author_email: zaheed.haque@gmail.com
  author_url: ""
- author: Gustav Paul
  date: Tue Jan 09 10:23:25 +0000 2007
  id: 90
  content: |
    <p>Glad to hear you're locked down! I didn't see any tests in the subdirectory and assumed you didn't have any.</p>
    
    <p>If I may: Why aren't the tests included when you checkout the project?</p>

  date_gmt: Tue Jan 09 10:23:25 +0000 2007
  author_email: gustav@rails.co.za
  author_url: http://rails.co.za
- author: Tom
  date: Tue Jan 09 10:32:30 +0000 2007
  id: 91
  content: |
    <p>Hey - welcome back. Hope you had fun rock climbing. Yes I read your blog :-)</p>
    
    <p>The tests are in a Rails-app which uses Hobo - actually it's the app that Hobo kind of grew out of. I'm not ready to release that app. What I want to do is migrate the tests over to the plugin, and clean it all up in the process. I'm wondering about switching to a BDD style.</p>

  date_gmt: Tue Jan 09 10:32:30 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Gustav Paul
  date: Wed Jan 10 21:51:05 +0000 2007
  id: 99
  content: |
    <p>Rock climbing was awesome thanks!</p>
    
    <p>I like the idea of going BDD (with rspec i presume?). Doing so may cut off potential developers from contributing though (many/most people are comfortable with tests and won't be as eager to learn rspec as I was :])</p>
    
    <p>This sounds like a good topic to warm the mailing list with?</p>

  date_gmt: Wed Jan 10 21:51:05 +0000 2007
  author_email: gustav@rails.co.za
  author_url: http://rails.co.za
author: Tom
title: Wot no Tests?
published: true
tags: []

date: 2006-12-28 18:13:21 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2006/12/28/wot-no-tests/
author_url: http://www.hobocentral.net
status: publish
---
Just looking through my referers and found [this post](http://rails.co.za/articles/2006/12/25/holidays). Quote:

> I&acirc;&euro;&trade;ll start writing some tests for it when I get back (looks like it&acirc;&euro;&trade;s in need of some)

`*Blush* :-)` Actually I have 128 tests with 298 assertions (which is better than nothing but not nearly enough for something on the scale of Hobo). But they're sitting in the app that gave birth to Hobo. It wasn't until recently that I discovered how to set up a full Rails testing environment within a plugin. To be honest the app and tests are kind of a mess. I really want to extract the tests into the plugin test directory, and clean everything up a bit in the process.

Meanwhile if anyone really wants access to the tests you might be able to twist my arm :-)
