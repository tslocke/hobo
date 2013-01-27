--- 
wordpress_id: 166
author_login: admin
layout: post
comments: 
- author: Jim
  date: Wed Aug 15 20:54:35 +0000 2007
  id: 9181
  content: |
    <p>It'll be worth reworking the dryml for syntax that slick. Looking forward to the release!</p>

  date_gmt: Wed Aug 15 20:54:35 +0000 2007
  author_email: jimhern@gmail.com
  author_url: ""
- author: Jon
  date: Wed Aug 15 22:19:15 +0000 2007
  id: 9187
  content: |
    <p>Let's see, if you guys can replace the testing in rails with rspec, and make validations work more like specifications I'd say you could replace rails. Of course, Hobo will have to become more stable where the syntax doesn't change, but you guys are doing good work. Keep it up.</p>

  date_gmt: Wed Aug 15 22:19:15 +0000 2007
  author_email: jonathan.hicks@centerstone.org
  author_url: ""
- author: Tom
  date: Thu Aug 16 08:15:24 +0000 2007
  id: 9206
  content: |
    <p>Jon - Thanks for the encouragement, although we're definitely not trying to replace Rails. Some parts of Rails are gone without a trace, for example I haven't written a single partial since I switched to DRYML. But overall it's still very much Rails development with some extra bells and whistles. Hobo <em>extends</em> Rails.</p>

  date_gmt: Thu Aug 16 08:15:24 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Paul Hedderly
  date: Fri Aug 17 09:33:58 +0000 2007
  id: 9242
  content: |
    <p>/me mops up and drool, and drivels some more</p>
    
    <p>Can't wait :O) Now... if only there was some kind of release before I go on holdiday so I can annoy the wife, erm I mean read/learn/play with it...</p>

  date_gmt: Fri Aug 17 09:33:58 +0000 2007
  author_email: paul+hobo@mjr.org
  author_url: ""
- author: Louis
  date: Fri Aug 17 17:29:54 +0000 2007
  id: 9258
  content: |
    <p>This all seems great and not great at the same time. For a programming novice like myself, the screencasts were great as I could follow them step by step. The above seems really cool if you know what you are doing but I am left with a feeling that I won't be able to make the most of the new version because a lot of it is just to advanced for me.</p>
    
    <p>So the big question is, will the screencasts be updated to use the goodies offered by the new version?</p>

  date_gmt: Fri Aug 17 17:29:54 +0000 2007
  author_email: louis.adekoya@virgin.net
  author_url: http://louis.adekoyavirgin.net
- author: Tom
  date: Fri Aug 17 19:11:11 +0000 2007
  id: 9263
  content: |
    <p>Louis - the new DRYML is not really any more complicated than the old. We definitely want to get new screencasts out but I honestly don't know when we'll get to it.</p>

  date_gmt: Fri Aug 17 19:11:11 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Lars
  date: Sat Aug 18 13:15:02 +0000 2007
  id: 9303
  content: |
    <p>Hi Tom, Lars_G from irc, not seen you in a while, now I see why (busy much? heh), anyhow, before people start with the "Make dryml a separate plugin" again, I wanted for the first time, and now that it's so goddam HOT (I LOVE the new dryml) suggest another PoV about that suggestion.</p>
    
    <p>You know, it does makes sense if you see it like this: DRYML  as a no-compromise-works-with-your-existing-system way to introduce people to hobo, dryml is by far the most explained item in the framework, and the simplest to use from a programmer's perspective, so, if it's separated, you could bundle it with a sort of "Do you like DRYML? why not try full Hobo in your next project?" propaganda I think it would drive even more people to work with hobo</p>
    
    <p>Plus I'd suggest you find an enthusiast with good writting skills and help produce a dryml focused book, that will also gain you support from more strict corp environments, and people who balk at not having a definite reference for it all.</p>
    
    <p>All in all, kudos, and I'm waiting for 0.6 with batted breath</p>

  date_gmt: Sat Aug 18 13:15:02 +0000 2007
  author_email: lars.gold@gmail.com
  author_url: ""
- author: Aleks
  date: Mon Aug 20 20:02:54 +0000 2007
  id: 9383
  content: |
    <p>A book would be nice. Docs would also be nice. Problem is syntax keeps changing. I'd write docs myself if someone would just say "here's the spec, it's not going to change in the next 6 months, and no major changes for at least a year." I'm fine with adding stuff, but this wholesale revision needs to calm down a bit before enough docs can be released to make things usable.</p>

  date_gmt: Mon Aug 20 20:02:54 +0000 2007
  author_email: aleks.clark@gmail.com
  author_url: http://built-it.net
