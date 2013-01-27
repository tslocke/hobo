--- 
wordpress_id: 183
author_login: admin
layout: post
comments: 
- author: bronson
  date: Wed Nov 14 17:30:18 +0000 2007
  id: 15057
  content: |
    <p>This is great news!!  Decoupling will also allow us to install one plugin at a time.  Hopefully upgrading won't be the break-everything trauma it is today.</p>
    
    <p>Just wondering, where are Hobo's Ruby extensions going to live?</p>

  date_gmt: Wed Nov 14 17:30:18 +0000 2007
  author_email: brons_hobo@rinspin.com
  author_url: ""
- author: Tom
  date: Wed Nov 14 17:34:49 +0000 2007
  id: 15058
  content: |
    <p>bronson - Hmm good point, forgot about those. I did take a look at Facets, someone suggested contributing to that project, but I felt it had too much in it, and some stuff was a bit questionable. I guess it will end up being something like hobo_support</p>

  date_gmt: Wed Nov 14 17:34:49 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: shalfacre
  date: Wed Nov 14 17:51:03 +0000 2007
  id: 15061
  content: |
    <p>The plans to break-up the functionality sound good and I am looking forward to seeing and using the results.  However, with that said, I would urge you to consider bringing your documentation and screencasts up to date with the current code base before embarking on a dramatic new development effort.  </p>
    
    <p>As a developer I empathize with the eagerness to make your product the best it can be, at the expense of taking time off for documentation.  However, I know the out of date documentation has been an issue affecting my willingness to recommend Hobo for use by our development team, and I suspect I am not alone in this regard.  Maybe it doesn't need to be as slick as your previous screencasts, but it seems like a comprehensive, accurate, and up to date set of documentation could majorly contribute to the ultimate success of the Hobo project(s).</p>
    
    <p>Hobo is great!  Keep up the good work.</p>

  date_gmt: Wed Nov 14 17:51:03 +0000 2007
  author_email: shalfacre@geonorth.com
  author_url: ""
- author: Tom
  date: Wed Nov 14 17:56:20 +0000 2007
  id: 15063
  content: |
    <p>shalfacre - I totally agree with you that the need for docs is absolutely crucial at this stage. I just don't have the bandwidth to document the whole thing, re-factor it all into a dozen plugins, and then update all the docs.</p>
    
    <p>Instead I'd like to document individual plugins as I go along.</p>
    
    <p>This new effort to break Hobo down is not a huge project. It's <em>FAR</em> less work than documenting the whole thing, so the documentation schedule isn't effected that badly.</p>

  date_gmt: Wed Nov 14 17:56:20 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Sam Livingston-Gray
  date: Wed Nov 14 23:23:17 +0000 2007
  id: 15120
  content: |
    <p>Cool!  Now maybe someone will come up with an alternative to the Rapid tag library.  Scriptaculous edit-in-place looks cool, but it's absolutely awful from a usability standpoint.  ;></p>

  date_gmt: Wed Nov 14 23:23:17 +0000 2007
  author_email: geeksam@gmail.com
  author_url: ""
- author: James
  date: Thu Nov 15 10:37:45 +0000 2007
  id: 15206
  content: |
    <p>Rapid has full support for non-ajax editing, it's just the generic pages that use it inappropriately at the moment. This is only a very small part of what Rapid is about so I wouldn't write it off just because of that.</p>

  date_gmt: Thu Nov 15 10:37:45 +0000 2007
  author_email: ""
  author_url: ""
- author: Kwahu
  date: Thu Nov 15 11:54:40 +0000 2007
  id: 15215
  content: |
    <p>The lack of documentation is a biggest problem in my company. I'm one of 3 ppl that where using HOBO right now and if not my faith in HOBO we would drop using HOBO a long time ago. I have to fight with the rest of the team every day. A least a list of avilable features (even without explanation) would help a lot!!!</p>
    
    <p>Sometimes I just don't knew that I can do a certain thing. If I knew about sth I have a 100% more chance that I will use it lets say by asking other ppl how to use it ;)</p>
    
    <p>Please publicate a list a least ;)</p>
    
    <p>Hugs to all HOBO Team and the HOBO Community !</p>

  date_gmt: Thu Nov 15 11:54:40 +0000 2007
  author_email: kwahus@gmail.com
  author_url: ""
