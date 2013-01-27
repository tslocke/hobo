--- 
wordpress_id: 7
author_login: admin
layout: post
comments: 
- author: Mislav
  date: Mon Dec 25 11:59:35 +0000 2006
  id: 25
  content: |
    <p>I am not convinced. From what I understand, these custom tags are like functions - you define them, reuse them and they can take parameters. We had helpers all this time for that! Why reinvent the wheel just to replace Ruby methods with XML-like markup?</p>

  date_gmt: Mon Dec 25 11:59:35 +0000 2006
  author_email: mislav.marohnic@gmail.com
  author_url: ""
- author: Paulo K&Atilde;&para;ch
  date: Mon Dec 25 19:25:00 +0000 2006
  id: 26
  content: |
    <p>Syntactic sugar and code expressiveness. I like it a lot. I suppose <%= Time.stuff %> would be much more readable in  format <time/>.</p>
    
    <p>I find it really clean for something like admin only links. I really dislike having to call a helper. Maybe it's just me.</p>
    
    <p>But yes, same old wheel, but with shinier rims =P</p>

  date_gmt: Mon Dec 25 19:25:00 +0000 2006
  author_email: paulo.koch@gmail.com
  author_url: http://mybi.ath.cx/
- author: Tom
  date: Mon Dec 25 20:18:57 +0000 2006
  id: 28
  content: |
    <p>Here's a bigger example. I've imagined a couple of helpers to try and make it a fair comparison. IMO the advantage of the XML syntax speaks for itself. The <a href="/blog/2006/11/11/dryml-meet-activerecord/" rel="nofollow">implicit context</a> also helps make things a lot clearer:</p>
    
    <h4>RHTML</h4>
    
    <pre><code><% panel do %>
      <h1>Categories</h1>
      <% ul_for(@categories) do |item| %>
        <%= object_link "#{display_name(item)} <i>(#{count(item.adverts)})</i>",
                        item %>
      <% end %>
    <% end %>
    </code></pre>
    
    <h4>DRYML</h4>
    
    <pre><code><panel>
      <h1>Categories</h1>
      <ul_for>
        <object_link>
          <display_name/> <i>(<count attr="adverts"/>)</i>
        </object_link>
      </ul_for>
    </panel>
    </code></pre>

  date_gmt: Mon Dec 25 20:18:57 +0000 2006
  author_email: tom@livelogix.com
  author_url: http://
- author: Mislav
  date: Mon Dec 25 20:56:44 +0000 2006
  id: 29
  content: |
    <p>Why the choice of underscores instead of dashes, then? ("ul-for", "object-link" ...)</p>

  date_gmt: Mon Dec 25 20:56:44 +0000 2006
  author_email: mislav.marohnic@gmail.com
  author_url: ""
- author: Tom
  date: Mon Dec 25 21:02:34 +0000 2006
  id: 30
  content: |
    <p>Yeah I did consider dashes. In the end I just figured it's better to have one convention everywhere, even though in markup I do slightly prefer dashes. I assume you prefer dashes. It will be interesting to see how many others  do.</p>

  date_gmt: Mon Dec 25 21:02:34 +0000 2006
  author_email: tom@livelogix.com
  author_url: http://
- author: Nathaniel Brown
  date: Fri Jan 05 14:02:52 +0000 2007
  id: 68
  content: |
    <p>I am really impressed by this new templating system. Very, very nice. I would love a combination or Liquid and DRYML.</p>

  date_gmt: Fri Jan 05 14:02:52 +0000 2007
  author_email: nshb@inimit.com
  author_url: http://nshb.net
- author: Nathaniel Brown
  date: Fri Jan 05 14:05:44 +0000 2007
  id: 69
  content: |
    <p>That was a "combination <em>of</em> Liquid and DRYML". Being able to restrict ERB usage, and only allow liquid filters, variables, etc.</p>
    
    <p>Would also be amazing to see some sort of include tags, and cascading tag access. So if you have an application.dryml, and include a header.dryml you have access to all the tags defined in application.dryml within the header.dryml.</p>

  date_gmt: Fri Jan 05 14:05:44 +0000 2007
  author_email: nshb@inimit.com
  author_url: http://nshb.net
- author: Tom
  date: Fri Jan 05 14:08:14 +0000 2007
  id: 70
  content: |
    <p>Thanks Nathaniel :-) Can you expand a bit on what Liquid has that DRYML is lacking? I confess I don't have a deep knowledge of Liquid.</p>

  date_gmt: Fri Jan 05 14:08:14 +0000 2007
  author_email: tom@livelogix.com
  author_url: http://
