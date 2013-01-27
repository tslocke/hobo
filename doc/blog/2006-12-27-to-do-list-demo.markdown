--- 
wordpress_id: 19
author_login: admin
layout: post
comments: 
- author: Adrian Madrid
  date: Wed Dec 27 23:11:35 +0000 2006
  id: 41
  content: |
    <p>Tried it and it looks really good. The whole rapid concept is very interesting but where I need more help is in figuring out how to modify the <em>scaffolding</em>. For example, once you create a task you can change the note but you can't change the title. How do you make it so the title is editable? One probable bug is that I could not get the search to work. I typed and also pressed enter but nothing happenned. Looked at the html but I didn't see any JS calls and Firebug did not complain about any errors. Is it just missing? I'm looking forward to where it's production ready. I'll keep checking the site often.</p>

  date_gmt: Wed Dec 27 23:11:35 +0000 2006
  author_email: aemadrid+hobo@gmail.com
  author_url: ""
- author: Tom
  date: Thu Dec 28 08:36:56 +0000 2006
  id: 43
  content: |
    <p>Adrian -- actually the title is editable - you can click to edit (provided you are logged in and have update permission for that task). The theme really needs updating so that there's some visual cue that the title is editable.</p>
    
    <p>I'll be posting a screencast on customising the views, but in the meantime I think I'd better do a post with a few quick tips.</p>
    
    <p>Search should be working - it works for me. You should see this javascript in the source:</p>
    
    <pre><code><body onload="Hobo.applyEvents(); Hobo.doSearch('search_field')">
    </code></pre>
    
    <p>Do you see the spinner appear?</p>

  date_gmt: Thu Dec 28 08:36:56 +0000 2006
  author_email: tom@livelogix.com
  author_url: http://
- author: Adrian Madrid
  date: Thu Dec 28 20:10:59 +0000 2006
  id: 46
  content: |
    <p>Tom -- I was trying to click on "Task:" instead of clicking on the  actual task name. It does work and it lets you edit there but you are right: we need visual cues (an icon?) to make it clear that it is editable. On the search I tried again and it does work although only after I typed 3 letters. I was looking for "ic" since a few of my entries were "ic*" like so nothing was happening. And thanks for the post on customizing the CRUD. I was suspceting it was something like that but I didn't have time to test it. I'll give it a shot.</p>
    
    <p>Thanks, </p>
    
    <p>AEM</p>

  date_gmt: Thu Dec 28 20:10:59 +0000 2006
  author_email: aemadrid+hobo@gmail.com
  author_url: ""
- author: matthibcn
  date: Fri Dec 29 16:40:04 +0000 2006
  id: 53
  content: |
    <p>Is there any chance you publish your demo"pods" in any readable format ??</p>
    
    <p>.mov is a bad choice anyway in internet since ever, as its installed in less than 60% of all your potential users machines, but in addition it looks like you use some extra features my QTPlayer cant install as it tells me, that this components are not found/available on QTServer.</p>
    
    <p>So, I would to encourage you to make your stuff for masses, not just for those who are willing to buy their hardware from a specific manufacture</p>
    
    <p>Thanks and hapy new year</p>
    
    <p>matthi</p>

  date_gmt: Fri Dec 29 16:40:04 +0000 2006
  author_email: ""
  author_url: ""
- author: Tom
  date: Fri Dec 29 18:40:46 +0000 2006
  id: 54
  content: |
    <p>Yeah I realise quicktime is not the most portable format. I've been trying to find another decent format but the file ends up twice the size and the quality is poor.</p>
    
    <p>If anyone can recommend a good format/encoder I'd be very grateful. Is there anything optimised for screencasts?</p>
    
    <p>Meanwhile there is a Google Video version <a href="http://video.google.co.uk/videoplay?docid=2527153840941403688" rel="nofollow">here</a>, but the quality is poor.</p>

  date_gmt: Fri Dec 29 18:40:46 +0000 2006
  author_email: tom@livelogix.com
  author_url: http://
- author: matthibcn
  date: Fri Dec 29 20:18:18 +0000 2006
  id: 55
  content: |
    <p>Thanks for your fast answer.</p>
    
    <p>The most portable would be flash6, but in any case it would help a lot if you could convert it just in another 1 or 2 formats, as mpeg etc, or just the most basic mov available.</p>
    
    <p>The wired thing is, that I do have the QTPlayer, but hes missing some stuff he even cant find on the QTServer, so I have no clue what you have done, but there must be some option, that is even within the .mov not the most common, probably some applespecific stuff..I am just guessing now...</p>
    
    <p>Anyway, thanks, and I will try to see it now</p>
    
    <p>Regards</p>
    
    <p>matthi</p>

  date_gmt: Fri Dec 29 20:18:18 +0000 2006
  author_email: ""
  author_url: ""
