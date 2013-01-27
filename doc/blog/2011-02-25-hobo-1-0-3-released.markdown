--- 
wordpress_id: 353
author_login: bryanlarsen
layout: post
comments: 
- author: Betelgeuse
  date: Fri Feb 25 21:58:46 +0000 2011
  id: 52164
  content: |
    <p>The github log links is producing weird results:</p>
    
    <p>Showing 2,288 commits by 11 authors.</p>

  date_gmt: Fri Feb 25 21:58:46 +0000 2011
  author_email: betelgeuse@gentoo.org
  author_url: ""
author: Bryan Larsen
title: Hobo 1.0.3 released
published: true
tags: []

date: 2011-02-25 20:42:05 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=353
author_url: http://bryan.larsen.st
status: publish
---
This is a security release.  All applications that use the reset
password functionality or are on versions of Rails prior to version
2.3.4 should upgrade.

To patch the reset password vulnerability, two changes have been made.

First of all, the lifecycle key hash mechanism has been changed.
Existing lifecycle keys will become invalid after you upgrade.
Lifecycle keys are typically short lived, so this is unlikely to be a
problem for most applications.

Secondly, lifecycle keys are now cleared on every transition to avoid
replay vulnerabilities.  This new behaviour may be avoided by added
the `:keep_key => true` option to a transition.

More information about the vulnerability can be viewed on the [bug
report](https://hobo.lighthouseapp.com/projects/8324/tickets/666-user-model-secure-links-have-low-security).

Other changes:

The text input tag (`<textarea>`) has a security hole with versions of
Rails prior to 2.3.4.  This release makes using textarea safe on old versions of Rails, although it is highly recommended that you upgrade to
Rails 2.3.11 because of other security vulnerabilities.

The "include" automatic scope has been aliased to "includes" to
increase future compatibility with Rails 3.  Future versions of Hobo
will remove support for "include".

This release increases compatibility with Ruby v1.9.2.

Hobo 1.0.2 introduced a major problem with chained scopes.   This has
been fixed.

All code changes may viewed on the [github
log](https://github.com/tablatom/hobo/compare/v1.0.2...v1.0.3)

