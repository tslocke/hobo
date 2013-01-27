--- 
wordpress_id: 10
author_login: admin
layout: post
comments: 
- author: ""
  date: Sat Dec 23 00:24:39 +0000 2006
  id: 19
  content: |
    <p>When defining the ul_for tag, do you have to add attrs for common html attributes like class, events etc.? I fear that I'd have to keep visiting the tag definition to add each html attribute as I need it.</p>
    
    <p>Your tags definitely look cleaner than irb. Have you given any thought to hilighting custom tags in editors like textmate?</p>
    
    <p>Cheers</p>

  date_gmt: Sat Dec 23 00:24:39 +0000 2006
  author_email: ""
  author_url: ""
- author: tom
  date: Sat Dec 23 06:58:04 +0000 2006
  id: 21
  content: |
    <p>There's a solution to the attribute issue.</p>
    
    <p>Any attributes you pass to a tag that are not mentioned in the <code>attrs</code> declaration will appear in a hash <code>options</code>. Then, you can use the special attribute <code>xattrs</code> (eXtra Attributes) on any tag -- pass a hash and the key/value pairs become attributes. To pass a Ruby value rather than a string to an attribute, you precede it with a hash symbol. So:</p>
    
    <pre><code><def tag="ul_for">
      <ul xattrs="#options">
        <repeat>
          <li><tagbody/></li>
        </repeat>
      </ul>
    </def>
    ------
    <ul_for id="my_list" class="small"> ... </ul_for>
    </code></pre>
    
    <p>In fact the <code>xattrs="#options"</code> case is so common that I made it the default. You can just say <code>xattrs=""</code>. Not sure if that's a bit cryptic -- what do you think?</p>
    
    <p>As for syntax highlighting, it's all just xml so it highlights just fine.</p>

  date_gmt: Sat Dec 23 06:58:04 +0000 2006
  author_email: tom@livelogix.com
  author_url: http://
- author: Vish Kohli
  date: Sun Jan 21 17:04:26 +0000 2007
  id: 175
  content: |
    <p>Tom,</p>
    
    <p>DRYML may make the code more concise, but the cost - of getting your tags right and debugging if you get it wrong (like debugging for the fact that one typed ul-for and not ul_for or whether to make it an element or an attib)- seems too high.  Now that you have a tag lib in the picture, you have introduced a learning curve plus one need's help to prevent mistakes in the markup.   why's Markaby has not caught on for the same reason (I know a few people who tried and gave it up).</p>
    
    <p>OTOH, with eRB, if you know Ruby which is needed everywhere else anyway, your chances of making mistakes are smaller and you progress faster - you may not be as concise but you've gained in the propensity to get it right the first time which implies faster development and easier maintenance by other people who're using your code.</p>
    
    <p>I commend your effort and hope you'll see my honest criticism for what it is.</p>
    
    <p>Regards
    Vish</p>

  date_gmt: Sun Jan 21 17:04:26 +0000 2007
  author_email: donnoit@yahoo.com
  author_url: ""