- author: Paul Davis
  date: Mon Jan 08 19:33:30 +0000 2007
  id: 88
  content: |
    <p>Pretty cool.
    I recently put together a method for todo lists using XML. Since almost all browsers have an XSL processor built in, I just link it to an xsl file to convert to html in the browser.
    There's a page on my site here:
    http://willcode4beer.com/design.jsp?set=todoList
    that explains a little better.
    I've also got a little demo on it.</p>

  date_gmt: Mon Jan 08 19:33:30 +0000 2007
  author_email: willcode4beer@gmail.com
  author_url: http://willcode4beer.com
- author: Michael
  date: Wed Mar 28 04:11:09 +0000 2007
  id: 1093
  content: |
    <p>great podcasts/demos---</p>
    
    <p>Is there a built-in Role-based Authentication model?</p>
    
    <p>Something to build on permissions within a given role or region?  </p>
    
    <p>For example, I would want people in marketing to create marketing todos, but not engineering todos.</p>

  date_gmt: Wed Mar 28 04:11:09 +0000 2007
  author_email: mc@itpath.com
  author_url: http://www.itpath.com
- author: Tom
  date: Wed Mar 28 08:53:07 +0000 2007
  id: 1107
  content: |
    <p>Michael - no there's no roles or anything like that built in, but it would be very easy to implement in your app. e.g.</p>
    
    <pre><code>class Task < ActiveRecord::Base
      def creatable_by?(person)
        department.in?(person.departments)
      end
    end
    </code></pre>

  date_gmt: Wed Mar 28 08:53:07 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Robert Berger
  date: Wed Apr 11 07:55:21 +0000 2007
  id: 1526
  content: |
    <p>Should the todo demo run with the current  Rails 1.2.3?</p>
    
    <p>I tried to do a rake db:migrate and get  all sorts of errors where it can't find various things to load via require (like rexml, extensions and even hobo)</p>
    
    <p>I have been able to build other hobo stuff from scratch... </p>
    
    <p>Am I doing something stupid or is the todo demo crusty?
    Thanks</p>

  date_gmt: Wed Apr 11 07:55:21 +0000 2007
  author_email: rberger@ibd.com
  author_url: http://rbergeribd.com
- author: Tom
  date: Wed Apr 11 21:12:24 +0000 2007
  id: 1551
  content: |
    <p>Robert - I'm running 1.2.3 and I was able to migrate and run the demo without problem. I did notice some problems with the theme though, so I've uploaded a new version of the demo. I don't think the new version will fix your problem though.</p>

  date_gmt: Wed Apr 11 21:12:24 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Bakki Kudva
  date: Mon Apr 30 00:26:54 +0000 2007
  id: 2288
  content: |
    <p>I stumbled upon your site while researching 'model security' at Bruce Perens model_security site. I downloaded and started coding using hobo and it is pretty darn cool, particularly dryml! Great job guys!! Now a question.</p>
    
    <p>I have an app where the resources belong to users/groups. Permissions should resemble unix fs rwx-rwx-rwx on each record in the model, The user should be able to set it for group/all. Here x means they can perform certain  set of operations on the resource such as email, reports etc. I am not that familiar with acts<em>as</em>authenticated and was wondering if hobo's permission model can be extended to accomplish this. Any suggestions?</p>

  date_gmt: Mon Apr 30 00:26:54 +0000 2007
  author_email: bakki.kudva@gmail.com
  author_url: ""
- author: Christopher
  date: Sun May 06 05:47:32 +0000 2007
  id: 2506
  content: |
    <p>Robert's right. When attempting to migrate on the todo demo, I receive errors as well. Anyone got some advice?</p>
    
    <p>My error looks like this:</p>
    
    <p>"E:0:Warning: require_gem is obsolete.  Use gem instead."</p>

  date_gmt: Sun May 06 05:47:32 +0000 2007
  author_email: ctmann@gmail.com
  author_url: ""
- author: Ivan
  date: Thu May 17 06:03:26 +0000 2007
  id: 2992
  content: |
    <p>Nice</p>

  date_gmt: Thu May 17 06:03:26 +0000 2007
  author_email: aaaaaa@gmail.com
  author_url: http://www.lcsc.edu/NS350/_discNS350/000003d9.htm?zyloprim
