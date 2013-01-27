--- 
wordpress_id: 254
author_login: bryanlarsen
layout: post
comments: 
- author: Owen
  date: Wed Oct 14 20:58:54 +0000 2009
  id: 51733
  content: |
    <p>Thanks Bryan!</p>

  date_gmt: Wed Oct 14 20:58:54 +0000 2009
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
- author: Betelgeuse
  date: Wed Oct 14 21:18:41 +0000 2009
  id: 51734
  content: |
    <p>The github log link points to version 0.8.5.</p>

  date_gmt: Wed Oct 14 21:18:41 +0000 2009
  author_email: betelgeuse@gentoo.org
  author_url: ""
- author: Bryan Larsen
  date: Wed Oct 14 21:43:04 +0000 2009
  id: 51735
  content: |
    <p>Thanks Betelgeuse.   I forgot to push the tag.</p>

  date_gmt: Wed Oct 14 21:43:04 +0000 2009
  author_email: bryan@larsen.st
  author_url: http://bryan.larsen.st
- author: Bryan Larsen
  date: Thu Oct 15 05:35:35 +0000 2009
  id: 51736
  content: |
    <p>And it looks like we've got another brown paper bag release.  Iain Beeston caught a bug in the last minute fix to Bug 473.  I pushed a fixed gem to gemcutter, but I didn't bump the version number.  I expect to do so in the morning so that everybody actually gets the new version.</p>

  date_gmt: Thu Oct 15 05:35:35 +0000 2009
  author_email: bryan@larsen.st
  author_url: http://bryan.larsen.st
author: Bryan Larsen
title: Hobo 0.8.9 Released
published: true
tags: []

date: 2009-10-14 20:54:58 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=254
author_url: http://bryan.larsen.st
status: publish
---
Our apologies for not releasing Hobo 0.8.9 earlier.  We really should have pushed out a new version as soon as Bug 461 was fixed.

We've got some exciting stuff coming, including internationalization support from soey and Spiralis, and auto indexing from Matt Jones.  This might slightly destabilize edge for a while -- consider yourself warned.

The gems are on [gemcutter.org](http://gemcutter.org) now.   `gem install gemcutter` to access them.  Hopefully they'll appear on Rubyforge soon.

### Enhancements

 <ul>
<li>[precompile_taglibs](http://groups.google.com/group/hobousers/browse_thread/thread/29694e75f60c0870/6b05f75f2f7e91f5)
allows you to precompile taglibs during application startup rather
than on demand.</li>

</li>`--invite-only` option added to the `hobo` generator.
</ul>

### Major bug fixes:

- [Bug
461](https://hobo.lighthouseapp.com/projects/8324-hobo/tickets/461-hobo-is-not-compatible-with-firefox-35):
Firefox 3.5 problems were caused by lowpro.&nbsp; For existing projects,
you will have to update your copy of [public/javascripts/lowpro.js](http://github.com/tablatom/hobo/raw/master/hobo/rails_generators/hobo_rapid/templates/lowpro.js)

- [Bug
477](http://groups.google.com/group/hobousers/browse_thread/thread/5a15288f9703a8a4/58a8dee62b237d29)
caused problems when the user submitted a form from the index page.

- "collection" was renamed to "collection-heading" in the Rapid
generated show-page.

- [Bug
473](https://hobo.lighthouseapp.com/projects/8324/tickets/473-use-timezonenow-instead-of-timenow#ticket-473-5):
Hobo now uses any time zone's configured for the application rather
than using the server's time zone.

### Minor bug fixes and enhancements:

See the [github log](http://github.com/tablatom/hobo/commits/v0.8.9)