- author: Tom
  date: Sun Jan 21 17:56:58 +0000 2007
  id: 176
  content: |
    <p>Vish - compliments are great but criticisms are what move projects forward, so yes I take it as constructive :-)</p>
    
    <p>In a future version Hobo will know what the standard HTML tags are (i.e. we'll simply hard-code a list of known HTML tags), and all other tags will convert to method calls. So you will in fact get an error if you try to use <code>ul-for</code>.</p>
    
    <p>Your other point is a little un-clear: "whether to make it an element or an attrib". Are you referring to the common XML dillemma of whether to model some piece of data as an element or an attribute? I don't think that problem arises in DRYML. I'd be interested to hear a clarification on this point.</p>
    
    <p>Regarding your conclusion that overall eRB is quicker and easier to maintain, I'd say you need to back that up a bit more. I'm using DRYML in several big projects at the moment, and my experience is quite the opposite. DRYML is slashing development time rather dramatically.</p>
    
    <p>Thanks</p>
    
    <p>Tom.</p>

  date_gmt: Sun Jan 21 17:56:58 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Vish Kohli
  date: Wed Jan 24 23:49:49 +0000 2007
  id: 192
  content: |
    <p>Tom wrote:</p>
    
    <blockquote>
      <p>Are you referring to the common >XML dillemma of whether to model >some piece of data as an element >or an attribute? </p>
    </blockquote>
    
    <p>Yes, such as for "tasks" and "name_link" in the example 
    for attr="tasks">link/>for></p>
    
    <p>I still don't see the net value in using DRYML and would appreciate some clarification from you on these counts: </p>
    
    <ol>
    <li>It seems to be a regression to dump a richly-expressive language like Ruby in favor of XML/DRYML.  With XML/DRYML, you essentially have to contrive XML elements for various Ruby language constructs such as loops (I noticed you have a ), conditionals such as if-then-else, case statements etc, some of which can get awkward and very error prone (users of BPML like me have been bitten by this in the past).</li>
    </ol>
    
    <p>Would you advocate changing Rake to use XML instead of Ruby(a la Ant)?</p>
    
    <ol>
    <li><p>XML/DRYML seems to be a way to limit the usage of Ruby code in Views.  But that should be so by design: anytime you're writing more than a little Ruby code in a view, you ought to move it away into a helper file.  Your way seems to be to move it out into a taglib.  So is it really buying much as opposed to  following good design practice.</p></li>
    <li><p>As for the benefit of conciseness, there are other ways to get concise with your view code without eliminating Ruby - see HAML for example (http://haml.hamptoncatlin.com).</p></li>
    </ol>
    
    <p>Would appreciate hearing your thoughts.</p>

  date_gmt: Wed Jan 24 23:49:49 +0000 2007
  author_email: donnoit@yahoo.com
  author_url: ""
- author: Vish Kohli
  date: Wed Jan 24 23:55:14 +0000 2007
  id: 193
  content: |
    <p>Sorry the example in my post above didn't come out nice and it seems to have caused some formatting issues..I should have read the instructions better, I guess.  Here's another try with backticks:</p>
    
    <p><code><ul_for attr="tasks"><name_link/></ul_for></code></p>

  date_gmt: Wed Jan 24 23:55:14 +0000 2007
  author_email: donnoit@yahoo.com
  author_url: ""
- author: Ed
  date: Sun Feb 25 22:34:46 +0000 2007
  id: 569
  content: |
    <p>There is an error (typo?) in the example code above. The following tag definition:</p>
    
    <p><code><def tag="name" attrs="this"><%= this.name %></def></code></p>
    
    <p>will throw the following error:</p>
    
    <p><code>invalid attrs in def: this</code></p>
    
    <p>To fix, replace 'attrs' with 'attr'.</p>

  date_gmt: Sun Feb 25 22:34:46 +0000 2007
  author_email: advisaed@hotmail.como
  author_url: ""
- author: Tom
  date: Sun Feb 25 22:44:17 +0000 2007
  id: 571
  content: |
    <p>Thanks Ed,</p>
    
    <p>Actually what's happened is that you don't explicitly give a <code>this</code> attribute anymore. So the correct def is now:</p>
    
    <pre><code><def tag="name"><%= this.name %></def>
    </code></pre>
    
    <p>I should fix the post!</p>
    
    <p>(done now)</p>

  date_gmt: Sun Feb 25 22:44:17 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Josh Adams
  date: Mon Mar 26 14:03:19 +0000 2007
  id: 1062
  content: |
    <p>I'm glad this exists.  I don't use it, and I don't see myself using it (I actually prefer markaby to almost anything I've used in the past, evar, template-wise).  But I'm glad development happens for those that like tag-based languages.  I just have /terrible/ memories of iHTML.</p>

  date_gmt: Mon Mar 26 14:03:19 +0000 2007
  author_email: knewter@gmail.com
  author_url: http://knewter.wordpress.com
- author: Tom
  date: Wed Mar 28 10:27:45 +0000 2007
  id: 1114
  content: |
    <p>Josh - I agree that Markaby is a very nice option. The problem it has is that it doesn;t make a good interface between coder and designer, but I'm guessing that issue doesn't crop up in your world. There are some DRYML features that you might find interesting that Markaby can't do though - inner tags, ajax parts, and more coming.</p>

  date_gmt: Wed Mar 28 10:27:45 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Dmitris
  date: Wed May 23 10:13:13 +0000 2007
  id: 3440
  content: |
    <p>Nice</p>

  date_gmt: Wed May 23 10:13:13 +0000 2007
  author_email: lhfmyt@gmail.com
  author_url: http://nissan-uae.car0esperanza.info/1995-dodge-neon-online-manual.htm
- author: Geira
  date: Sat Jun 16 18:04:13 +0000 2007
  id: 5044
  content: |
    <p>Kudos for trying to minimize Ruby code in the presentation layer (which based on all experience <em>is</em> a bad idea, and not dogma as Dave Thomas claims). Too bad the solution involves mixing unrelated tags into the same namespace.</p>

  date_gmt: Sat Jun 16 18:04:13 +0000 2007
  author_email: geir@aalberg.com
  author_url: ""
- author: faryzhijcherteg
  date: Sat Jan 19 02:17:17 +0000 2008
  id: 21823
  content: |
    <p>Lafarge to buy Orascom Cement for $12.8 bln <a href="http://34.x008.in/14.html" rel="nofollow">link</a></p>

  date_gmt: Sat Jan 19 02:17:17 +0000 2008
  author_email: jomorr@kokpitjx.de
  author_url: http://00.x008.in/16.html
author: Tom
title: DRYML, meet ActiveRecord
excerpt: |
  DRYML has a nifty little feature called *implicit context*. Despite the title of this post, this feature has got nothing directly to do with ActiveRecord. Implicit context makes it a lot easier to populate your pages with data, and in Rails that means ActiveRecord models. So this post is about getting your models into your views.
  
  

published: true
tags: []

date: 2006-11-11 10:42:36 +00:00
categories: 
- Documentation
author_email: tom@hobocentral.net
wordpress_url: http://hobotek.net/blog/2006/11/11/dryml-meet-activerecord/
author_url: http://www.hobocentral.net
status: publish
---
DRYML has a nifty little feature called *implicit context*. Despite the title of this post, this feature has got nothing directly to do with ActiveRecord. Implicit context makes it a lot easier to populate your pages with data, and in Rails that means ActiveRecord models. So this post is about getting your models into your views.


<a id="more"></a><a id="more-10"></a>

For those that want all the details, we'll do the whole thing from scratch: create the Rails app, install Hobo, create some models... For those who don't, you can skip the stuff between the two rules

---

### `<skippable>`

Let's get started with a fresh Rails app and get Hobo installed:

    $ rails hobo_demo
	$ mysqladmin create hobo_demo_development
	$ cd hobo_demo
	$ ./script/plugin install svn://hobocentral.net/hobo/trunk
	$ ./script/generate hobo
	
...then create some models, populate with some data. Hmm, I guess we need to pick some kind of domain to model. How about a simple to-do list app? [Groan] OK but it's a clich&Atilde;&copy; for a reason - simple, familiar... Let's move on :-)

