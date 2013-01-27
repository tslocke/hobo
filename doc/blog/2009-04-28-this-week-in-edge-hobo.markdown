--- 
wordpress_id: 230
author_login: bryanlarsen
layout: post
comments: 
- author: Joe W
  date: Wed Apr 29 15:06:59 +0000 2009
  id: 51602
  content: |
    <p>This is not a huge deal, but the link to the Rails 2.3 support post is borked both in the text and the href.  Both should be:
    <a href="http://hobocentral.net/blog/2009/04/27/support-for-rails-23/" title="http://hobocentral.net/blog/2009/04/27/support-for-rails-23/" rel="nofollow">http://hobocentral.net/blog/2009/04/27/support-for-rails-23/</a></p>

  date_gmt: Wed Apr 29 15:06:59 +0000 2009
  author_email: josephaweeks+hobo@gmail.com
  author_url: ""
author: Bryan Larsen
title: This Week in Edge Hobo
published: true
tags: []

date: 2009-04-28 01:02:26 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=230
author_url: http://bryan.larsen.st
status: publish
---
Here's what's been happening the last 3 weeks in Hobo.

Automated Tests
---------------

Unit tests have been updated, and integration tests have been added.
More information is available in this [post](http://hobocentral.net/blog/2009/04/24/automated-tests-for-hobo).

Rails 2.3 Support
-----------------

Hobo finally supports Rails 2.3.&nbsp; More information, and instructions on how to upgrade are available in this [post](http://hobocentral.net/blog/2009/04/27/support-for-rails-23)

The Push for Hobo 1.0
---------------------

[As Tom
mentioned](http://hobocentral.net/blog/2009/04/22/hobo-10-nears/) we
hope to get Hobo 1.0rc1 out soon.&nbsp; The code is frozen, we're only
fixing bugs.&nbsp; Please ensure you've entered any bugs you find in our
[Lighthouse](https://hobo.lighthouseapp.com) so we don't miss any.
And if you have any changes of your own, please send patches or pull
requests quickly.

Hobo --no-rails
---------------

The `--no-rails` option was added to the hobo command to make it
available when hobo is run as a plugin.&nbsp; [See this recipe for more
details on how to upgrade to a plugin](http://cookbook.hobocentral.net/recipes/27)

Bugs Fixed
----------

 - [update permission not checked for table controls](http://groups.google.com/group/hobousers/browse_thread/thread/44ddb93e8f6de399)
 - [filter-menu selected not working](https://hobo.lighthouseapp.com/projects/8324/tickets/369)
 - [in-place editor for integers not working](https://hobo.lighthouseapp.com/projects/8324/tickets/400)
 - [rapid crashes on bignum](https://hobo.lighthouseapp.com/projects/8324/tickets/368)
 - [HoboFields rich types fix - was converting blanks to 0 for numeric types](http://github.com/bryanlarsen/hobo/commit/8664b71641e728cb36eab4a6b8e7c31d999a4605)
 - [error editing resource: undefined method `dasherize' for :integer:Symbol](http://groups.google.com/group/hobousers/browse_thread/thread/384955b28615ee50)
 - [in place editor not working after ajax update](https://hobo.lighthouseapp.com/projects/8324/tickets/305)
 - [minimize impact of bug in rails' select_datetime](https://hobo.lighthouseapp.com/projects/8324/tickets/408)
