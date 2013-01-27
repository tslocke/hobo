--- 
wordpress_id: 141
author_login: admin
layout: post
comments: 
- author: NomDePlume
  date: Mon Mar 19 01:03:54 +0000 2007
  id: 943
  content: |
    <p>Well, there is automation and then there is automation. These days DSL's are in fashion and we see people doing their "DSL Thang" but most of the DSL's are actually  cumbersome and confusing. I don't get the newest SQLDSL.. (no offense to the creator). Same goes with a so called DSL created some time ago to "ease" the task of shell scripts by creating a ruby dsl. Wrapping something in the language of one's choice is not automation, it is just restating the problem in familiar terms (to the author). </p>
    
    <p>Even looking at Hobo, one fears that the line between automation and even-more-complexity is a thin one. It would be so easy for it to devolve into a steam engine of a device with knobs and levers and valves sticking out of every nook and cranny of the cock-pit. Something which reminds one of the rails helpers and utility methods and all kinds of things which just go on and on for pages and pages. </p>
    
    <p>I am a novice to web development and gui programming in general, but I always wonder why is it that one has to do so much work.. even with something like Rails(TM) when the page primitives and abstractions are so simple. A header, left column, main column, right column and a footer. with containers inside each column.</p>
    
    <p>Maybe it is the very thing that make one a "framework developer", namely, the capability to deal with complexity, which eventually starts showing up in the framework itself, in the form of complexity. The complexity of abstractions. So now the user has the added burden of not only knowing the abstractions, but also the various nuances of each abstraction itself. </p>
    
    <p>Somewhere along the way the abstractions break down and the automation itself becomes a set of chores, just a different set of chores just as boring and tedious. It would be cool if we had a limited number of widgets with defined interfaces and we could just drop them. HyperCard came very close to it, but it got strangled just in time. So now we have a "much improved" apple-script which is just utterly useless.  </p>
    
    <p>IMO, building web pages should be just as intuitive as writing text. This is one reason the web pages of real hot shot icons of computer science are so shitty. Look at Knuth's page. Why can't a guy who created something like TeX and wrote seminal works like "The Art of Computer Programming" , create a half decent web page with rounded corners and all that good stuff? Why is the onus on him to know the language of design when most pages could be created with a relatively stable set of rules and primitives and "skinning" could be just applied to whatever was on there? Is the fault with Knuth? or with those of us who have spent years barking up various fad trees while the problem "creating a dynamically generated page" is still as elusive as ever? </p>
    
    <p>sorry, got a bit tangential but the talk of automation gets me going on these tangents :-)</p>

  date_gmt: Mon Mar 19 01:03:54 +0000 2007
  author_email: ""
  author_url: ""
- author: Tom
  date: Tue Mar 20 18:03:39 +0000 2007
  id: 963
  content: |
    <p>NomDePlume - some feedback</p>
    
    <blockquote>
      <p>It would be so easy for it to devolve into a steam engine of a device with knobs and levers and valves sticking out of every nook and cranny of the cock-pit.</p>
    </blockquote>
    
    <p>I agree - that's something we have to watch out for</p>
    
    <blockquote>
      <p>Something which reminds one of the rails helpers and utility methods and all kinds of things which just go on and on for pages and pages.</p>
    </blockquote>
    
    <p>Now I disagree :-) There is such a thing as innate complexity. There are a lot of helpers because there are a lot of little things we often need to do in web pages. We could always wrap things up in higher level abstractions, like a search-widget for example, but there'll always be a time when you need to go under the hood, and when you do you'll be glad they are all still there.</p>
    
    <blockquote>
      <p>I am a novice to web development and gui programming in general, but I always wonder why is it that one has to do so much work.. even with something like Rails(TM) when the page primitives and abstractions are so simple.</p>
    </blockquote>
    
    <p>It amazes me too! Complexity is a tenacious thing - it just doesn't like going away and staying away. If you want a truly well-crafted web-app, there are always an amazing number of details you need to deal with. But what if such attention to detail is not needed? What if you need to knock up a quick solution and you're not too bothered about the nuances of interaction design. That, I feel, is where current tools let you down. Hobo is trying to create a continuum from quick-and-standard, to slow-and-hand-crafted. By 'standard' I mean having some usability compromises.</p>
    
    <blockquote>
      <p>IMO, building web pages should be just as intuitive as writing text.</p>
    </blockquote>
    
    <p>Web <em>pages</em> maybe. Web <em>applications</em>? That's science fiction at this stage.</p>

  date_gmt: Tue Mar 20 18:03:39 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
author: Tom
title: The cost of automation
published: true
tags: []

date: 2007-03-18 12:45:54 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/03/18/the-cost-of-automation/
author_url: http://www.hobocentral.net
status: publish
---
Very interesting point over on S/N:

> [Auto-mode vs. shooting manual](http://www.37signals.com/svn/posts/321-auto-mode-vs-shooting-manual)

Is Hobo guilty of putting up another layer? Of blurring your vision? The answer can't be a straightforward "yes", because that road would lead back to hacking assembly-code by hand.

Many photographers like to *develop* their film by hand too. If Hillman Curtis did that with his movie, for every frame, he'd definitely get a richer result. He'd also never finish.

I think it comes down to a simple trade-off -- every time you flick an "auto" switch off, development time goes up, but quality goes up too - people always do things better than machines. Which switches you flick is a judgement call that has to be made for each switch and for each project.

The interesting thing about Hobo is that it lets you, if you so choose, start with all the switches on. You can then switch them off one by one, gradually replacing the automatic with the hand-crafted.