To start we'll just have TodoLists and Tasks, where a TodoList has many Tasks.

    $ ./script/generate model todo_list
    $ ./script/generate model task

Now let's get those tables created -- edit the two migrations so the create tables look like these:

    create_table :todo_lists do |t|
      t.column :name, :string
    end

    create_table :tasks do |t|
      t.column :name, :string
      t.column :todo_list_id, :integer
    end

Declare the relationships in the models:

#### app/models/task.rb

    class Task < ActiveRecord::Base
	  belongs_to :todo_list
	end

#### app/models/todo_list.rb

	class TodoList < ActiveRecord::Base
	  has_many :tasks
	end

Then just a quick

    $ rake migrate

...and we're good to go. Gotta love Rails eh?

If you're following along you might want to pause here to get some data in there. Personally I'd use `./script/console` but you might prefer scaffolding, your MySQL GUI...

### `</skippable>`

---

(Welcome back to the skimmers :-) What you missed: we're working with a skeleton app with a `TodoList` model that has a name and `has_many :tasks` and a `Task` model that has a name and `belongs_to :todo_list`)

OK lets create a view of a single list

    $ ./script/generate controller todo_lists

#### `app/controllers/todo_lists_controller.rb`

    class TodoListsController < ApplicationController

	  def show
	    @this = TodoList.find(params[:id])
	  end

	end
	
