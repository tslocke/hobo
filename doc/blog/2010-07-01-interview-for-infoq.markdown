--- 
wordpress_id: 300
author_login: admin
layout: post
comments: 
- author: Flow &raquo; Blog Archive &raquo; Daily Digest for July 2nd - The zeitgeist daily
  date: Fri Jul 02 10:09:00 +0000 2010
  id: 51951
  content: |
    <p>[...] the new superframework on top of Ruby on Rails http://hobocentral.net/blog/2010/07/01/interview-for-infoq/ [...]</p>

  date_gmt: Fri Jul 02 10:09:00 +0000 2010
  author_email: ""
  author_url: http://clair.ro/flow/2010/07/02/daily-digest-for-july-2nd-2/
author: Tom
title: Interview for InfoQ
excerpt: |
  A while back I was approached by Paul Blair who was interested in doing an email interview about Hobo for InfoQ. That interview went out a few weeks back and is available [here](http://www.infoq.com/news/2010/05/hobo-10).
  
  The actual interview was quite a bit longer than the version that got published, and the full version is probably of interest to anyone interested in Hobo, so I'm posting it here in full.
  

published: true
tags: []

date: 2010-07-01 13:08:47 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/?p=300
author_url: http://www.hobocentral.net
status: publish
---
A while back I was approached by Paul Blair who was interested in doing an email interview about Hobo for InfoQ. That interview went out a few weeks back and is available [here](http://www.infoq.com/news/2010/05/hobo-10).

The actual interview was quite a bit longer than the version that got published, and the full version is probably of interest to anyone interested in Hobo, so I'm posting it here in full.

<a id="more"></a><a id="more-300"></a>

*How would you describe Hobo in a few words?*

Hobo is a collection of extensions to Ruby on Rails designed to make coding Rails apps even quicker and easier than it is already. We're taking ideas that Rails pioneered, like *convention over configuration*, and pushing them much, much further.

*What led you to develop Hobo?*

It started pretty much as soon as I started learning Rails, back in 2006. I quickly found that I was extremely productive in Rails, except for the view layer. I had been experimenting with tag languages since as early as 1995 (browsing with Netscape version 1!) and had some ideas stored up. I was learning Ruby at the same time, and as I started experimenting, I quickly realised what a great language it is for this kind of thing. I was hooked. The Hobo project took off from the momentum that Ruby gave me.

*Who is using Hobo? How big is the community?*

We've had over 2,000 downloads of Hobo 1.0 and we're approaching 500 members of the mailing list. It's growing pretty quickly at the moment. As for who they are, we've had all sorts, from hobbyists to NASA. It's especially popular with people that would love to create a Rails app but are a little intimidated by how much they have to learn in order to get to their finish line. With Hobo they can see that their goal is within reach.

I'm very happy to say that the Hobo community is very friendly. Newcomers are always welcome, and no one will tell you to RTFM!

*What kinds of application is Hobo used for? Why would someone choose Hobo over Rails? Is Hobo useful for developing enterprise/business apps, or is it more for individuals making personal sites? Would professional web developers use Hobo?*

Hobo can really be used anywhere that Rails can. The sweet-spot is for smaller projects and prototypes - that's where the speed-up is most noticeable. With the professional folk, some love the power it gives them, and some seemingly prefer to do things at a slightly lower 'hands-on' level. Actually we've worked very hard to make sure you can always go 'under the hood' and can change anything that you could with regular Rails, but there is a learning-curve to be surmounted before you get to that point.

*How does Hobo differ from other similar tools which are available, such as ActiveScaffold or Streamlined (or even make_resourceful and other REST controller frameworks)? Is Hobo just another scaffolding framework?*

In my opinion Hobo is entirely different from these tools. I've written about this several times over the history of the project because obviously there's a perceived similarity. Scaffolding frameworks are very useful in situations where rough-and-ready is good enough. For example, as a stop-gap while you're working, or in an admin site that your public users won't see. Hobo is for your whole app. You can start with the out-of-the-box UI, which is already closer to a usable site than you might expect, and from there you can gradually tweak anything and everything until you have exactly the user-experience you're after.

*Your site features two books devoted to Hobo. Why does Hobo require two books' worth of documentation? Is the learning curve steep?*

Hobo is a big project. There's a lot to learn but you only need to learn a little to be up and running and productive. The more particular you choose to be about fine-tuning your app, the further along that learning curve you'll need to go. In practice it tends to be the people that build several Hobo apps that decide to learn the details. 

*How many plugins are included in Hobo? Is there more to Hobo than the three plugins HoboFields, HoboSupport, and DRYML? What are the external dependencies? Does Hobo require any native extensions? Can I run it under JRuby?*

Actually DRYML *still* hasn't been separated, although Bryan Larsen has pretty much done the work now as part of his efforts to support Rails 3. So we have HoboSupport, HoboFields, and Hobo itself which includes DRYML. We rely on will-paginate for pagination and that's about it. There are no native extensions, and it runs fine under JRuby.

*Do we really need another markup language? What does DRYML do for the user that, say, partials in Rails wouldn't?*

DRYML is the part of Hobo that I'm most proud of -- I believe it brings some significant and important innovations to the table. It's main strength is allowing view-code fragments to be packaged up for re-use, without sacrificing flexibility down the line. I think any discerning hacker who's written a lot of Rails view code knows that we need something better. Projects like Seaside (for Smalltalk) and Erector make low-level languages like ERB and HAML look very primitive.

The important idea in DRYML is nested parameterisation. Imagine method A calls method B which calls method C, and in your code, which is using A, you realise you need to tweak a parameter to C. If that parameter is not exposed by both B and A in turn, you're sunk. With DRYML you can "drill down" and add that extra parameter to C. In regular code this would be total chaos, but in view-code where all you're ever doing is generating fragments of HTML, without side-effects, it works wonderfully. You can remove that breadcrumb link, inside that latest-news widget, inside your blog's index page, without ever having to repeat any of the intermediate HTML code.

*If a developer uses HoboFields to specify fields in the model classes, how does HoboFields maintain compatibility with ActiveRecord, which is looking to create those fields by querying the database? Wouldn't this break ActiveRecord? What are the advantages and disadvantages of moving away from Rails' philosophy of generating the model dynamically from the database columns?*

It doesn't break any aspect of ActiveRecord. ActiveRecord still creates the fields by interrogating the database. The fields block in a HoboFields model is used by our *migration generator*. Originally it wasn't used at runtime at all. The migration generator essentially does a 'diff' of your database and your field declarations, and writes both the up and down migrations for you. So for example, if you want to rename a field, you literally go to the model and rename it, and then run the migration generator. Job done. ActiveRecord carries on as normal, taking the field name from the (now updated) database.

Once that was working we realised that the fields block was a great place to add a few more conveniences, like some nice shorthands for validations (e.g. `name :string, :required`).

I've honestly not encountered any down-sides at all. There's really no need for anyone to write migrations by hand any more.

*If I add a new field to a model, HoboFields creates a new migration to add a column to the database. How does it keep track of what additional migrations it needs to create? Isn't this process fragile?*

There's nothing to keep track of. You run the generator, it creates a migration that will bring your database into line with your code. Once you've run that migration you can sanity-check by running the migration generator again and it will say "Database and models match - nothing to change". It's rock-solid. The one issue that is a challenge for any tool that attempts this is that you can't tell the difference between an add/remove and a rename. For example, the migration generator sees a column in the database called 'name' that's missing from the model, and a field in the model called 'title' for which there is no column. Did you remove the 'name' field (and hence want all the name data to be dropped) and add a new one called 'title', or did you rename 'name' to 'title'? It's impossible to tell. One solution is to require the developer to include some kind of hint in the source code, which could later be removed, but that's clunky. In the end I realised that there was a simple solution - just ask! So the migration generator is interactive: is this an add/remove or a rename. It only asks when there is ambiguity.

*What are HoboFields Rich Types? What kinds of types are there?*

A rich type allows you to capture higher level information about your data, such as "this is an email address", or "this is Markdown formatted text". You know that information when you are coding your model, so it's a shame not to capture it. Doing so allows you to do some nice tricks, like rendering Markdown text correctly as HTML without having to do a thing in your view code, or getting validations for email addresses. These things happen automatically as soon as you tell HoboFields the type of your fields. You can very easily add your own rich types.

*Does Hobo add tools for building AJAX applications over and above what's provided with Rails?*

Yes. In Rails, if you have a fragment of a page that needs to be updated via AJAX, you have to factor that out into a partial - a separate template file. Sometimes they are ridiculously small and you can end up with unmanageably large numbers of them. DRYML has the concept of a *part*, which is a section of your template that is marked as something you want to update. There's no need to go to a separate file. Even better, in many cases Hobo knows how to update the part for you. You can just annotate, say, an ajax form or button, with `update="foo"` where 'foo' is the name of your part, and it just works -- the page is updated according to the new state of the database after the ajax operation is complete. To be honest that's one of the more magical features in Hobo -- perhaps too magical for some people's tastes. But it's totally optional.

*What makes the 1.0 release a milestone release?*

It means we stopped adding features and focused on documentation and stability until we felt ready to say, OK, all sorts of people can feel comfortable using this now. We've also made a commitment to not make major breaking changes without a grace period of warning messages, very much as with Rails.

*How do you see Hobo evolving after 1.0?*

To be honest I feel that this is now up to the community. There are a million ideas to explore, but which ones get done depends on what people want, and what people are going to contribute. We've just had a fantastic contribution to the internationalisation support, and to be frank that wasn't on my radar at all. It's great to see the project gain it's own momentum like that.

*The Hobo site says that Barquin International sponsors Hobo. Was Barquin involved with Hobo from its inception? What does Barquin's support enable that you wouldn't have if you were simply an open-source project without funding? *

The project had already been going for about two years when Owen Dall of Barquin spotted us and decided to get on board. To be clear, we're not talking about VC-like funding here, with a long line of zeros. Barquin supported myself, and later Bryan Larsen to work on the code and still be able to pay the rent. Progress accelerated a great deal compared to fitting the project in on the side. I'm married with kids so the days when I could stay up all night working on a hobby are long gone. We also learned a lot by watching a company picking up Hobo and training their team. We were able to make the learning curve a lot more pleasant as a direct result of that experience. More recently, the project to create the Hobo books came entirely from Barquin. Some of my words were used, from documentation I'd written already, and for that I got authorship credit, but in truth the books happened entirely because of Owen and Jeff over at Barquin. The community has benefited enormously of course, so all in all we're extremely grateful.
