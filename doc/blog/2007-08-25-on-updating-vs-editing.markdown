--- 
wordpress_id: 172
author_login: admin
layout: post
comments: 
- author: larryk
  date: Sun Aug 26 02:40:16 +0000 2007
  id: 9652
  content: |
    <p>Hi Tom,</p>
    
    <p>Thanks for your post. editable_by? is the right solution to speed up Hobo apps that have a per-field permission system. </p>
    
    <p>Maybe a way to split the difference between whether the generator should include an editable<em>by? skeleton or not is to mention editable</em>by? in comments within the updateable<em>by? skeleton. Something like "Check out the editable</em>by? optional model method if you're doing per-field permissions."</p>
    
    <p>I agree with your idea of speeding up Hobo by enhancing the editor tag to enable better programmer control of what will happen. It's a great solution: faster in the usual case, better self-documentation in the less common case. Win-win!</p>
    
    <p>Thanks again for the great Hobo project.</p>
    
    <p>Regards,</p>
    
    <p>Larry</p>

  date_gmt: Sun Aug 26 02:40:16 +0000 2007
  author_email: hobo@kluger.com
  author_url: ""
- author: Seewenjoync
  date: Tue Mar 01 14:16:03 +0000 2011
  id: 52165
  content: |
    <p>Medication For Alcohol Withdraw  <a href="http://edwardkennedyonline.com/" rel="nofollow">buying clonazepam online</a> Order Klonopin (Clonazepam) drugs at reputable online pharmacy and save money. No hidden fees! http://edwardkennedyonline.com/ - clonazepam without prescription</p>

  date_gmt: Tue Mar 01 14:16:03 +0000 2011
  author_email: driepeque@myspaceave.info
  author_url: http://edwardkennedyonline.com/
author: Tom
title: On updating vs. editing.
excerpt: |+
  We recently had some great posts on the forum from larryk. I was just replying to Larry, and, what with the cup of rather fine Darjeeling, and an indulgently large pile of mini gingerbread-man biscuits, I got into the swing of it until I thought - this is a blog post!
  
  Quick background -- Larry has a model with 60(!) fields, and he has a page with `<editor>` tags for all of them. He's discovered an O(n^2) problem because each call to `<edit>` calls `updatable_by?` which has to check *all 60* fields to see what has changed.
          
  Not pretty.
  
published: true
tags: []

date: 2007-08-25 19:08:53 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/08/25/on-updating-vs-editing/
author_url: http://www.hobocentral.net
status: publish
---
We recently had some great posts on the forum from larryk. I was just replying to Larry, and, what with the cup of rather fine Darjeeling, and an indulgently large pile of mini gingerbread-man biscuits, I got into the swing of it until I thought - this is a blog post!

Quick background -- Larry has a model with 60(!) fields, and he has a page with `<editor>` tags for all of them. He's discovered an O(n^2) problem because each call to `<edit>` calls `updatable_by?` which has to check *all 60* fields to see what has changed.
        
Not pretty.

<a id="more"></a><a id="more-172"></a>

First of all, some background on the rationale behind the design of `editable_by` and `updatable_by`.

The Hobo permission system serves two totally different roles:

 1. Policing POST and PUT requests from the client
 2. Automatically adjusting the view rendering so people see only what is appropriate for them.

For 1, we have to cope with the fact that a single request can change many fields, so we have the moethod updatable_by? which is responsible for allowing/denying the overall change to the object. We know what the old state is, we know what the new state is, so we ask "is this change ok?" 

For 2, we want to know something entirely different -- is a user allowed to edit a specific field? For that (as spotted by Matt in that same thread) you can write a method editable_by? which takes the user and the name of the field they want to edit. There's no "new" value in this case, because how do we know what the user will do?

Hang on though -- the `hobo_model` generator doesn't even create a stub for `editable_by?`. Why not?

Well although `editable_by?` and `updatable_by?` are quite different questions, the underlying application logic is always going to be the same. `updatable_by?` has to cover every eventuality, so in theory it should be possible to somehow derive `editable_by?` from `updatable_by?`.

In theory.

Well it turns out there's a clever trick that does something along those lines.

Hmmm. Clever trick. Clever tricks can be good and they can be veeeeeery bad. Right now I'm still leaning towards liking this particular trick, but I'm not totally sure yet.

It goes like this. Hobo defined an extremely volatile type `Hobo::Undefined`. If you so much as look at one of these it goes BANG! (raises a Hobo::UndefinedAccessError). When Hobo needs to know if field 'foo' is editable by user Fred, it looks for the `editable_by?` method. If that's not there the clever trick comes into play. Hobo creates a "hypothetical" new object, exactly the same as the current one, but field 'foo' has the value `Hobo::Undefined`. Hobo can now ask if the object is `updatable_by?` the current user, passing this tricky little thing as the new state of the object.

Now if your `updatable_by?` method depends on the value of 'foo' in any way - BANG! Hobo catches the exception and says nope -- not editable.

It's not fool-proof, but it gives the correct results in many situations, and if it lets you down, well you'll just have to write your `editable_by?` method. Make the common things easy, keep the uncommon things possible. 

Back to Larry's problem, `editable_by?` will generally be quicker than `updatable_by?` as it doesn't have to check for all the many things that might have been done to an object. So defining `editable_by?` should improve things a lot.

We've been thinking about the whole morph-the-view-to-the-user thing though, and we've come to a conclusion that should make things even faster. The behaviour of `<editor>` where it automatically degrades to a view is pretty nifty, and very useful in some situations, but in our apps at least 95% of the calls to `<editor>` are *always* going to result in an editor. The overhead of going to the permission system is really undesirable.
        
So we'll probably make the auto-degrade feature optional, and the default will be off. If you want an editor that will degrade to a view when the user has no edit permission, you'll need to do something like:

    <editor or_view/>
    
I actually prefer that as it says more clearly what you're getting -- an editor, or possibly a view.
    
We can do something similar for the few tags that render nothing when the user is not allowed to perform the action in question, e.g.

    <delete_button if_allowed/>