`@this`?? That's kind of unconventional isn't it? The implicit context in a DRYML template is held in a variable `this` (actually it's not a variable, it's a method, but don't worry about it). To set the context for the whole page, we assign to `@this` in the controller.

Now the view. We can access the context as `this` in a regular ERB scriptlet.

#### app/views/todo_lists/show.dryml

    <h1>Todo List: <%= this.name %></h1>

	<ul>
	  <% this.tasks.each do |task| %>
	    <li><%= task.name %></li>
	  <% end %>
	</ul>

Now lets clean that up with some DRYML goodness. First we'll use `<repeat>`, which is part of the core taglib (available everywhere) instead of that loop. Let's see the code first, and then go through how it works

#### app/views/todo_lists/show.dryml

    <h1>Todo List: <%= this.name %></h1>

	<ul>
	  <repeat attr="tasks">
	    <li><%= this.name %></li>
	  </repeat>
	</ul>

Starting to look cleaner! Two things to notice. First: we gave `repeat` just the name of the attribute we were interested in (`tasks`). It implicitly found that collection in the current context (the current value of `this`). We are therefore iterating over `this.tasks`. In other words, you just say "how to get there from here": the page is displaying a `TodoList`, so iterate over the `tasks`. Nice and easy.

(Aside: We use the term 'attribute' here in the Ruby sense, as in, say, `attr_reader`. Unfortunately, in a mark-up setting that term conflicts confusingly with XML attributes. We might change this name. What else could you call the attributes of a model object? Properties? Fields?)

The second thing to notice is that *inside* the repeat, we're using `this` again, only now it refers to the individual task. `repeat` sets the context to each item in the collection in turn. If you've ever worked with XSL-T, this idea may be familiar.

Notice now that both the scriptlets that display the name are identical. Bad programmer! *Don't* repeat yourself! No problemo:

#### app/views/todo_lists/show.dryml

    <def tag="name"><%= this.name %></def>

	<h1>Todo List: <name/></h1>

	<ul>
	  <repeat attr="tasks">
	    <li><name/></li>
	  </repeat>
	</ul>
	
Note that the `name` tag declares `this` as an attribute. Any tag that's going to use `this` should declare so in this way, even though we never actually give `this`
 as an attribute when we use the tag.

Next we should move that `<def>` to the global taglib (application.dryml, which lives in app/views/hobolib). While we're at it, `<ul>/<li>` lists tend to crop up all over the place, right? Bad programmer! *Don't* repeat yourself! Let's make a tag for those lists.
	
#### app/views/hobolib/application.dryml

	<def tag="name"><%= this.name %></def>
	
	<def tag="ul_for">
	  <ul>
		<repeat>
		  <li><tagbody/></li>
		</repeat>
	  </ul>
	</def>
	
The `ul_for` tag expects the context to be a collection. Here's how we use it:

#### app/views/todo_lists/show.dryml

	<h1>Todo List: <name/></h1>

	<ul_for attr="tasks"><name/></ul_for>

You can't ask for much more concise than that! Let's now improve things a bit. Suppose the individual tasks were each going to have their own page in this app, perhaps displaying notes and such-like. In that case, we'd like that list to be a list of links. Here's a handy tag that makes it easy to create a link to anything with a name:

#### app/views/hobolib/application.dryml (fragment)

	<def tag="name_link">
	  <%= link_to this.name,
	              :controller => this.class.name.underscore.pluralize,
	              :action => 'show',
	              :id => this %>
	</def>
	
There's a little reflective name-mangling magic going there, but the beauty is that we can forget about that and just use the `name_link` tag. The change to our page to add our links is trivial:

#### app/views/todo_lists/show.dryml

	<h1>Todo List: <name/></h1>

	<ul_for attr="tasks"><name_link/></ul_for>

And we're done. For today at least. Now -- bearing in mind that this page is dramatically simpler than a typical page in a production app -- let's just compare:
	
#### Traditional ERB

    <h1>Todo List: <%= @todo_list.name %></h1>

	<ul>
	  <% @todo_list.tasks.each do |task| %>
	    <li>
	      <%= link_to task.name, :controller => "tasks",
	                             :action => "show",
                                 :id => task %>
        </li>
	  <% end %>
	</ul>

...to...

#### DRYML

	<h1>Todo List: <name/></h1>

	<ul_for attr="tasks"><name_link/></ul_for>
	
I don't know about you but to me that's like a breath of fresh air. Now imagine that clarity in the context of a vastly more complex production app, and you might see what Hobo is all about.

(And we *still* haven't shown you the best bit...)
