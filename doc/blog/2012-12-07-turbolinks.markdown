--- 
wordpress_id: 468
author_login: bryanlarsen
layout: post
comments: []

author: Bryan Larsen
title: Turbolinks
published: true
tags: []

date: 2012-12-07 21:15:35 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=468
author_url: http://bryan.larsen.st
status: publish
---
Hobo 2.0.0.pre7 added support for the [turbolinks gem](https://github.com/rails/turbolinks)

Turbolinks adds a capability similar to the [Hobo push-state option](http://cookbook.hobocentral.net/manual/changes20#pushstate) without requiring any modifications to your views.  So just by adding the turbolinks gem, you can get a substantial speedup for "free".

There are some drawbacks.   For instance, if your stylesheet & javascript assets are different on two different pages, turbolinks ends up loading your page twice.

I recommend checking out [turbolinks](https://github.com/rails/turbolinks).   Most of you will want to add it to your application.
