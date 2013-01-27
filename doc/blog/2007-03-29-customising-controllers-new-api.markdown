--- 
wordpress_id: 147
author_login: admin
layout: post
comments: 
- author: anony mouse
  date: Thu Mar 29 12:52:04 +0000 2007
  id: 1136
  content: |
    <p>Cool! Do you mind explaining the last scope feature a bit more?</p>
    
    <p>Also, have you considered doing it the way ActiveScaffold handles this same issue? Basically all actions are 'invisible' which you can override in the controller.</p>

  date_gmt: Thu Mar 29 12:52:04 +0000 2007
  author_email: anon@mous.com
  author_url: ""
- author: petef
  date: Fri Mar 30 08:03:23 +0000 2007
  id: 1155
  content: |
    <p>That looks very neat. Is this working in your sandbox now? Will it be in 0.5.2?</p>

  date_gmt: Fri Mar 30 08:03:23 +0000 2007
  author_email: subs@petef.com
  author_url: http://petef.org
- author: Tom
  date: Fri Mar 30 09:56:12 +0000 2007
  id: 1157
  content: |
    <p>Anon - the scope this is gone now anyway :-) Does the new way make make sense?</p>
    
    <p>Pete - Yes and yes (note to all - it's called sandbox for a reason - I am liable to check in broken code to that branch)</p>

  date_gmt: Fri Mar 30 09:56:12 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Tom
  date: Fri Mar 30 19:40:08 +0000 2007
  id: 1169
  content: |
    <blockquote>
      <p>Also, have you considered doing it the way ActiveScaffold handles this same issue? Basically all actions are &acirc;&euro;&tilde;invisible&acirc;&euro;&trade; which you can override in the controller.</p>
    </blockquote>
    
    <p>Hobo controllers have been like that since the start - you only define the methods you need to customise.</p>

  date_gmt: Fri Mar 30 19:40:08 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: paul
  date: Sat Mar 31 11:15:41 +0000 2007
  id: 1200
  content: |
    <p>how do we contact you tom</p>

  date_gmt: Sat Mar 31 11:15:41 +0000 2007
  author_email: paul.mckellar@gmail.com
  author_url: ""
- author: Alex
  date: Wed Apr 25 12:07:58 +0000 2007
  id: 2129
  content: |
    <p>Thank You</p>

  date_gmt: Wed Apr 25 12:07:58 +0000 2007
  author_email: liste@openbsd.de
  author_url: http://www.google.com
author: Tom
title: Customising controllers - new API
excerpt: |+
  One of the nice things about Hobo is that you never have to write the seven boilerplate actions to get a basic CRUD controller (index, show, new, create, edit, update and destroy). The downside is that if you need to tweak the behaviour of one of those actions, there's no code in your controller to tweak.
  
  
published: true
tags: []

date: 2007-03-29 12:27:27 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/03/29/customising-controllers-new-api/
author_url: http://www.hobocentral.net
status: publish
---
One of the nice things about Hobo is that you never have to write the seven boilerplate actions to get a basic CRUD controller (index, show, new, create, edit, update and destroy). The downside is that if you need to tweak the behaviour of one of those actions, there's no code in your controller to tweak.


<a id="more"></a><a id="more-147"></a>

I've been addressing that issue by adding hook points, e.g. you can define `create_response` and `invalid_create_response` in order to override Hobo's default responses. I've never been totally happy with that approach though - the number of such hooks is bound to grow until there's a rather complex little API in there, which we certainly don't want.

Today I'm having a go at a different approach. The `index` action in Hobo's model controller is now as follows:

    def index
      hobo_index
    end

The `hobo_index` method (which is protected), can also be passed a bunch of parameters, so you could override `index` in your controller like this:

	def index
	  hobo_index :page_size => 10
	end
	
Through parameters like that, you can customise pretty much everything. A common requirement is to include some eager loading in the ActiveRecord find:

	def index
	  hobo_index :items => Post.find(:all, :include => :comments)
	end
	
Another trick - if you pass the items as a proc, the find will happen in a scope that handles pagination for you. (UPDATE: After some digging I've come across the idea, which I thoroughly agree with, that this is really an abuse of `with_scope`)

#### Baaad idea

	def index
	  hobo_index :items => proc { Post.find(:all, :include => :comments) }
	end
	
So here's the new way to achieve the same (and I renamed the `:items` parameter)

#### Good idea

	def index
	  hobo_index :collection => paginated_find(:include => :comments)
	end

I think this approach is going to be easier to learn, while giving you a fine-grained choice between having Hobo do things for you, and having custom control.
