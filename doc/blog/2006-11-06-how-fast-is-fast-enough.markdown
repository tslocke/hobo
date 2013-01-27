--- 
wordpress_id: 3
author_login: admin
layout: post
comments: 
- author: james
  date: Wed Jan 10 19:41:29 +0000 2007
  id: 98
  content: |
    <p>Interesting.  This looks very much like the  Element feature in Nitro.  </p>
    
    <p>http://www.nitroproject.org/</p>

  date_gmt: Wed Jan 10 19:41:29 +0000 2007
  author_email: james.britt@gmail.com
  author_url: ""
- author: HAK
  date: Tue Mar 04 19:47:35 +0000 2008
  id: 27848
  content: |
    <p>Tom>> The move to CRUD as a design strategy makes the idea of a one-size-fits-all controller look pretty doable. But the views&acirc;&euro;&brvbar; I seem to spend 80% of my time hacking view code.</p>
    
    <p>Hi Tom,</p>
    
    <p>The jist of this article is the exact thing that attracts me to hobo, but for me I have been spending 95% time hacking view code.</p>
    
    <p>Till I catch up with DRYML I am still hacking at rhtml pages most of the time.</p>
    
    <p>Just reading dryml files available in taglibs folder is my only current option to go ahead with DRYML right now.</p>
    
    <p>I know many people may have already asked you this already, would it be possible to write usage sample examples for 1 or 2 tags in taglibs per day that you think are not going to be more stable.</p>
    
    <p>Thanks &amp; Best Regards,
    HAK</p>

  date_gmt: Tue Mar 04 19:47:35 +0000 2008
  author_email: ""
  author_url: ""
author: Tom
title: How fast is fast enough?
excerpt: |
  <blockquote>
  
  <p><b><a href="http://www.imdb.com/name/nm0000221/">Bud Fox</a></b>: How much is enough?</p>
  
  <p><b><a href="http://www.imdb.com/name/nm0000140/">Gordon Gekko</a></b>: It's not a question of enough, pal. It's a zero sum game, somebody wins, somebody loses. Money itself isn't lost or made, it's simply transferred from one perception to another.</p>
  
  </blockquote>
  
  I'm a bit of a Gordon Gekko myself when it comes to programming. Greed is good. Remember? Greed works. I'm greedy for speed. Seems to me pretty reasonable that I should be able to build a nice looking, usable, fully-ajaxified database app in what? A couple of hours? That would be fast enough. Then I'd be satisfied [grin].
  

published: true
tags: []

date: 2006-11-06 15:25:22 +00:00
categories: 
- Motivation
author_email: tom@hobocentral.net
wordpress_url: http://hobotek.net/blog/?p=3
author_url: http://www.hobocentral.net
status: publish
---
<blockquote>

<p><b><a href="http://www.imdb.com/name/nm0000221/">Bud Fox</a></b>: How much is enough?</p>

<p><b><a href="http://www.imdb.com/name/nm0000140/">Gordon Gekko</a></b>: It's not a question of enough, pal. It's a zero sum game, somebody wins, somebody loses. Money itself isn't lost or made, it's simply transferred from one perception to another.</p>

</blockquote>

I'm a bit of a Gordon Gekko myself when it comes to programming. Greed is good. Remember? Greed works. I'm greedy for speed. Seems to me pretty reasonable that I should be able to build a nice looking, usable, fully-ajaxified database app in what? A couple of hours? That would be fast enough. Then I'd be satisfied [grin].

<a id="more"></a><a id="more-3"></a>

To be clear, I'm only talking about a basic front end to a database here. You know the drill: create, update, delete, link things together. A blog, a simple content management system, a shop, an events diary, an issue tracker... The list goes on and on. All these kinds of sites are overwhelmingly similar. If I'm having to sweat a lot of code to get a site like this working, surely I must be repeating myself from the last site I built? Real programmers don't repeat themselves. (Got that? I said: real programmers don't repeat themselves)

Of course, any *interesting* web app is going to need a bunch of code to make it tick. Your job aint going anywhere just yet Mr. Programmer (except to Bangalore of course). I just don't want to waste my life hacking on *uninteresting* sites. Or to be more accurate, on the uninteresting parts (there are a lot!) of my otherwise brain-meltingly exciting sites.

In fact there's a bunch of stuff out there that will <i>build a database front-end for you</i>, in an instant. The Python world has Django, and the same for Rails is not far off. The Streamlined guys seem to be doing a great job. With one caveat: it's called an Admin Interface. Not for public consumption.

So if an admin interface can be derived automatically from the data model, surely a genuine end-user interface can't take that long? They are mere mortals, I believe, these administrators.

This is exactly what Hobo is trying to achieve - to take the automation of the out-of-the-box admin interface along with the flexibility of hand-coded views, and mix 'em up in a big 'ol pot to see what comes out.

Like the Scriptaculous guys have it - it's about the user interface, baby!

This pretty much reflects my experience with hacking on Rails apps. The data-layer has been reduced to blissful simplicity. The move to CRUD as a design strategy makes the idea of a one-size-fits-all controller look pretty doable. But the views... I seem to spend 80% of my time hacking view code.

Not for much longer! :-)

Soon I'll be able to say:

    <page title="search">
      <hey_cut_the_drama_and_give_me_a_search_page_already/>
    </page>

<pre><code><page tile="Search">
  <hey_cut_the_drama_and_give_me_a_search_page_already/>
</page></code></pre>

Of course, it's all open-source so if it works, please help yourselves :-)

Feeling greedy?

(p.s. What a load of old waffle eh?! I'll make sure the next post has some actual content. Y'know, like, er, code and stuff)
