--- 
wordpress_id: 137
author_login: admin
layout: post
comments: []

author: Tom
title: Nearly forgot
published: true
tags: []

date: 2007-03-15 02:00:51 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/03/15/nearly-forgot/
author_url: http://www.hobocentral.net
status: publish
---
If you are updating an existing app that uses Rapid to Hobo 0.5, you will need to add the following at the top of your views/hobolib/application.dryml

	<taglib src="plugins/hobo/tags/rapid"/>

    <set_theme name="default"/>
