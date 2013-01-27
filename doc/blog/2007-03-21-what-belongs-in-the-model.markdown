--- 
wordpress_id: 145
author_login: admin
layout: post
comments: 
- author: Adrian Madrid
  date: Mon Mar 26 16:52:50 +0000 2007
  id: 1070
  content: |
    <p>Tom, great write up. There is a lot of gray areas I think and  you, very much like DHH, are very opinionated. I think a good compromise is what the Streamlined guys are doing with the ui "concerns" in their streamlined directory. Like you I think most of these commands should/could go fine in  the model although some are very much closer to a separate area like these ui concerns. Just my .02 cents.</p>
    
    <p>AEM</p>

  date_gmt: Mon Mar 26 16:52:50 +0000 2007
  author_email: aemadrid@gmail.com
  author_url: ""
- author: Tom
  date: Wed Mar 28 10:24:18 +0000 2007
  id: 1113
  content: |
    <p>Adrian - do you see anything that Hobo puts in the model that you think would be better implemented as separate UI concerns?</p>

  date_gmt: Wed Mar 28 10:24:18 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
author: Tom
title: What belongs in the model?
excerpt: |+
  It's a regular post-a-thon :-)
  
  I just came across [this](http://weblog.rubyonrails.org/2006/8/16/streamlined-taking-admins-beyond-scaffolding) old post on the Rails blog about Streamlined.
  
  Of particular note:
  
  > I really like their approach of using separate UI classes instead of contaminating the model classes with administrative concerns.
  
  That's DHH, and I wholeheartedly agree. But then Hobo doesn't have the "separate UI classes". In fact Hobo does ask you to add extra metadata to your models which is then used in constructing the views.
  
  Have I slipped up? I don't think so...
  
published: true
tags: []

date: 2007-03-21 21:36:47 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/03/21/what-belongs-in-the-model/
author_url: http://www.hobocentral.net
status: publish
---
It's a regular post-a-thon :-)

I just came across [this](http://weblog.rubyonrails.org/2006/8/16/streamlined-taking-admins-beyond-scaffolding) old post on the Rails blog about Streamlined.

Of particular note:

> I really like their approach of using separate UI classes instead of contaminating the model classes with administrative concerns.

That's DHH, and I wholeheartedly agree. But then Hobo doesn't have the "separate UI classes". In fact Hobo does ask you to add extra metadata to your models which is then used in constructing the views.

Have I slipped up? I don't think so...

<a id="more"></a><a id="more-145"></a>

Firstly Hobo doesn't *need* "UI classes" because DRYML is powerful enough that we can configure everything to our hearts content in mark-up. As I said in my talk at the Skills Matter RoR exchange, it's like the difference between an app with a preferences dialogue (UI classes where you set a bunch of options) and an app which is scriptable (DRYML).

Secondly, I don't think I've added any metadata to the models that doesn't belong there. Notice I say "think". Coming across that post has made me think that I should really review this. So let's do it -- right now :-) [fires up Hobo model extensions in trusty Emacs]. Let's make sure all the model extensions really belong there.

Before we start though, how do we decide what belongs in the model and what is merely an "administrative concern". Is it a clear boundary or a grey one? I have a simple trick I sometimes use to help clarify this design challenge. When the coming [Command Line Renaissance](http://www.pikesoft.com/blog/index.php?itemid=152) happens, and you're building the fashionable new command-line interface for your app, will you still need this behaviour? If yes, it probably belongs in the model. If no it probably doesn't. It's an OO thing. Is this an innate part of the behaviour of the object you are modelling? Is it just something that you need to put this object on the web? Notice that this is a more subtle point than asking "is this a user-interface issue?". Think about the models in a blog app. It's all user-interface! The thing only exists in the first place because people want to read the blog!

Bottom line - there will always be grey areas. Some things will be absolutely not appropriate for the model, some will obviously belong in the model, some will be tricker. 

OK so lets tour the Hobo model extensions and make some calls.

## Permission system

You don't have to do much coding with Hobo before you realise that modelling the permissions of your various objects is a very central and fundamental part of modelling your domain. To me this very clearly belongs in the model.

I guess you could say that Hobo makes the user model special, and in doing so extends the meaning of modelling to include modelling the rules governing what users are allowed to do to what. I think this has been a huge win and is an idea that could be taken a lot further.

An interesting question though: are these permissions innate to the models themselves, or could we imagine having a different set of permissions for different contexts? Pluggable permissions. Hmmm. How about a concise yet powerful rule-based DSL for declaring permissions? Sheesh - so many ideas so little time...

## Extended type declarations.

Hobo lets you say

    set_field_type :content => :html

If you then do, e.g.

	Post.find(:first).content.class
	=> Hobo::HtmlString

(That's just a pretty much empty subclass of `String` BTW.) OK this one's easy. That's a model concern. No question.

## Default order

    set_default_order "created_at desc"

That order will then be used in your `index` pages. There's a kind of asymmetry in ActiveRecord here -- you can specify the default order for `has_many` collections, but there's no way to specify a default order for a top-level `find(:all)`. So we've really just balanced things out. Model concern.

## Never show

    never_show :password

The word "show" immediately cries out "user-interface issue!". In fact this declaration is just a short-hand for something you could do anyway with `viewable_by?`. So if the permission system belongs in the model, so does `never_show`.

## Creator attributes

    set_creator_attr :author

This tells Hobo that the author attribute should be automatically set to the user that creates the object. On the web this means the currently logged-in user for the session from which the object was created. In another context it might mean something else. Again this idea follows naturally from the decision to model users as something special. To me this does belong in the model.

## Search columns

    set_search_columns :title, :content

This tells Hobo which columns to include in the built-in search feature. This is a bit like writing custom find methods on your models. We already have the magic methods like `find_all_by_title_and_content`. What we're doing here is highlighting a particular query as special in some way, which to be honest feels a bit dodgy. Special from what point of view? From the point of view of your web-app? I can see this possibly moving out of the model.

## Display name

If your model has an attribute `display_name`, this is used as the default text for the object in links and such-like. It's also very useful for logging, and for debugging, and would certainly get re-used in your command-line UI. My feeling is that a display-name is an innate part of a thing, and so this does belong in the model.

OK that's about it. There are a few other extensions but they're so obviously part of the model layer that they're not worth mentioning. So it was only really `set_search_columns` that was called into question.

The overall feeling I've got from this exercise is that the decision to model users as something special, something that has permissions, has lead to a lot more stuff going into the model than might otherwise. I don't think this is at all wrong, but in asking these questions, some lights have gone on and I can see some advantages of moving this stuff into a separate place. I just wish those ideas didn't have to get pushed to the bottom of a veeery long to-do list...
