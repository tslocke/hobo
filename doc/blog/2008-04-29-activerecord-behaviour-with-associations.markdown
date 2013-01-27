--- 
wordpress_id: 201
author_login: admin
layout: post
comments: 
- author: solars
  date: Wed Apr 30 06:13:32 +0000 2008
  id: 32937
  content: |
    <p>Thanks for the nice writeup Tom :)</p>
    
    <p>I remember there was only little information about when things get saved, back when I started with rails.</p>

  date_gmt: Wed Apr 30 06:13:32 +0000 2008
  author_email: cb@tachium.at
  author_url: http://railsbased.org
- author: Joe Van Dyk
  date: Mon May 05 20:48:11 +0000 2008
  id: 33574
  content: |
    <p>http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html has details on when things are saved.  </p>
    
    <p>Look down in the "Unsaved objects and associations" section.</p>

  date_gmt: Mon May 05 20:48:11 +0000 2008
  author_email: joe@pinkpucker.net
  author_url: http://pinkpucker.net
- author: Ara Vartanian
  date: Sun Oct 05 16:22:06 +0000 2008
  id: 48888
  content: |
    <p>Thanks Tom.</p>
    
    <p>Yeah, this is one of the things that drives me crazy about Rails and ActiveRec. I don't like the fact that DB calls happen silently in the background (and therefore fail silently in the background). There have been a couple of times where I've had tables messed up with half-formed object graphs on account of it.</p>
    
    <p>It gets even better with the #build series of methods, where you can associate to a collection without any save at all. My only problem with #build is that it only allows me to pass in attributes for a new objects rather than to assign an existing object and postpone the save for later.</p>

  date_gmt: Sun Oct 05 16:22:06 +0000 2008
  author_email: ara_vartanian@yahoo.com
  author_url: ""
- author: Chris Apolzon
  date: Thu Jun 03 17:27:53 +0000 2010
  id: 51933
  content: |
    <p>Another great ruby skills post!  I hope we can expect more of these in the future (obviously when yall have more time and ant busy with actually working on the hobo codebase)</p>
    
    <p>Articles like this are what ruby/rails needs to lower the barrier of entry for newcomers.</p>

  date_gmt: Thu Jun 03 17:27:53 +0000 2010
  author_email: Apolzon@gmail.com
  author_url: http://Applesonthetree.com
author: Tom
title: "\tActiveRecord behaviour with associations"
excerpt: |+
  The interaction between ActiveRecord and the database is very simple when working with a single record - it's always pretty clear when the database is going to be changed. What about when you're working with multiple records and associations? I did some experiments way back at the start of the Hobo project, but recently I wanted to check if anything had changed.
  
  So I threw together some simple experiments, and turned on logging in the console. It's a bit rough and certainly not exhaustive, but I formatted it in markdown out of habit and then though hey, I should post this, so here it is.
  
  Is this stuff documented somewhere? I never found it if it is. I wonder if most Rails devs know about all this already.
  
  This is all in Rail 2.0.2 BTW.
  
published: true
tags: []

date: 2008-04-29 13:36:24 +00:00
categories: 
- Ruby Skills
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2008/04/29/activerecord-behaviour-with-associations/
author_url: http://www.hobocentral.net
status: publish
---
The interaction between ActiveRecord and the database is very simple when working with a single record - it's always pretty clear when the database is going to be changed. What about when you're working with multiple records and associations? I did some experiments way back at the start of the Hobo project, but recently I wanted to check if anything had changed.

So I threw together some simple experiments, and turned on logging in the console. It's a bit rough and certainly not exhaustive, but I formatted it in markdown out of habit and then though hey, I should post this, so here it is.

Is this stuff documented somewhere? I never found it if it is. I wonder if most Rails devs know about all this already.

This is all in Rail 2.0.2 BTW.

<a id="more"></a><a id="more-201"></a>


## Some simple models

	class Post < ActiveRecord::Base
	  has_many :comments
	  has_many :categorisations
	  has_many :categories, :through => :categorisations
	end
	
	class Comment < ActiveRecord::Base
	  belongs_to :post
	end
	
	class Category < ActiveRecord::Base
	  has_many :categorisations
	end
	
	class Categorisation < ActiveRecord::Base
	  belongs_to :post
	  belongs_to :category
	end
	
## `has_many` (not through)

### Assigning to the array on a new record

