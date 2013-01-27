--- 
wordpress_id: 150
author_login: admin
layout: post
comments: 
- author: Dr Nic
  date: Sun Apr 22 14:02:57 +0000 2007
  id: 2027
  content: |
    <p>This is my first upgrade, are the steps listed somewhere?</p>

  date_gmt: Sun Apr 22 14:02:57 +0000 2007
  author_email: drnicwilliams@gmail.com
  author_url: http://drnicwilliams.com
- author: Dr Nic
  date: Sun Apr 22 14:03:21 +0000 2007
  id: 2028
  content: |
    <p>Also... I just found those darn hooks 2 hours ago and now they are gone! :D</p>

  date_gmt: Sun Apr 22 14:03:21 +0000 2007
  author_email: drnicwilliams@gmail.com
  author_url: http://drnicwilliams.com
- author: yuanjs
  date: Sun Apr 22 14:24:39 +0000 2007
  id: 2030
  content: |
    <p>So Great!
    I'm using 0.5.1 now, but how to upgrade to 0.5.2</p>

  date_gmt: Sun Apr 22 14:24:39 +0000 2007
  author_email: yuanjs@gmail.com
  author_url: ""
- author: Dr Nic
  date: Sun Apr 22 16:42:21 +0000 2007
  id: 2032
  content: |
    <p><code>html<em>repsonse</code> --> <code>html</em>response</code></p>

  date_gmt: Sun Apr 22 16:42:21 +0000 2007
  author_email: drnicwilliams@gmail.com
  author_url: http://drnicwilliams.com
- author: Tom
  date: Sun Apr 22 19:25:17 +0000 2007
  id: 2038
  content: |
    <p>Thanks for spotting that typo Dr Nic. Simplest way to upgrade is to remove the plugins/hobo folder and check out the latest one from svn. You should also run the <code>hobo_rapid</code> generator again if you're using Rapid, but be careful to say "no" to overwriting any files you have changed (e.g. application.dryml).</p>

  date_gmt: Sun Apr 22 19:25:17 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Paul
  date: Mon Apr 23 04:53:30 +0000 2007
  id: 2059
  content: |
    <p>Congratulations and thanks, Tom.</p>

  date_gmt: Mon Apr 23 04:53:30 +0000 2007
  author_email: ""
  author_url: ""
- author: Tom
  date: Mon Apr 23 13:54:10 +0000 2007
  id: 2076
  content: |
    <p>Correction (to my previous comment): application.dryml isn't touched by that generator anyway.</p>

  date_gmt: Mon Apr 23 13:54:10 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Niko
  date: Wed Apr 25 16:52:05 +0000 2007
  id: 2135
  content: |
    <p>Hi Tom.  Is there any way of getting in touch besides the forum and the blog?  I didn't find an emailaddress.  I got banned from the forum for posting "spam" but the forum didn't tell me what exactly was wrong.  Sorry for the misuse of your blog.  I would highly appreciate you removing the ban, please.  Thank you!</p>
    
    <p>You can contact me via email:  mail at niko minus dittmann dot de</p>

  date_gmt: Wed Apr 25 16:52:05 +0000 2007
  author_email: ""
  author_url: ""
author: Tom
title: Hobo 0.5.2 released
excerpt: |
  OK 0.5.2 is now available, both in the svn trunk and as a gem
  
    * [hobo-0.5.2.gem](/gems/hobo-0.5.2.gem)
  
    * [Changelog](/gems/CHANGES.txt)
  

published: true
tags: []

date: 2007-04-22 10:48:06 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/04/22/hobo-052-released/
author_url: http://www.hobocentral.net
status: publish
---
OK 0.5.2 is now available, both in the svn trunk and as a gem

  * [hobo-0.5.2.gem](/gems/hobo-0.5.2.gem)

  * [Changelog](/gems/CHANGES.txt)

<a id="more"></a><a id="more-150"></a>

The important breaking change is that the customisation hooks in your `hobo_model_controller`s no longer work. e.g. if you have

    def create_response
      redirect_to "..."
    end

That will no longer work. The equivalent is now:

	def create
	  hobo_create :html_response => proc { 
		redirect_to "..."
	  }
	end
	
If you have done a lot of stuff with those hooks, you might want to wait until tomorrow before grabbing 0.5.2. I'm hoping to put a decent chunk of time into catching up with the documentation tomorrow.

Enjoy!
