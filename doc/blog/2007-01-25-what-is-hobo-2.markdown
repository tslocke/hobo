--- 
wordpress_id: 30
author_login: admin
layout: post
comments: 
- author: Michiel
  date: Thu Jan 25 19:38:49 +0000 2007
  id: 195
  content: |
    <p>Hey Tom,</p>
    
    <p>thanks for the write-up. I've been going through the hobo sources (very nice stuff!) but a little description goes a long way for a project of this scope.</p>

  date_gmt: Thu Jan 25 19:38:49 +0000 2007
  author_email: ""
  author_url: ""
- author: Ed
  date: Fri Jan 26 15:39:12 +0000 2007
  id: 199
  content: |
    <p>Ahhhhh these little nuggets really help. Thanks for sharing Tom.</p>

  date_gmt: Fri Jan 26 15:39:12 +0000 2007
  author_email: ""
  author_url: ""
- author: petef
  date: Thu Feb 08 14:23:37 +0000 2007
  id: 285
  content: |
    <p>In this case I didn&acirc;&euro;&trade;t want to build password reset into Hobo, but I did build the RPC mechanism).</p>
    
    <p>I'm curious, why not include password reset? Pretty much a universal requirement, no?</p>

  date_gmt: Thu Feb 08 14:23:37 +0000 2007
  author_email: subs@petef.com
  author_url: http://petef.org
- author: Carl
  date: Sun Feb 11 01:44:19 +0000 2007
  id: 330
  content: |
    <p>Have you considered a database.yml like that of [Raymond Lim] (http://blog.wetonrails.com/2006/10/13/how-to-install-mephisto-noh-varr-release) ?  Eventually it may help automate the configuration.  Here is a possible example:</p>
    
    <pre><code>login: &#38;login
      adapter: mysql
      host: localhost
      username: (insert username here)
      password: (insert password here)
    
    development:
      database: pod_development
      </pre>

  date_gmt: Sun Feb 11 01:44:19 +0000 2007
  author_email: hobocentral@betterbilling.net
  author_url: http://carlbtanner.net
- author: Craig Smith
  date: Wed Feb 14 08:40:22 +0000 2007
  id: 388
  content: |
    <p>Hi Tom</p>
    
    <p>My name is Craig Smith and I run oreillygmt.eu. I was running the O'Reilly bookstall at the SkillsMatter Ruby on Rails eXchange on Friday 9th Feb, where I saw you present Hobo. While you were talking I posted a piece on the oreillygmt.eu website:
    <a href="http://www.oreillygmt.eu/2007/02/hobo_web_app_bu.html" rel="nofollow">http://www.oreillygmt.eu/2007/02/hobo_web_app_bu.html</a>
    but I didn't manage to get away from the bookstall long enough to let you know.</p>
    
    <p>I hope you like it: if there's any news or events we can help you publicise, please let me know.</p>
    
    <p>All the best with Hobo, and with everything else</p>
    
    <p>Craig</p>

  date_gmt: Wed Feb 14 08:40:22 +0000 2007
  author_email: oreillygmt@oreilly.co.uk
  author_url: http://www.oreillygmt.eu
- author: RailsNoob
  date: Mon Feb 19 07:57:29 +0000 2007
  id: 446
  content: |
    <p>Anything on localization?</p>
    
    <p>P.S.: "What the heck does 'Allow comment box to float next to comments'" do and why do we care?</p>

  date_gmt: Mon Feb 19 07:57:29 +0000 2007
  author_email: railsnoob@dodgeit.com
  author_url: ""
- author: Tom
  date: Mon Feb 19 08:41:58 +0000 2007
  id: 447
  content: |
    <p>RailsNoob - To be honest I can't see localisation getting to the top of the to-do list in the near future. Still, I don't think there's anything in Hobo that makes it <em>harder</em> to do localisation. Just use the same techniques as you would in regular Rails.</p>
    
    <p>The comment box thing. That's just something that came with the wordpress theme, but it is quite useful (I'm using it for this comment). Ty checking it and scrolling up and down in a post with a lot of comments.</p>

  date_gmt: Mon Feb 19 08:41:58 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Jason
  date: Mon Mar 26 16:11:38 +0000 2007
  id: 1069
  content: |
    <p>It's 'thingamabob'.</p>

  date_gmt: Mon Mar 26 16:11:38 +0000 2007
  author_email: rockmasterj@gmail.com
  author_url: ""
