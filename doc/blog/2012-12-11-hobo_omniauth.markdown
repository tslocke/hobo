--- 
wordpress_id: 471
author_login: bryanlarsen
layout: post
comments: []

author: Bryan Larsen
title: hobo_omniauth
published: true
tags: []

date: 2012-12-11 18:34:00 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=471
author_url: http://bryan.larsen.st
status: publish
---
We're proud to announce a new plugin for hobo: [hobo_omniauth](http://cookbook.hobocentral.net/api_plugins/hobo_omniauth)

This plugin is a wrapper around [omniauth](https://github.com/intridea/omniauth) which allows you to add link your user accounts with google, twitter, facebook, github, et al so that your users can log in without a password.

This is an opinionated plugin.   Unlike the base omniauth plugin, it assumes that you have your system set up in a certain way.  It comes with two different "strategies" that you can choose from.

The first strategy UserAuth assumes that you are linking to a single provider, and you are only using that provider for authentication, that you aren't supporting password logins.

The second strategy MultiAuth supports multiple providers along with password login.

If neither of these strategies work for you, you can use the two strategies above to create your own.  If you create a new one, send it to us, we'd love to add it to the plugin!

The documentation for  [hobo_omniauth is in the cookbook,](http://cookbook.hobocentral.net/api_plugins/hobo_omniauth)  There are also two example bare applications on github: [UserAuth example](https://github.com/Hobo/hobo_omniauth_userauth_example) and [MultiAuth example](https://github.com/Hobo/hobo_omniauth_multiauth_example)
