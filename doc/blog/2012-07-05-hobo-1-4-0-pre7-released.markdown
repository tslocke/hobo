--- 
wordpress_id: 393
author_login: bryanlarsen
layout: post
comments: 
- author: Owen
  date: Thu Jul 05 16:10:53 +0000 2012
  id: 52367
  content: |
    <p>Great work, Bryan!</p>

  date_gmt: Thu Jul 05 16:10:53 +0000 2012
  author_email: ""
  author_url: ""
- author: Owen
  date: Mon Jul 23 15:12:33 +0000 2012
  id: 52395
  content: |
    <p>Nice work on the Changes documentation...</p>

  date_gmt: Mon Jul 23 15:12:33 +0000 2012
  author_email: ""
  author_url: ""
author: Bryan Larsen
title: Hobo 1.4.0.pre7 released
published: true
tags: []

date: 2012-07-05 15:27:39 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=393
author_url: http://bryan.larsen.st
status: publish
---
I'm proud to announce the release of 1.4.0.pre7.   The vast majority of the changes are bug fixes, see the <a href="https://github.com/tablatom/hobo/compare/1.4.0.pre6...1.4.0.pre7">GitHub compare view for a listing.</a>

However, it does include the following new features:

- new tags: `cache`, `swept-cache`
- new tag `search-filter` extracted from table-plus
- `update_response`, `create_response`, etc have changed to allow them to be more easily used from your application
- `parse_sort_param` has gained a couple of new features to deal with dotted fields
- `HoboRapid::PreviousUriFilter` created to make `after-submit` easier to use

<a href="https://github.com/tablatom/hobo/blob/master/hobo/CHANGES-1.4.txt">CHANGES-1.4.txt</a> has been updated to document the changes.