- author: ""
  date: Tue Jun 19 05:44:36 +0000 2007
  id: 5216
  content: |
    <p>what if I need a web_method for the collection? Is there a way to do that? (purpose is because the collection is a nested set and I want to provide an outliner view for admin users for managing the hierarchy)</p>

  date_gmt: Tue Jun 19 05:44:36 +0000 2007
  author_email: ""
  author_url: ""
- author: Amul&#8217;s Digital Life?
  date: Tue Jun 26 19:49:35 +0000 2007
  id: 6065
  content: |
    <p>[...] Powerful mark-up language, DRYML, combines rapid development with ultimate design flexibility. The end of the cookie cutter blues! [...]</p>

  date_gmt: Tue Jun 26 19:49:35 +0000 2007
  author_email: ""
  author_url: http://amul84.wordpress.com/2007/06/26/another-plugin-gem-for-rubyrails-to-build-apps-faster/
- author: Thomas
  date: Thu Nov 15 16:05:11 +0000 2007
  id: 15251
  content: |
    <p>I tried out hobo with a new project today, but did not succeed. I did a "hobo --user-model hobouser myproject" to create a project. Then I started the server and got an error message, that the hobousers-table is missing in the db. So I did a "rake db:migrate" which did not help. I found out, that there are no migrations for the given user-model. Since the documentation is poor AND outdated as stated on some pages and the first screencast fails to run with quicktime on my windows pc, I had to stop using hobo. </p>
    
    <p>What also drives me a bit crazy: When running the hobo command, it clears the screen so often, that I cannot see, whats going on.</p>
    
    <p>I saw a video presentation of hobo from one of the rails conferences and was quite interested in hobo, but it seems, as if it cannot be used by someone, who is not involved in the development of hobo.</p>
    
    <p>PS: One last question: Do I have to use DRYML (what I liked most about rails was: I did not have to learn languages for templates, configuration-files etc.) or can I stay with RHTML.</p>

  date_gmt: Thu Nov 15 16:05:11 +0000 2007
  author_email: ""
  author_url: ""