- author: Tom
  date: Fri Jan 05 14:15:04 +0000 2007
  id: 71
  content: |
    <p>Ha ha - we both posted at the same time :-)</p>
    
    <p>Yes - restricting ERB usage is something I've thought about, although
    if Why's sandbox stands up, maybe that's an even nicer approach.</p>
    
    <p>Inclusion of tag libraries is all in there. You can say</p>
    
    <pre><code><taglib src="header" />
    </code></pre>
    
    <p>(The .dryml suffix is not needed). Or</p>
    
    <pre><code><taglib module="MyModule"/>
    </code></pre>
    
    <p>In your example, header.dryml would automatically have access to
    application.dryml tags, as application.dryml is implicitly imported in
    every dryml file.</p>

  date_gmt: Fri Jan 05 14:15:04 +0000 2007
  author_email: tom@livelogix.com
  author_url: http://
- author: Ted Hawkins
  date: Sun Feb 11 13:47:52 +0000 2007
  id: 335
  content: |
    A designer's point of view
    
    <p>This DRML approach promises two excellent benefits. By separating form and function I can control presentation without breaking the code.  Being far simpler to read also means that it is easier for me to maintain and explain to my customers.  </p>
    
    <p>Looking forward to trying out this on our own rails project where the views have caused no end of friction and time wasting between myself and the rails developer.</p>

  date_gmt: Sun Feb 11 13:47:52 +0000 2007
  author_email: ted@edgesoftwareconsultancy.com
  author_url: http://www.edgesoftwareconsultancy.com
- author: RaymonWazerri
  date: Sat Apr 21 00:56:27 +0000 2007
  id: 1988
  content: |
    <p>Hey, 
    I love what you'e doing! 
    Don't ever change and best of luck. </p>
    
    <p>Raymon W.</p>

  date_gmt: Sat Apr 21 00:56:27 +0000 2007
  author_email: alliswelltoday43@yahoo.com
  author_url: http://www.blogger.com
- author: Steven Vu
  date: Fri Jun 08 00:42:11 +0000 2007
  id: 4326
  content: |
    <p>I really do love what you're doing. I was pleasantly surprised to hear a British accent in the screencast.</p>
    
    <p>Is there a transcript available for the screencast? I wouldn't mind going through the screencast nice and slowly to see what you actually did.</p>
    
    <p>Regards,
    Steven</p>

  date_gmt: Fri Jun 08 00:42:11 +0000 2007
  author_email: stevenvu@gmail.com
  author_url: ""
- author: Tom
  date: Fri Jun 08 08:00:49 +0000 2007
  id: 4344
  content: |
    <p>Steven - sorry no transcript. You'll have to make do with frequent use of the pause button!</p>

  date_gmt: Fri Jun 08 08:00:49 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Ruby on Rails Website Development Blog from Atlantic Dominion Solutions
  date: Wed Sep 19 20:03:48 +0000 2007
  id: 10856
  content: |
    <p>[...] &#8220;Exploring Very Rapid Web Development Techniques with Hobo&#8221; by Tom Locke was definitely cool. Hobo is &#8220;an Open Source extension to Ruby on Rails which helps you build full blown web applications incredibly quickly and easily.&#8221; Dr. Nic created the MyConfPlan site using Hobo. Filling the gap between an &#8220;auto admin&#8221; tool and hand coding an entire application, you can get an entire application up and running in a few minutes to a few hours, complete with AJAX, model level security, controller generation and the DRYML tag library. A few of the &#8220;smaller features&#8221; are automatic routing, a migration generator, authorization and sign-up, search, &#8220;kinda&#8221; theme support, and many more. Not yet at version 1.0, the Hobo team is working on documentation in the form of a comprehensive screencast series, API stability, and performance. Looking beyond 1.0, they want to add plugins, themes, and user created tag libraries. [...]</p>

  date_gmt: Wed Sep 19 20:03:48 +0000 2007
  author_email: ""
  author_url: http://www.techcfl.com/blog/?p=199