New comments are created along with a new post:

	>> p = Post.new
	=> #<Post id: nil>
	>> p.comments = [Comment.new]
	=> [#<Comment id: nil, post_id: nil>]
	>> p.save
	  Post Create (0.000601)   INSERT INTO posts VALUES(NULL)
	  Comment Create (0.000195)   INSERT INTO comments ("post_id") VALUES(1)
	=> true

### Appending to the array

For a post that exists, the appended comments are created immediately:

	>> p
	=> #<Post id: 1>
	>> p.comments << Comment.new
	  Comment Create (0.000481)   INSERT INTO comments ("post_id") VALUES(1)
	=> [#<Comment id: 1, post_id: 1>, #<Comment id: 2, post_id: 1>]
	
### Assigning to the array on an existing record

Comments no longer in the array have their foreign_key set to NULL. (I'd guess this changes if you declare `:dependent => :destroy`, but I didn't try it)

	>> p.comments
	=> [#<Comment id: 1, post_id: 1>, #<Comment id: 2, post_id: 1>]
	>> p.comments = []
	  Comment Update (0.001335)   UPDATE comments SET post_id = NULL WHERE (post_id = 1 AND id IN (1,2))
	=> []
	
New comments in the array are created immediately:

	>> p.comments = [Comment.new]
	  Comment Create (0.000504)   INSERT INTO comments ("post_id") VALUES(1)
	=> [#<Comment id: 3, post_id: 1>]

Existing comments have their foreign key set

	>> p2 = Post.create
	  Post Create (0.000820)   INSERT INTO posts VALUES(NULL)
	=> #<Post id: 2>
	>> c = p.comments.first
	=> #<Comment id: 3, post_id: 1>
	>> p2.comments = [c]
	  Comment Load (0.000292)   SELECT * FROM comments WHERE (comments.post_id = 2) 
	  Comment Update (0.000684)   UPDATE comments SET "post_id" = 2 WHERE "id" = 3
	=> [#<Comment id: 3, post_id: 2>]
	
## `belongs_to`

When assigning `c.post` on an existing comment, the change is saved when the comment is saved:

	>> c.post == p2
	=> true
	>> c.post = p
	=> #<Post id: 1>
	>> c.save
	  Comment Update (0.000778)   UPDATE comments SET "post_id" = 1 WHERE "id" = 3
	=> true
	
When assigning a `c.post` to a new post, the post is created when the comment is saved:

	>> c
	=> #<Comment id: 3, post_id: 1>
	>> c.post = Post.new
	=> #<Post id: nil>
	>> c.save
	  Post Create (0.000464)   INSERT INTO posts VALUES(NULL)
	  Comment Update (0.000148)   UPDATE comments SET "post_id" = 3 WHERE "id" = 3
	=> true

This happens the same way when the comment is new -- both are created together:

	>> c = Comment.new
	=> #<Comment id: nil, post_id: nil>
	>> c.post = Post.new
	=> #<Post id: nil>
	>> c.save
	  Post Create (0.000499)   INSERT INTO posts VALUES(NULL)
	  Comment Create (0.000161)   INSERT INTO comments ("post_id") VALUES(4)
	=> true
	
## `has_many :through`

### Assigning to the array has no effect:

Assignment to `p.categories` where `p` is an existing post:

	>> p
	=> #<Post id: 1>
	>> cat = Category.create
	  Category Create (0.000427)   INSERT INTO categories VALUES(NULL)
	=> #<Category id: 1>
	>> p.categories = [cat]
	  Category Load (0.000289)   SELECT categories.* FROM categories INNER JOIN categorisations ON categories.id = categorisations.category_id WHERE ((categorisations.post_id = 1)) 
	=> [#<Category id: 1>]
	>> p.save
	=> true
	
Note there were no changes to the categories table.
	
Assignment to `p.categories` where `p` is a new post:

	>> p = Post.new
	=> #<Post id: nil>
	>> p.categories = [cat]
	=> [#<Category id: 1>]
	>> p.save
	  Post Create (0.000513)   INSERT INTO posts VALUES(NULL)
	=> true
	
Again, nothing happens to the categories table
	
### Appending to the array does have an effect

Can't append to a has-many-through on a new record:

	>> p = Post.new
	=> #<Post id: nil>
	>> p.categories << cat
	ActiveRecord::HasManyThroughCantAssociateNewRecords: Cannot associate new records through 'Post#categorisations' on '#'. Both records must have an id in order to create the has_many :through record associating them.
	
Can append to a has-many-through on an existing record. The joining record is created immediately:

	>> p = Post.find(:first)
	  Post Load (0.000365)   SELECT * FROM posts LIMIT 1
	=> #<Post id: 1>
	>> p.categories
	  Category Load (0.000294)   SELECT categories.* FROM categories INNER JOIN categorisations ON categories.id = categorisations.category_id WHERE ((categorisations.post_id = 1)) 
	=> []
	>> p.categories << cat
	  Categorisation Create (0.000479)   INSERT INTO categorisations ("post_id", "category_id") VALUES(1, 1)
	=> [#<Category id: 1>]

But this is not allowed if the category is new:

	>> p.categories << Category.new
	ActiveRecord::HasManyThroughCantAssociateNewRecords: Cannot associate new records through 'Post#categorisations' on '#'. Both records must have an id in order to create the has_many :through record associating them.

Did you learn something?