- author: ylon
  date: Thu Nov 15 17:30:10 +0000 2007
  id: 15257
  content: |
    <p>Well, perhaps we should take the following approach?  Obviously Tom &amp; company are going to be doing that which is outlined, however perhaps if we did start with some sort of master list as Kwahu is saying and allow community driven documentation to help Tom and James out along the way so folks could break out and write a little bit about each piece that they discover or things which are explained in IRC, etc..  Just brainstorming, but trying to make things easier for the core developers.</p>

  date_gmt: Thu Nov 15 17:30:10 +0000 2007
  author_email: lists@southernohio.net
  author_url: ""
- author: Owen
  date: Thu Nov 15 17:45:18 +0000 2007
  id: 15259
  content: |
    <p>I think breaking the releases into digestible chunks makes great sense.  What do you think the order will be?  That would help us for planning purposes.</p>

  date_gmt: Thu Nov 15 17:45:18 +0000 2007
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
- author: bronson
  date: Thu Nov 15 19:03:23 +0000 2007
  id: 15271
  content: |
    <p>I started playing with documentation a while ago.  Here's an attempt to get NaturalDocs to work: http://u32.net/tagdoc-noframes  WARNING: that's intended to see if NaturalDocs would work for Hobo; the actual documentation there pretty much sucks.</p>
    
    <p>Verdict: NaturalDocs is crufty.  I'll try to get rdoc to work next, but it's going to take a fair bit of effort and I don't know when I'm going to get the time.  :-/</p>
    
    <p>Kwahu, I'm not sure fighting to get people to use Hobo is a productive thing to do right now.  :)  Personally, I think Hobo is the most exciting thing to happen in all of Rails history but it's still awfully unstable.  And I'm glad it is -- it's improving incredibly fast yet accruing very little cruft.</p>
    
    <p>Still, because of that, I wouldn't consider bringing Hobo into the enterprise right now.  (that said, I actually am using it in the enterprise myself, but they don't know yet and by the time they care Hobo will be stable ;).</p>

  date_gmt: Thu Nov 15 19:03:23 +0000 2007
  author_email: brons_hobo@rinspin.com
  author_url: http://u32.net
- author: bronson
  date: Thu Nov 15 19:23:12 +0000 2007
  id: 15273
  content: |
    <p>I should mention that I don't bill for Hobo upgrade breakage.  I chose Hobo, I get to deal with the consequences myself.  :)</p>

  date_gmt: Thu Nov 15 19:23:12 +0000 2007
  author_email: brons_hobo@rinspin.com
  author_url: http://u32.net
- author: Andy
  date: Fri Nov 16 12:55:25 +0000 2007
  id: 15359
  content: |
    <p>How about a hobo wiki, to document features and host tutorials?</p>

  date_gmt: Fri Nov 16 12:55:25 +0000 2007
  author_email: andystannard@hotmail.com
  author_url: ""
- author: Finn Higgins
  date: Mon Nov 19 21:33:52 +0000 2007
  id: 15808
  content: |
    <p>Wow. Boy do I feel special!</p>
    
    <p>That's incredibly good news, and really all I could possibly have hoped for in terms of keeping track of Hobo as a dependency.  You guys are utter champions.</p>
    
    <p>At the moment I have a few projects that are specifically Rails-only affairs because the model structure isn't too well-suited to Hobo's assumptions about data.  But being able to move the views to DRYML would really make my day.</p>
    
    <p>I'm a very happy man.</p>

  date_gmt: Mon Nov 19 21:33:52 +0000 2007
  author_email: finn.higgins@gmail.com
  author_url: ""
- author: Tom
  date: Tue Nov 20 10:06:20 +0000 2007
  id: 15873
  content: |
    <p>Andy - there is one (part of rthe Hobo Trac) at dev.hobocentral.net</p>

  date_gmt: Tue Nov 20 10:06:20 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Jon
  date: Thu Dec 27 14:41:35 +0000 2007
  id: 19443
  content: |
    <p>With you guys breaking up the pieces of your app, have you thought about using something like merb (http://www.merbivore.com/) in stead of rails? It looks like both teams are having a similar approach: have a strong default set of tools but make it plugable in case those tools don't suit everyone.</p>
    
    <p>Personally, I'd think the combination of merb with datamapper, validatable, rspec and DRYML would be pretty strong.</p>
    
    <p>Just my opinion. Good luck with the breakdown of the components. I can't wait for the DRYML gem/plugin. Keep up the terrific work.</p>

  date_gmt: Thu Dec 27 14:41:35 +0000 2007
  author_email: Jonathan.Hicks@centerstone.org
  author_url: ""
- author: Tom
  date: Fri Dec 28 10:14:56 +0000 2007
  id: 19511
  content: |
    <p>Jon - yes we have taken a look at merb. It does seem to offer some improvements over Rails, and the team seem to have a stronger commitment to a pluggable architecture, which is great for a project like Hobo.</p>
    
    <p>The fact is though, Rails has the traction. There are many factors to consider that are not technical. I'm a strong believer in the idea that the vale of any software infrastructure is directly proportional to how widely it is used.</p>
    
    <p>So for now we'll definitely be sticking with Rails, but keeping a watchful eye on merb.</p>
    
    <p>Some of the Hobo components, particularly DRYML, could conceivably be made compatible with both. That would be very cool :-)</p>

  date_gmt: Fri Dec 28 10:14:56 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
