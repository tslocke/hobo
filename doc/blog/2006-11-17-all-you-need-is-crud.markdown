--- 
wordpress_id: 12
author_login: admin
layout: post
comments: []

author: Tom
title: All You Need is CRUD?
excerpt: |
  DHH, as you probably heard, has learnt to stop worrying and love the CRUD. I'm very much in agreement. The idea of replacing the actions `add_member` and `remove_member` (or would that be `join_group` and `leave_group`?) with `Membership#create` and `Membership#destroy` was the final light switch that got me to a place I'd been striving for.
  
  The generic controller. A standard implementation of the CRUD actions that can be used out-of-the-box in a large majority of cases.
  

published: true
tags: []

date: 2006-11-17 22:09:23 +00:00
categories: 
- Motivation
author_email: tom@hobocentral.net
wordpress_url: http://hobotek.net/blog/2006/11/17/all-you-need-is-crud/
author_url: http://www.hobocentral.net
status: publish
---
DHH, as you probably heard, has learnt to stop worrying and love the CRUD. I'm very much in agreement. The idea of replacing the actions `add_member` and `remove_member` (or would that be `join_group` and `leave_group`?) with `Membership#create` and `Membership#destroy` was the final light switch that got me to a place I'd been striving for.

The generic controller. A standard implementation of the CRUD actions that can be used out-of-the-box in a large majority of cases.

<a id="more"></a><a id="more-12"></a>

The idea is that the concrete controllers that make up an application will need no custom code at all -- just a few declarations:  I need an auto-completer for this attribute, an ajax-setter for that one... I don't see why this can't be done.

Of course if an application needs to do something unusual, then sure you might want a custom action or two. But a huge number of apps are really nothing more than a web-interface to a database, and nearly all apps have at least some parts that fit this description.

There are a couple of challenges though. Firstly, what should these standard actions render? It's all very well to have a single URL that you hit to, say, create a new event in your calendar, but depending on where in your app you're coming from, you're likely to want a different page (or ajax update) to follow.

Simple answer - parameterise it. Have the browser request "create me a new event, then refresh parts a, b, and c of my page". That functionality is now part of Hobo and seems to work great. As well as getting us closer to a fully generic controller, this idea has also yielded a very simple approach to ajax.

Another problem I've hit is that sometimes an application feature requires a whole graph of related models be created in one go. The solution to that one has been to extend the way ActiveRecord handles the hash you pass to `MyModel.new`. With Hobo's ActiveRecord extensions, that single call to `new` can set up arbitrary relationships with other models, either existing or new.

This post is light on technical details (all will be revealed), but it sets the stage for what I want to waffle about next -- Hobo's support for ajax. I think Hobo's approach will make ajax programming easier than with anything else out there.

Just had a good week delivering a Rails training course for Skills Matter in London, but of course that meant little progress with Hobo. Next week it's full steam ahead!