- author: Jim
  date: Sat Nov 17 09:05:42 +0000 2007
  id: 15459
  content: |
    <p>Installed release 0.6.4 tonight and created a hobo app.  I created the databases in mysql for development, test, production and edited database.yaml correspondingly.  Then I just tried script/server to see if we'd be up in generic form.</p>
    
    <p>Got the error ActionView::TemplateError (undefined method 'extract_options!' for [{:limit=>40}]:array on line #1 of app/views/front/index.dryml:
    1: </p>
    
    <p>searching through the source that the plugin contains, I see no declaration for extract_options, but plenty of calls to it.</p>
    
    <p>Is there an "in progress" change being made so that all those calls to args.extract<em>options! are becoming extract</em>options<em>from</em>args! ?</p>
    
    <p>I have not installed the will_paginate plugin... which comes to mind because of the ":limit => 40" part of the error.</p>

  date_gmt: Sat Nov 17 09:05:42 +0000 2007
  author_email: tobinj@mac.com
  author_url: ""
- author: Jim
  date: Sat Nov 17 09:09:43 +0000 2007
  id: 15460
  content: |
    <p>And I also noticed that when you use the hobo<em>model</em>controller generation, no db/migrate/ files are created.  Is this being removed?  Or is this an "in progress" change?</p>

  date_gmt: Sat Nov 17 09:09:43 +0000 2007
  author_email: tobinj@mac.com
  author_url: ""
- author: Tom
  date: Sat Nov 17 10:30:02 +0000 2007
  id: 15467
  content: |
    <p>Folks - you should post in the forums rather than commenting on a thread that's nearly a year old :-)</p>
    
    <p>Jim - quick tip. You need Rails 2.0 RC1</p>

  date_gmt: Sat Nov 17 10:30:02 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: A Fresh Cup &raquo; Blog Archive &raquo; A Layer on Top of Rails
  date: Fri Jan 04 19:50:15 +0000 2008
  id: 20314
  content: |
    <p>[...] Interesting - What is Hobo? describes Hobo, which bills itself as &#8220;the Web App Builder for Rails.&#8221; Basically, it&#8217;s a set of plugins to add even more DRY and RAD features to the Rails framework. I think I need to spend some more time digging into plain vanilla Rails first (if there is such a thing), but this looks like it&#8217;s a rather mature project and worth some exploration in the future. [...]</p>

  date_gmt: Fri Jan 04 19:50:15 +0000 2008
  author_email: ""
  author_url: http://afreshcup.com/?p=653
author: Tom
title: What is Hobo?
excerpt: |+
  There's a fair few reactions to Hobo out there on the big wide Internets by now, and it's interesting to see people's interpretations. I suppose it's pretty obvious that people are going to jump to conclusions when I've only given a brief glimpse of what Hobo is about. I just wanted to take a quick moment to clear a few things up. [Update: this turned from a "quick moment" into a fairly comprehensive overview of what Hobo can do :-)]
  
published: true
tags: []

date: 2007-01-25 09:03:14 +00:00
categories: 
- Documentation
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/01/25/what-is-hobo-2/
author_url: http://www.hobocentral.net
status: publish
---
There's a fair few reactions to Hobo out there on the big wide Internets by now, and it's interesting to see people's interpretations. I suppose it's pretty obvious that people are going to jump to conclusions when I've only given a brief glimpse of what Hobo is about. I just wanted to take a quick moment to clear a few things up. [Update: this turned from a "quick moment" into a fairly comprehensive overview of what Hobo can do :-)]

<a id="more"></a><a id="more-30"></a>

The main point here is this - Hobo is nothing but extensions to Rails! There's nothing that Rails can do that Hobo can't. I'm not saying that Hobo will be to everyone's taste - of course you may prefer Rails as it is. I'm just making the point that Hobo only *adds* to Rails, it doesn't take anything away. Perhaps it's the slightly "magic" feel to the POD screencast -- I can see that the screencast might leave some people thinking they'd rather build the app themselves and have control over everything. So I guess I'm really just making the point that you *do* have control over everything, in just as direct a manner as you do in Rails without Hobo.

Hobo does do more than your average plugin though -- it's kind of like several plugins rolled into one. Inevitably people are going to be interested in having those features as separate plugins -- a few people have asked for DRYML by itself already. But there are a bunch of dependencies between the different features, and to be honest I won't know exactly where things can be separated until Hobo matures a bit.

So, for now at least, I've taken a different approach - you *install* all these features at once by installing Hobo, but you *use* only those features you want to. If you want the whole "web app builder" thing, then you'll end up using most or all of them, but if you just want DRYML? Not a problem, the rest of Hobo won't get in your way. If you later see that you could also benefit from, say, the ajax-mechanism, fine -- just start using it.

So perhaps a quick tour of what these features are would be in order :-)

### DRYML

This is really the heart of Hobo -- it all started with DRYML. There's a few posts on this already of course - have a look in the [documentation category](/blog/category/documentation/). DRYML consists of the templating mechanism itself, as well as a "core" tag library, with the basic things like loops and conditionals.

### Ajax Rendering

Building on DRYML, this is the ability to mark a section of your page as a "part". Having done this, Hobo will track the object that was in context when the part was rendered, and can re-render the part using the new state of that object when requested. This mechanism can be used by itself, but works best in combination with the Hobo Rapid tag library, which lets you write very simple stuff like

    <delete_button update="number_of_users"/>

and the number of users will automatically change to reflect the deletion.

Right now using the Ajax mechanism *without* also buying into Hobo Rapid is kind of a pain. Some extra work to smooth that out is in order. Perhaps some regular Rails helpers.

### Hobo Rapid Tag Library

This is where things get groovy. A tag library is basically just like a load of Rails helpers, but as DRYML tags instead of methods. Hobo Rapid contains the Hobo equivalent of link helpers, form helpers, ajax helpers, and pagination helpers. There's also some "scaffold-like" tags for default pages, and support for navigation bars.

This library is expected to grow!

### ActiveRecord Permission System

