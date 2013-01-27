--- 
wordpress_id: 178
author_login: admin
layout: post
comments: 
- author: Vivek
  date: Tue Nov 06 17:53:44 +0000 2007
  id: 14055
  content: |
    <p>Great, looking forward to it!  Especially eager to see the documentation.  I took a crack at getting a Hobo app up and running by piecing together the blog posts and existing docs.  So much has changed though and I ran into issues so I'm waiting for the long-awaited guide before I try to scale the peak again.</p>
    
    <p>I think you're right on with many of the things you're trying to do with Hobo. Good stuff!</p>

  date_gmt: Tue Nov 06 17:53:44 +0000 2007
  author_email: vivek.x.sharma@gmail.com
  author_url: ""
- author: Niko
  date: Tue Nov 06 18:08:21 +0000 2007
  id: 14057
  content: |
    <p>Nice to see the docu coming. I wish I had more time to play with hobo.</p>
    
    <p>Cheers from Konstanz, Niko.</p>

  date_gmt: Tue Nov 06 18:08:21 +0000 2007
  author_email: ni-di@web.de
  author_url: ""
- author: Will
  date: Tue Nov 06 18:18:54 +0000 2007
  id: 14059
  content: |
    <p>Glad to hear that you are surviving!  Sounds like there are some changes happening, certainly looking forward to seeing what it's like.</p>
    
    <p>I know you didn't ask for a vote or anything, but can I suggest you update the screen casts before you start to tackle the documentation?  It would be easier to help (for me anyway) if we could watch how you go about creating something.</p>
    
    <p>Thanks.</p>

  date_gmt: Tue Nov 06 18:18:54 +0000 2007
  author_email: wschenk@gmail.com
  author_url: http://sublimeguile.com
- author: petef
  date: Thu Nov 08 10:18:50 +0000 2007
  id: 14209
  content: |
    <blockquote>
      <p>hopefully [0.6.3] will make it out of the door -tomorrow-[yesterday].</p>
    </blockquote>
    
    <p>Any news on when we might see this?</p>

  date_gmt: Thu Nov 08 10:18:50 +0000 2007
  author_email: subs@petef.com
  author_url: http://petef.org
- author: Kwahu
  date: Thu Nov 08 11:37:46 +0000 2007
  id: 14215
  content: |
    <p>Looking forward to take my hands on 0.6.3. I finnishing a commercial application using HOBO within next few days. After it will be online I'll give u all a link to have a look ;)</p>

  date_gmt: Thu Nov 08 11:37:46 +0000 2007
  author_email: kwahus@gmail.com
  author_url: http://www.selleo.com
author: Tom
title: Coming up for air
excerpt: |+
  The big app we've been working on over here is finally calming down. Not finished as such, but close enough that we can start to give some attention to the hundred other things we've got on the go, like... Hobo!
  
published: true
tags: []

date: 2007-11-06 16:49:46 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/11/06/coming-up-for-air/
author_url: http://www.hobocentral.net
status: publish
---
The big app we've been working on over here is finally calming down. Not finished as such, but close enough that we can start to give some attention to the hundred other things we've got on the go, like... Hobo!

<a id="more"></a><a id="more-178"></a>

The first benefit will be that Hobo 0.6.3 is on it's way. There are no huge new features, but lots of little touches. In all, over 100 commits since 0.6.2. I've just finished the changelog (which took ages!) so hopefully this will make it out of the door tomorrow.

And of course I haven't forgotten all the docs I've been promising. There's one fairly significant change on it's way first though - we've figured out a way to merge the camel-case `<TemplateTags>` and `<normal_tags>` into one kind of tag, with two different styles for calling the tag. It's going to be a big improvement to the aesthetics of DRYML code. And while we're on aesthetics, we've decided to switch from `<tags_with_underscores>` to `<tags-with-dashes>`. Don't freak out -- we're going to provide a rake task that will update your existing DRYML source automatically. We've got enough DRYML code ourselves to make it well worth the effort to write that utility.
        
Overall you can expect to see a general upturn in activity in the Hobo project over the next month or two. We've got some very cool new stuff to add, and Hobo is finally going to get the level of documentation it needs for people to really start to get to grips with it. We might even finally get some themes :-) Exciting times!
