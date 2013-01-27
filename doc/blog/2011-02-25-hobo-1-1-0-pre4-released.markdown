--- 
wordpress_id: 355
author_login: bryanlarsen
layout: post
comments: []

author: Bryan Larsen
title: Hobo 1.1.0.pre4 released
published: true
tags: []

date: 2011-02-25 20:42:21 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=355
author_url: http://bryan.larsen.st
status: publish
---
Hobo 1.1.0.pre4 has been released into the wild.   Most of the differences between 1.1.0.pre3 and 1.1.0.pre4 mirror the changes betwen 1.0.2 and 1.0.3, including the security fix for lifecycles, so it's highly recommended that you upgrade.   Here is the changelog for the entire 1.1 release:

The biggest change to Hobo 1.1 is that DRYML has been split into it's
own gem and may now be used independently of Hobo or Rails:

    Dryml.render("<html><%= this %>></html>", {:this => something})

Automatic scopes has gained any\_of\_:

    Person.any_of_friends(Jack, Jill)

The default password validation has been changed to 6 characters, one
of which must not be lowercase.  Luckily, we also made the password
validation easier to change.   See
[Bug #638](https://hobo.lighthouseapp.com/projects/8324/tickets/638) for
more information.

The `input-many`, `name-one` and `sortable-collection` tags have been
updated.  See the documentation for more details.

New tags have been added:  `sortable-input-many`, `login-form`.

Some css class names have been changed.   Hobo 1.0 creates class names
with the '[]' characters, which is technically illegal, although
supported by all browsers.   However, this does cause problems with
some third party libraries, such as JQuery.

All code changes may viewed on the [github
log](https://github.com/tablatom/hobo/compare/1-0-stable...master)