author: Tom
title: DRYML Tour (0.6 not quite ready)
excerpt: |+
  Nope, sorry. No Hobo 0.6 today, but to whet your appetites a little further, here's an example of how clean a full DRYML template can look in the new DRYML. We're pretty happy with the result over here - hope you like it :-)
  
  
published: true
tags: []

date: 2007-08-15 19:35:52 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/08/15/dryml-tour-06-not-quite-ready-yet/
author_url: http://www.hobocentral.net
status: publish
---
Nope, sorry. No Hobo 0.6 today, but to whet your appetites a little further, here's an example of how clean a full DRYML template can look in the new DRYML. We're pretty happy with the result over here - hope you like it :-)


<a id="more"></a><a id="more-166"></a>

In particular, look out for the new "smart HTML tags". These aren't a new DRYML feature, but a new style for the Rapid tag library. They're  just regular DRYML tags that have the same name as HTML tags. Want a link?

    <a href="...">My Link</a>
    
Want Hobo to fill the href in for you? Say, to the author of the article you are rendering:

    <a:author>...</a>
    
How about a form? Hobo will provide the attributes that make the form work (action, method...):

    <form with="&Story.new">...</form>
    
Want to make that an ajax form? Just name the part (or parts) you want updated and Hobo does the rest:

    <form with="&Story.new" update="stories">...</form>
    
So, on to that full page. It's an index page BTW:

    <Page title="Admin Home">

      <intro>
        <h1>Admin Home</h1>
      </intro>

      <maincol>
        <panel>
          <h2>All Accounts by client</h2>

          <section>
            <h3>Create a new client</h3>
            <form with="&Client.new">
              Name: <input:name/>
              <submit label="Create"/>
            </form>
          </section>

          <section>
            <p>Click on a client name to edit.</p>
          </section>

          <section repeat class="client">
            <h3><editor:name/></h3>

            <Table:accounts>
              <tr>
                <td><a/></td>
                <td>Created: <view:created_at.to_date/></td>
                <td>
                  <a:quarters.latest if="&this.site_exists?">View Site</a>
                </td>
              </tr>
            </Table>

            <p>
              <b>&raquo; <a:accounts.new>Create a new account for 
                  <name with="&this_parent"/></a></b>
            </p>

            <delete_button label="Delete #{this.name} permanently"/>
          </section>

          <section><page_nav/></section>

        </panel>
      </maincol>

    </Page>

Let's go over that again with some explanation. First the `<Page>` tag.

    <Page title="Admin Home">

`<Page>` is a _template_. That's a new DRYML feature. Where a normal tag has a single body, a template has a bunch of named parameters, and they can be placed wherever you like in the templates output. It's a fill-in-the-blanks kind of model. Look up at the full listing again and you'll see that `<Page>` has two children -- `<intro>` and `<maincol>`. These are not normal tags that are being called, they are named parameters to the `<Page>` template. Whenever you see a tag with a capitalised name, remember that the children are parameters rather than tag calls.
    
Next, forms. Forms are blissfully neat now in Hobo.

    <form with="&Client.new">
      Name: <input:name/>
      <submit label="Create"/>
    </form>

Because the context for the form is a new AR object, Hobo knows to create a POST to the relevant RESTful create method. Furthermore, if you create the object via a `has_many` collection, the hidden field will be included so that the created object has the required foreign key.

Also notice the new tag for form controls: `<input>`, and the nice syntax to set the context to a given field: `<input:name/>`.

There are three general purpose tags of this kind: `<view>` for read-only views, `<input>` for form input fields and `<editor>` for ajax in-place editors. They all create the right stuff automatically depending on the type of the context, and it's very easy to extend this with your own types. These replace the old `show`, `form_field` and `edit` (we've realised that nouns are better than verbs - they're more declarative).

If the context is something enumerable, look how easy it is to repeat a tag for each item in the collection:

    <section repeat class="client">

A quick click-to-edit title:

    <h3><editor:name/></h3>
    
A table with a row for each account:

    <Table:accounts>
      <tr>
        <td><a/></td>
        <td>Created: <view:created_at.to_date/></td>
        <td>
          <a:quarters.latest if="site_exists?">View Site</a>
        </td>
      </tr>
    </Table>

That's a template too - `<tr>` is a parameter and there are others for giving a `thead` and `tfoot`. Also Note the new in-line `if` syntax on that link.

And finally the page navigation:

    <section><page_nav/></section>

That whole section will only appear if there is more than one page.

Sweet :-)