- author: GSIY &#8230; Ruby-Rails Portal
  date: Thu Sep 20 19:52:28 +0000 2007
  id: 10928
  content: |
    <p>[...] &ldquo;Exploring Very Rapid Web Development Techniques with Hobo&rdquo; by Tom Locke was definitely cool. Hobo is &ldquo;an Open Source extension to Ruby on Rails which helps you build full blown web applications incredibly quickly and easily.&rdquo; Dr. Nic created the MyConfPlan site using Hobo. Filling the gap between an &ldquo;auto admin&rdquo; tool and hand coding an entire application, you can get an entire application up and running in a few minutes to a few hours, complete with AJAX, model level security, controller generation and the DRYML tag library. A few of the &ldquo;smaller features&rdquo; are automatic routing, a migration generator, authorization and sign-up, search, &ldquo;kinda&rdquo; theme support, and many more. Not yet at version 1.0, the Hobo team is working on documentation in the form of a comprehensive screencast series, API stability, and performance. Looking beyond 1.0, they want to add plugins, themes, and user created tag libraries. [...]</p>

  date_gmt: Thu Sep 20 19:52:28 +0000 2007
  author_email: ""
  author_url: http://www.gsiy.com/articles/railsconf-europe-2007-wednesday-wrap-up/
- author: ""
  date: Tue Mar 04 12:36:09 +0000 2008
  id: 27811
  content: |
    <p>Hi Tom,</p>
    
    <p>I get follwing error when I use  tag in a dryml page.</p>
    
    <p>MESSAGE ===</p>
    
    <p>NoMethodError in Hello#hello_world</p>
    
    <p>Showing hello/hello_world.dryml where line #29 raised:</p>
    
    <p>undefined method `tagbody' for #</p>
    
    <p>Extracted source (around line #29):</p>
    
    <p>26: 
    27: 
    28:   
    29:     
    30:   
    31: </p>
    
    <p>===
    What am I doing incorrectly?</p>
    
    <p>when I use a tag name "flower_box" it gives following error</p>
    
    <p>MESSAGE ===
    Hobo::Dryml::DrymlException in Hello#hello_world</p>
    
    <p>Showing hello/hello_world.dryml where line #27 raised:</p>
    
    <p>invalid tag="flower<em>box" attribute on  -- at app/views/hello/hello</em>world.dryml:27</p>
    
    <p>===</p>
    
    <p>Regards,
    HAK</p>

  date_gmt: Tue Mar 04 12:36:09 +0000 2008
  author_email: ""
  author_url: ""
- author: nissans
  date: Sat Mar 22 16:40:15 +0000 2008
  id: 29635
  content: |
    <p>Hi!  Today
    completely changed system and all links which were in bookmarks were lost. Including the link on 
    hobocentral.net ! 4  hours searched for a site on the Internet also has just now found through http://google.com/ 
    X-rum, I can not find your number ICQ write to me please!!!</p>

  date_gmt: Sat Mar 22 16:40:15 +0000 2008
  author_email: dimus02@mail.ru
  author_url: http://nissaninfone.741.com/
- author: amurgrades
  date: Sat Aug 16 13:42:57 +0000 2008
  id: 46016
  content: "<p>Clearly. Thanks! \n\
    :))</p>\n"
  date_gmt: Sat Aug 16 13:42:57 +0000 2008
  author_email: dimus01@mail.ru
  author_url: http://www.amur-grad.110mb.com/
- author: Raymond Gao
  date: Sun Jul 25 04:14:10 +0000 2010
  id: 51978
  content: |
    <p> does not work, if it is used in the application.dryml</p>
    
    <p>It works in other view. But, just not in the application.dryml file.</p>

  date_gmt: Sun Jul 25 04:14:10 +0000 2010
  author_email: raygao06@gmail.com
  author_url: http://appfactory.us
author: Tom
title: A Quick Guide to DRYML
published: true
tags: []

date: 2006-11-10 16:45:49 +00:00
categories: 
- Documentation
author_email: tom@hobocentral.net
wordpress_url: http://hobotek.net/blog/?p=7
author_url: http://www.hobocentral.net
status: publish
---
<a id="more"></a><a id="more-7"></a>

*UPDATE: This stuff is very out of date now, you might prefer to look [here](/blog/2007/08/15/dryml-tour-06-not-quite-ready-yet/)*

Gosh - there's quite a lot in here - where to start? Guess I'll just dive right in.

To follow along, create yourself a new app, install Hobo, and throw in a `demo` controller. (for help with that, see [Hello World](/blog/2006/11/10/hello-world-2/))

Tags can be defined inside your views, making them local to that view. Useful for quick prototyping:

#### app/views/demo/my_page.dryml

    <def tag="time"><%= Time.now %></def>

    <p>The time is <time/></p>

More commonly you'd define tags in app/views/hobolib/application.dryml, making them available to your whole app, but for the purposes of exploring we'll stick with local definitions.

Tags can have attributes. They are available as local variables inside the definition:

    <def tag="time" attrs='format'>
      <%= Time.now.strftime(format) %>
    </def>

    <p>Today is <time format='%A'/></p>

Tags can call other tags, as you'd expect:

    <def tag="time" attrs='format'>
      <%= Time.now.strftime(format) %>
    </def>

    <def tag='today'><time format='%A'/></def>

    <p>Today is <today/></p>

Tags can have a body. Use DRYML's `<tagbody/>` to insert the body where you need it:

    <def tag="flower_box">
      <div class='flower_box'>
        <img src='flower.gif'/><tagbody/>
      </div>
    </def>

    <flower_box>Nice flower eh?</flower_box>

(Aside: yes, you could have done something similar with CSS, but there plenty you *can't* do with CSS, like adding drop shadows in a way that copes with resizing. The drop-shadow technique I prefer needs *8 nested DIVs*. Boy was I ever glad to wrap *that* in a tag)

Watch out for the XHTML compliant image tag (`<img ... />`). DRYML templates must be valid XML, except for two relaxations: they may contain ERB scriplets (in content or attribute values), and they need not have a single root tag.

OK let's define a tag that lays out a whole page -- yes you can use DRYML tags instead of layouts. This has the advantage of letting the choice of page-layout be made in the view, where it belongs (regular Rails layouts are selected in the controller). It also makes it easier for the page to pass bits-and pieces to the layout, such as a title and an `onload` event.

Here's a simple page layout that separates the header and footer with a *horizontal rule* no less! Notice how we define multiple attributes using commas in `attrs` attribute.

    <def tag='page' attrs='title,onload,header,footer'>
      <html>
        <head><title><%= title %></title></head>
        <body onload="<%= onload %>">

          <div class='header'>
            <%= header %>
          </div>
          <hr/>

          <tagbody/>

          <hr/>
          <div class='footer'>
            <%= footer %>
          </div>

        </body> 
      </html>
    </def>


    <page title="My Page"
          onload="alert('NO PLEASE! Not an onload alert!')">
      My wonderful page
    </page>

Note the absence of a header and footer in that case. We'd rather not define those in attributes, as they'll probably contain mark-up. So we'll use an alternate syntax for supplying parameters to tags. Lets quickly get rid of that horrible alert too - if we don't supply the `onload`, the result in the rendered page will simply be a blank `onload` on the `<body>` tag.

    <def tag='page' attrs='title,onload,header,footer'>
      <html>
        <head><title><%= title %></title></head>
        <body onload="<%= onload %>">

          <div class='header'>
            <%= header %>
          </div>
          <hr/>

          <tagbody/>

          <hr/>
          <div class='footer'>
            <%= footer %>
          </div>

        </body> 
      </html>
    </def>


    <page title="My Page">
      <:header>
        Welcome to my site
      </:header>

      My wonderful page

      <:footer>
        My site. &copy; Me. Some Rights Reserved
      </:footer>
    </page>

Those tags that start with a colon, e.g. `<:footer>`, are not defined tags. They are simply parameters to the `<page>` tag. They can appear anywhere *directly* inside the call (i.e. the `<page>` tag in this case). They could even have been given the other way around, the result would be the same. 

Obviously the `<page>` tag isn't much use unless it's defined somewhere where it can be used by multiple pages. The simplest thing is to move it into app/views/hobolib/application.dryml. That library -- or taglib as we call them -- is implicitly imported by every page in your app. Alternatively here's how you could put it into your own taglib instead. Move just the `<def>` into a new file e.g.:

#### app/views/shared/my_tags.dryml

    <def tag='page' attrs='title,onload,header,footer'>
      <html>
        <head><title><%= title %></title></head>
        <body onload="<%= onload %>">

          <div class='header'>
            <%= header %>
          </div>
          <hr/>

          <tagbody/>

          <hr/>
          <div class='footer'>
            <%= footer %>
          </div>

        </body> 
      </html>
    </def>

In the page, instead of the full definition of `<page>`, you now just need to import that taglib using, um, `<taglib>`. Like this:

    <taglib src="shared/my_tags"/>

    <page title="My Page">
      <:header>
        <h1>Welcome to my site</h1>
      </:header>
      <:footer>
        <i>My site. &copy; Me. Some Rights Reserved</i>
      </:footer>

      My wonderful page

    </page>

If you define your tags in app/views/hobolib/application.dryml, you don't need to use `<taglib>` -- this is the global taglib and is always imported. Convention over configuration, man!
