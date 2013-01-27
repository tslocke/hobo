--- 
wordpress_id: 20
author_login: admin
layout: post
comments: 
- author: Nick
  date: Sun Feb 25 21:47:06 +0000 2007
  id: 568
  content: |
    <p>New?</p>

  date_gmt: Sun Feb 25 21:47:06 +0000 2007
  author_email: nivk@df.dfp
  author_url: http://com.com
- author: petef
  date: Thu Mar 08 21:22:50 +0000 2007
  id: 729
  content: |
    <p>Thanks for this, it's a good start. However <index<em>page>, <show</em>page>, <new<em>page> and <edit</em>page> are at least fairly self evident. What would be really useful would be a little guidance on the use of <show<em>collection</em>page> and <new<em>in</em>collection_page>?</p>

  date_gmt: Thu Mar 08 21:22:50 +0000 2007
  author_email: subs@petef.com
  author_url: http://petef.org
- author: petef
  date: Thu Mar 08 21:25:29 +0000 2007
  id: 730
  content: |
    <p>Whoops. Forgot to escape my <code>_</code>'s in that post. Sorry.</p>

  date_gmt: Thu Mar 08 21:25:29 +0000 2007
  author_email: subs@petef.com
  author_url: http://petef.org
- author: Tom
  date: Fri Mar 09 15:33:43 +0000 2007
  id: 746
  content: |
    <p>petef - breaking news :-) There's a mini Hobo manual on the way that will cover this and much more</p>

  date_gmt: Fri Mar 09 15:33:43 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
author: Tom
title: Customising a Page
excerpt: |
  I owe you a screencast on customising the whole UI of the POD demo, but strictly speaking I'm on holiday at the moment :-) I'm just stealing a few moments on the laptop here and there to check the site stats and respond to any comments.
  
  So to keep you going, I thought I'd better rattle off a few quick tips on customising a page, seeing as it's a total mystery at the moment. We'll customise the view of a category page in the POD demo.
  
  

published: true
tags: []

date: 2006-12-28 10:43:00 +00:00
categories: 
- Documentation
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2006/12/28/cusomtising-a-page/
author_url: http://www.hobocentral.net
status: publish
---
I owe you a screencast on customising the whole UI of the POD demo, but strictly speaking I'm on holiday at the moment :-) I'm just stealing a few moments on the laptop here and there to check the site stats and respond to any comments.

So to keep you going, I thought I'd better rattle off a few quick tips on customising a page, seeing as it's a total mystery at the moment. We'll customise the view of a category page in the POD demo.


<a id="more"></a><a id="more-20"></a>

If you wanted to customise the front page, that would be a relatively familiar process - look in app/views/front and you'll find index.dryml, as well as a few others. But app/views/categories is empty -- so where is the current page coming from?

Hobo's model controller (i.e. any controller that declares `hobo_model_controller`) provides the following pages (actions) just like a regular Rails scaffold:

  * index - A list of all the records

  * show - A view of a single record

  * edit - an editable view of a single record (the default UI doesn't use this,
	as the show page supports in-place editing)
	
  * new - A blank form for a new record

If Hobo doesn't find a template for a given page, it will use a tag instead - these are defined by the theme:

  * `<index_page>`
  * `<show_page>`
  * `<edit_page>`
  * `<new_page>`

So there are two ways to override the look of a page. If you override one of these tags, say by defining `<show_page>` in app/views/hobolib/application.dryml, *all* the show pages will change. If you create a file, say app/views/categories/show.dryml, then just that page will change.

Try creating this file:

#### app/views/categories/show.dryml

    My category page

If you browse to a category page, you should see just that text - all trace of the theme is gone. To get the theme back, we need to use the `<page>` tag which gives us a generic page (this tag is used in turn by `<index_page>`, `<show_page>` etc.). E.g.:
	
#### app/views/categories/show.dryml

    <page>
	  <h1>My category page</h1>
	</page>

Now lets start to build out the page

#### app/views/categories/show.dryml

    <page>
	  <h1><show attr="name"/></h1>

	  <panel>
	    <h1>Adverts</h1>
	    <repeat attr="adverts">
	      <section>
	        <h2><show attr="title"/></h2>
	      </section>
	    </repeat>
	  </panel>
	</page>
	
Note the use of `<panel>` and `<section>` tags. These are theme tags and will be rendered differently by each theme.
	
One problem with this page is that we've lost the ability to edit in-place. If we change those `<show>` tags to `<edit>` tags, Hobo will provide an in-place editor to any user with the right permissions. Lets include the advert body while we're at it:
	
#### app/views/categories/show.dryml

	<page>
	  <h1><edit attr="name"/></h1>

	  <panel>
	    <h1>Adverts</h1>
	    <repeat attr="adverts">
	      <section>
	        <h2><edit attr="title"/></h2>
		    <p><edit attr="body"/></p>
	      </section>
	    </repeat>
	  </panel>
	</page>

And there you have it. An obvious feature we're missing is the ability to paginate. What's needed I think is something like `<paginated_repeat>` which would only be allowed once on a page. Hobo doesn't have this yet. There's no shortage of things on the to-do list!