author: Tom
title: Time to break it down
excerpt: |+
  Over in the forums, finnhiggins is letting us know that keeping up with the all the changes to Hobo is a lot of work.
  
  > Hobo has some fantastic ideas that the rest of the Rails community could learn from, but keeping them all tied into a single package that is a very difficult dependency to track is making them pretty inaccessible to developers for the moment.  Some more decoupling during development would be killer, IMHO.
  
  "Can we have this in its own plugin?" is a very often heard request from the folk following Hobo. One that we've been saying no to.
  
  Why?
  
published: true
tags: []

date: 2007-11-14 17:14:37 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/11/14/time-to-break-it-down/
author_url: http://www.hobocentral.net
status: publish
---
Over in the forums, finnhiggins is letting us know that keeping up with the all the changes to Hobo is a lot of work.

> Hobo has some fantastic ideas that the rest of the Rails community could learn from, but keeping them all tied into a single package that is a very difficult dependency to track is making them pretty inaccessible to developers for the moment.  Some more decoupling during development would be killer, IMHO.

"Can we have this in its own plugin?" is a very often heard request from the folk following Hobo. One that we've been saying no to.

Why?

<a id="more"></a><a id="more-183"></a>

The reason we've given is that there are a lot of interdependencies between the different parts of Hobo. Keeping all these parts separate will add an overhead to the development effort -- possibly a significant overhead when you take into account all the extra management associated with having multiple sub-projects. And for what? There would be benefits for those who *don't* want to use all of Hobo, but not so much for those who *do*.  If you put it like that it doesn't sound too tempting.

I'm going to say it plainly -- we got it wrong.

James and I have just been chatting this over and come to the conclusion that the benefits of a collection of de-coupled Hobo "modules" far outweigh the costs:

 * The development overhead of keeping things separate is something we should be doing *anyway*. A monolithic code-base is just going to get increasingly unwieldy.
 
 * A collection of plugins will be more enticing to newcomers -- it's easier to adopt Hobo features one by one than to go the whole hog in one go and say "this one's going to be a Hobo App". (This exact point was made by a DRYML fan on the blog ages ago -- hey, we get there in the end!)
 
 * It's easier to document and to learn smaller plugins with well defined interfaces to each other.
 
 * We think and hope that smaller modules with more sharply defined purposes will be more likely to encourage quality contributions from all you ace developers waiting in the wings :-)
 
 * It's easier to benefit from other projects. Say we decide that [`ez_where`](http://brainspl.at/articles/2006/01/30/i-have-been-busy) or [Ambition](http://errtheblog.com/post/10722) are much better than Hobo's (lame) find extensions, we can drop that plugin like a hot-coal and grab the new shiny one. In other words -- Hobo needs to stop trying to be the best at too many things.
 
Yep - we're doing this!
 
The truth is that the Hobo code-base is already fairly well structured, so there's really not as much work involved as one might fear.

We've had a bit of a scribble on the white-board and the initial stab at a logical breakdown looks like this:

 * Model layer
 
  * General model extensions (Field Types?): Rich types, 'fields do' declaration, migration generator. (note that the migration generator needs the field declaration stuff, so it wouldn't make sense in a plugin of its own)
  
  * Extensions to attribute assignment semantics.
  
  * `def_scope`
  
  * Permission system
  
 * Controller layer
 
  * Resource controller (`hobo_model_controller`), including web-methods
  
  * Data filters / search
  
  * Autocomplete support
  
 * View layer
 
  * DRYML + core tags
  
  * Rapid tag library
  
So that's looking like a set of 9 plugins/gems. The idea is that any of these plugins can be used with or without any of the others, subject to some dependencies of course (Rapid probably won't work too well without DRYML!)

We've pretty much convinced ourselves that this is the way forward now for Hobo. It's going to have an impact on the documentation schedule, because it makes no sense at all to write docs *before* breaking things down. On the other hand, documenting Hobo in small chunks will make the job much easier and should mean you'll get well documented *parts* of Hobo even sooner.

I'm planning to launch into this work pretty much immediately. Big change coming!