This appears prominently in the POD screencast. At it's heart it's just a simple convention for declaring who's allowed to do what to your models (create, update, delete and view). The permissions come into effect in two places: in customising the views, and in validating http requests.

View customisation is provided in the tag library. The output of various tags is dependent on permissions. For example the `<edit>` tag will automatically become a read-only view if the current user does not have edit permission.

Validation of web requests is done in Hobo's generic model controller (see below). If the request, be it a view, a create, an update or a delete (http get/post/put/delete) is not permitted for the current user, it will be rejected.

### Cross-Model Search

Fairly simple but useful. Models can declare which columns are searchable (there are sensible defaults of course!) and Hobo provides both server and client-side support for a nice ajaxified search that finds many types of model from a single search page.

### Switchable Themes

A Hobo theme consists of public assets such as a stylesheet and images, and some tag definitions. The tags define the basic HTML structure of the various theme elements - the overall page, header and footer, navigation bar, sidebars, panels (boxed sections within the page) etc. Themes are switchable by changing a configuration variable. All the variable does is determine the paths used to find the tag definitions (app/views/hobolib/themes/*theme-name*) and the public assets (public/hobothemes/*theme-name*).

### User Management (Acts As Authenticated)

In order for the permission system to work, a user model must be present. For that reason we decided to go ahead and include AAA in Hobo. It's been tweaked a bit -- the controller has been merged with Hobo's "front" controller (so called because it gives you your front page and related pages like search, login and signup). The user model methods that are not commonly changed have been moved out into a module to keep your user model clean.

Hobo also adds the concept of a guest user, this is a pseudo model that is not stored in the database. It's just a place to define the permissions for someone who has not logged in. One implication of this change this is that instead of testing if `current_user` is nil, you test for `current_user.guest?`.

### ActiveRecord Composable Query Mechanism

It's common practice with ActiveRecord to write query methods to capture standard queries your application needs beyond the magic `find_by_thingumybob` methods. A problem I ran into was that I wanted to be able to *compose* queries: find everything that matches this query *or* that one; find the first record that matches some query *and* some other one.

I found I needed such a feature in Hobo so I implemented the following:

    Post.find(:all) { (title_contains("Hobo") | content_contains("Hobo")) &
                       is_in(news_category.posts) }
    User.find(:first) { name_is("Tom") | email_is("foo@bar.com") }

Note that in the first example, the collection `my_category.posts` doesn't need to be loaded - the query generates SQL and runs entirely on the database.

The query operations in those examples -- `*_contains`, `*_is` and `in_collection` -- are all built in. If you write class methods on your model that return SQL expressions you can use those in the query too.
    
### Generic Model Controller (CRUD Support)

Hmmm - this does a fair few things. Maybe I need another cup of tea... Slurp, ahhh. Sorry where was I? Oh yeah - the model controller. To get this functionality, add this to your controller

    hobo_model_controller

It's just a short-hand for including `Hobo::ModelController`. You can also generate a controller which already contains this declaration (hey - every little helps!) with:

    $ ./script/generate hobo_model_controller <model-name>


**CRUD support**

Hobo derives the model class from the controller class name, so you should follow the Rails convention of `PostsController` for model `Post` (the generator will do this for you of course). You then get the basic CRUD methods familiar from scaffolding: index, show, new, create, edit and update.

The controller also has support for your `has_many` and `belongs_to` associations. Firstly, your `has_many` associations get published automatically, so for example the URL

    /posts/12/comments

Would map to the action `show_comments`, which is implemented for you. Also

    /posts/12/comments/new

Will invoke the `new_comment` action - again it's implemented for you. Note that the form on that page doesn't post to `/posts/12/comments` but to `/comments` as usual. I decided it was best to have a single URL for creating a given model.

There's also support for your associations when creating / updating models. Without going into too much detail in this overview, when you post (create) or put (update), you can set both `has_many` associations and `belongs_to` associations. You can either pass the id of an existing record, or pass entirely new records in nested parameter hashes. There's support for all this in DRYML and Hobo Rapid, so for example if a person has an address as a separate, associated model, you can easily build a single form with fields for both the person and the associated address.

**Data filters**

The composable query mechanism for ActiveRecord has been described above. Data filters allow you to expose these queries to the web. This is easiest to explain with an example. Say we have people that are members of groups, and we want a page with all the people not in a particular group. Inside the people controller we define a data filter:

    def_data_filter :not_in do |collection|
      not_in(collection)
    end

A page with all the people not in the group with id 7 would then be available at

    /people?where_not_in=group_17
  
**Enhanced autocomplete**

Rails already has support for working with the Scriptaculous auto-completer through the helper `auto_complete_for` (although that's on its way out in 2.0). Hobo's version is enhanced to work with the data filter mechanism. Say for example you wanted an auto-completer to allow you to add people to a list - you don't want the people already in the list to be included in the completions. You would add the following to your controller:

    def_data_filter :not_in do |collection|
      not_in(collection)
    end

    autocomplete_for :name

You would then point your auto-completer at (e.g.) `/people/completions?for=name&where_not_in=list_12`

Hobo Rapid has an auto-completer tag so the client side is nice and easy too.
  

**Remote procedure calls**

When DHH introduced the Simply Restful stuff, he described CRUD as an aspiration rather than a hard rule (IIRC). In other words, you shouldn't go crazy trying to model absolutely everything as resources -- there will still be "remote procedure calls" (RPC) that we post to. I hit this recently with a need for a "reset password" service on an app I'm building. (BTW - this is basically how Hobo moves forward - if I hit a need for a feature that I feel will crop up again and again, I build it into Hobo, not the app. In this case I didn't want to build password reset into Hobo, but I did build the RPC mechanism).

The basic procedure is: write an action in your controller as normal. Add `web_method <method-name>`. Hobo will add a route for your method, and apply a before filter so the object in question is already available in `@this`. Hobo's ajax mechanism supports updating the page with results from your method, and there's integration into the permission system too.
	
Let's see an example - the reset password method. In the controller we add:

	web_method :reset_password
	def reset_password
	  new_password = @this.reset_password
	  hobo_ajax_response(@this, :password => new_password)
	end

On the model we can add a method `can_call_reset_password?(user)`. In my case I only wanted the super-user to have access to this method so I didn't need `can_call_reset_password?`.

The method will be available to HTTP posts at, e.g.

    /users/21/reset_password

For the client side there's a `<remote_method_button>` tag (note to self: should be called `<web_method_button>`?)

**Alternative show methods**

Simply Restful introduced the semicolon in the URL to access alternate views of the same object. So

    /posts/12

Would be a 'normal' view of the post, while
 
    /post/12;edit

Would give you a form to edit the post -- still a view of the post, just a different one. You'll probably find the need for additional "alternative views", e.g. you might have a main view of a user, plus a separate "My Profile" page where users can edit details that don't change so often, like their email address. Hobo allows you to simply say

    show_method :profile

In your controller. You then create `app/views/users/profile.dryml`. You also get a named route `person_profile` so you can call `person_profile_url(fred)` and get the URL back.

### Migration Enhancements

This is a little one, but very useful. In `create_table` calls, you can add columns like this

    t.string :name, :subject, :limit => 50

instead of

    t.column :name, :string, :limit => 50
    t.column :subject, :string, :limit => 50

There's also `t.auto_dates` that gives you `updated_at` and `created_at`, and

    t.fkey :zip, :zap

That will give you integer columns zip_id and zap_id. 

### ID Names

In ActiveRecord everything has a numeric ID. It's common however, that models also have an identifying name (e.g. a name column where every row is unique). If a model has an ID name like this, it's nice to be able to sometimes use it instead of the numeric ID, for example in readable URLs. If your model declares `hobo_model`, you can also declare

    id_name <column-name>

If you don't specify a column it defaults to `name`. This gives you a read/write attribute `id_name` which is just an alias for the column in question. You also get `find_by_id_name` on the class.

If you are using Hobo's `model_controller` you can then use names instead of IDs in your URLs, e.g. (using ID names in combination with the associations support):

    /categories/News/posts

The helper `object_url` will generate this kind of URL too - if the object you pass supports ID names.

### That's All Folks!

That's pretty much everything, although of course lots of detail is lacking. Oh and there's a *ton* of great new stuff just around the corner of course!