- author: Marc
  date: Sat Jul 07 07:15:28 +0000 2007
  id: 7034
  content: |
    <p>Good demo for the permissions, only bad thing is that the search will still return the private items, any suggestions?</p>

  date_gmt: Sat Jul 07 07:15:28 +0000 2007
  author_email: marc@jupiter-labs.com
  author_url: ""
- author: Tom
  date: Tue Jul 10 08:33:56 +0000 2007
  id: 7198
  content: |
    <p>Marc - this should be fixed if you're using a recent version.</p>

  date_gmt: Tue Jul 10 08:33:56 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Adamh
  date: Thu Sep 27 10:38:36 +0000 2007
  id: 11607
  content: |
    <p>Hi. I think Hobo is fantastic but the lack of documentations won't put it in the spotlight for a while. 
    In the topic of permissions I played with the authorization plugin http://www.writertopia.com/developers/authorization and everything works fine, you just have to make some additional admin pages for role/permissions assignments.</p>

  date_gmt: Thu Sep 27 10:38:36 +0000 2007
  author_email: hoscilo@gmail.com
  author_url: http://hoscilo.pypla.net
- author: naisioxerloro
  date: Thu Nov 29 00:08:32 +0000 2007
  id: 16841
  content: |
    <p>Hi. 
    Good design, who make it?</p>

  date_gmt: Thu Nov 29 00:08:32 +0000 2007
  author_email: naisioxerloro@mymail-in.net
  author_url: ""
- author: Brandon
  date: Tue Apr 01 15:20:38 +0000 2008
  id: 30417
  content: |
    <p>@matthibcn: QuickTime has been available for Windows for ages, and QT support has been available for Linux for quite a while too, just not from Apple: http://www.heroinewarrior.com/quicktime.php3 .</p>
    
    <p>(Apple writes a surprising number of things for Windows, but as far as I can remember Shake is the only thing they've offered for Linux, basically because they bought the software from another company and it already had a Linux version.)</p>
    
    <p>Anyway, as Tom says, it's great quality.  And it is available just about everywhere.   Also, unlike software from Real or Microsoft, you don't have to worry that they're going to install spyware or something else on your system.    So I'd much rather have QuickTime than Real or Windows Media Player.</p>
    
    <p>I agree with you that having a Flash option is a good idea, but just want to let you know that you're not automatically 'locked out' when someone uses QuickTime.  It's really not tied to hardware choice.   (Well, maybe it is, since you probably can't view it on your Nokia ;)</p>

  date_gmt: Tue Apr 01 15:20:38 +0000 2008
  author_email: brandon.zylstra@gmail.com
  author_url: http://brandonzylstra.com
author: Tom
title: To-Do List Demo
excerpt: |
  I've posted another demo -- this one is a simple to-do list app (see the [Demos](/blog/demos) section). The app took about 10 - 15 minutes to create, which includes figuring out the (minimal!) design.
  

published: true
tags: []

date: 2006-12-27 17:34:32 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2006/12/27/to-do-list-demo/
author_url: http://www.hobocentral.net
status: publish
---
I've posted another demo -- this one is a simple to-do list app (see the [Demos](/blog/demos) section). The app took about 10 - 15 minutes to create, which includes figuring out the (minimal!) design.

<a id="more"></a><a id="more-19"></a>

This demo illustrates a little more of what you can do with the permission system. Each to-do list has a `public?` attribute. Public lists can be viewed by any visitor to the site, whereas private lists can only be viewed by the owner of the list. Here's a couple of fragments from the `TodoList` model that show how we set this up:

#### class TodoList (fragments)

	belongs_to :user
	has_many :tasks
	
	def viewable_by?(viewer, field)
	  viewer == user or public?
	end

Clearly we want this view permission to carry over to the individual tasks in the list. First we define `public?` and `owner` methods on the `Task` model:

#### class Task (fragments)

	belongs_to :todo_list

  	def owner
      todo_list and todo_list.user
  	end

	def public?
      todo_list and todo_list.public?
  	end

The owner of a task is the owner of the to-do list it belongs to, and a task is public if it belongs to a list and that list is public. Note that the implementation of these rules is no longer than the descriptions I'm giving in English. Now we can define view permission for the task:

#### class Task (fragment)

	def viewable_by?(viewer, field)
      viewer == owner or public?
  	end

Run up the demo and have a look at the way these permissions effect the user-interface, as seen by a guest user, a signed in user, and the administrator (to create the administrator, just sign up as "admin"). Are there any holes? You might notice that the front page gets a little out of whack. This is because at the moment there's no way to count the number of public to-do lists, or, say, fetch the first three public lists. That would have to be coded manually.
