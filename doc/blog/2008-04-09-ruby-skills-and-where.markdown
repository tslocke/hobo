--- 
wordpress_id: 198
author_login: admin
layout: post
comments: 
- author: Owen
  date: Wed Apr 09 19:43:14 +0000 2008
  id: 31074
  content: |
    <p>Great stuff!</p>

  date_gmt: Wed Apr 09 19:43:14 +0000 2008
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
- author: coderrr
  date: Wed Apr 09 23:46:32 +0000 2008
  id: 31094
  content: |
    <p>nice idioms!</p>

  date_gmt: Wed Apr 09 23:46:32 +0000 2008
  author_email: oksteev@gmail.com
  author_url: http://coderrr.wordpress.com
- author: Brandon Zylstra
  date: Thu Jun 26 18:50:48 +0000 2008
  id: 39500
  content: |
    <p>Will this create a conflict when Ruby 1.9 adds the * operator? 
    http://pragdave.blogs.pragprog.com/pragdave/2008/06/silly-ruby-19-t.html</p>

  date_gmt: Thu Jun 26 18:50:48 +0000 2008
  author_email: brandon.zylstra@gmail.com
  author_url: http://brandonzylstra.com
- author: Tom
  date: Thu Jun 26 19:17:31 +0000 2008
  id: 39503
  content: |
    <p>Hi Brandon - no I think it should be OK. Actually the 'splat' operator is already there:</p>
    
    <pre><code>>> x = [1,2,3]
    => [1, 2, 3]
    >> [10, *x]
    => [10, 1, 2, 3]
    </code></pre>
    
    <p>It's syntactically different from the multiply operator (note there's no left-hand-side). Ruby 1.9 just adds a load of new tricks you can do with it.</p>

  date_gmt: Thu Jun 26 19:17:31 +0000 2008
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
author: Tom
title: "[Ruby Skills] * and where"
excerpt: |+
  This is the first post in a new category I've added to the blog: "Ruby Skills". It's a place for me to share Ruby tricks and tips I've picked up along the way. Sometimes, as with this post, I'll post about the Ruby extensions in HoboSupport. Now that HoboSupport is available as a gem, you can easily use these tricks in any Ruby project.
  
  
published: true
tags: []

date: 2008-04-09 14:00:16 +00:00
categories: 
- Ruby Skills
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2008/04/09/ruby-skills-and-where/
author_url: http://www.hobocentral.net
status: publish
---
This is the first post in a new category I've added to the blog: "Ruby Skills". It's a place for me to share Ruby tricks and tips I've picked up along the way. Sometimes, as with this post, I'll post about the Ruby extensions in HoboSupport. Now that HoboSupport is available as a gem, you can easily use these tricks in any Ruby project.


<a id="more"></a><a id="more-198"></a>

First up, two new Enumerable methods that HoboSupport adds: `*` and `where`. Attentive readers might be thinking -- hang on, Array already defined `*`. Don't worry, it still works.

`*` is some syntactic sugar for `map`. The idea is that we use 'dot' to call a method on *one* object, and we use 'dot star' to call a method on a *whole collection* of objects, returning all the results in a new array.

Say `users` is an array of user objects, and we want all the names:

	users.*.name
	
Nice eh? You can pass arguments too:

	users.*.to_json(:only => [:first_name, :surname])
	
Note that you can't do

	users.*.name.upcase
	
That would try to upcase the array. You'd have to do:

	users.*.name.*.upcase # Not very efficient though
 
Of course, as a good functional programmer, I wouldn't dream of giving map some love while neglecting filter (better known in Ruby-land as `find_all` or `select`). So you can also do:

	users.where.active? # same as users.find_all {|u| u.active? }
	
There's also `where_not`
	
Given that the result is just an array, we can chain them. Want the names of all the inactive users?

	users.where_not.active?.*.name
	
Very handy in the console.
