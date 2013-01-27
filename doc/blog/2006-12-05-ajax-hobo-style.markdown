--- 
wordpress_id: 14
author_login: admin
layout: post
comments: 
- author: Sr&Auml;&lsquo;an Prodanovi&Auml;&Dagger;
  date: Tue Dec 26 13:10:09 +0000 2006
  id: 34
  content: |
    <p>Interesting. The last dryml makes it hard to distinguish HTML from proprietary code though.
    Also, be careful when wrapping block level elements. To remain valid, that span must turn to div :-)</p>

  date_gmt: Tue Dec 26 13:10:09 +0000 2006
  author_email: srdjan.prodanovic@gmail.com
  author_url: http://www.some1else.org
- author: Tom
  date: Thu Dec 28 08:44:49 +0000 2006
  id: 44
  content: |
    <p>The fact that defined tags look the same as HTML primitives is deliberate -- think of a GUI library where you have classes that provide user-interface widgets like buttons, menus etc. If you create your own custom widget, you want it to blend right in with the existing ones.</p>
    
    <p>Then again, it would be pretty easy to customise the HTML mode of your editor to use a different colour for HTML tags.</p>
    
    <p>Good point about the <code><span></code> tag. Unfortunately the part mechanism doesn't know what you're going to put inside the part, so it doesn't know whether to use a <code>span</code> or  a <code>div</code>.</p>
    
    <p>There's a change in the part mechanism on the way that might  also offer a fix to this problem.</p>

  date_gmt: Thu Dec 28 08:44:49 +0000 2006
  author_email: tom@livelogix.com
  author_url: http://
- author: haakon
  date: Fri Jan 05 11:29:10 +0000 2007
  id: 61
  content: |
    <p>Minor nit, but the line
        <% form<em>remote</em>tag :url => "/tasks", :method => :post do %></p>
    
    <p>should read </p>
    
    <pre><code><% form_remote_tag :url => "/tasks/create", :method => :post do %>
    </code></pre>

  date_gmt: Fri Jan 05 11:29:10 +0000 2007
  author_email: ""
  author_url: ""
- author: Tom
  date: Fri Jan 05 11:35:18 +0000 2007
  id: 62
  content: |
    <p>haakon - this is the way things work with RESTful routes. The fact that it's an HTTP POST means the <code>create</code> action will be invoked at the <code>/tasks</code> url. A GET to the same url would invoke the <code>index</code> action.</p>

  date_gmt: Fri Jan 05 11:35:18 +0000 2007
  author_email: tom@livelogix.com
  author_url: http://
- author: Daniel Schierbeck
  date: Fri Jan 05 11:39:44 +0000 2007
  id: 63
  content: |
    <p>The is very nice indeed,but as     Sr&Auml;&lsquo;an pointed out, the custom tags are hard to distinguish from the HTML. Why not use a qualified name? like <code><dry:form></code>. That would also make the tags more declarative.</p>

  date_gmt: Fri Jan 05 11:39:44 +0000 2007
  author_email: daniel.schierbeck@gmail.com
  author_url: ""
- author: Tom
  date: Fri Jan 05 11:53:47 +0000 2007
  id: 64
  content: |
    <p>As I said above, I <em>want</em> the custom tags to look like HTML. In my Hobo apps, my views contain 80% -- 90% Hobo tags, having <code>dry:</code> or even just <code>d:</code> in front of them all would be pretty grim.</p>
    
    <p>I really don't see a problem. In a Ruby class, how do you distinguish between that class's own methods and inherited methods?</p>
    
    <p>Once the module system is working, you can if you want keep all your tags in a module, and then they look like</p>
    
    <pre><code><m.tag ... />
    </code></pre>
    
    <p>It deliberately uses a dot rather than a colon, as discussed in <a href="/forum/viewtopic.php?p=77" rel="nofollow">this thread</a>.</p>
    
    <p>I'm not quite sure what you mean by "more declarative". Because you can re-use the "simple" names like <code>form</code> and <code>table</code>?</p>

  date_gmt: Fri Jan 05 11:53:47 +0000 2007
  author_email: tom@livelogix.com
  author_url: http://
- author: haakon
  date: Fri Jan 05 11:56:22 +0000 2007
  id: 65
  content: |
    <p>Ah, forgive my ignorance about the new restful stuff.  I hadn't restarted the server after putting this line in the right spot in the routes.rb:</p>
    
    <pre><code>map.resources :todo_lists, :tasks
    </code></pre>
    
    <p>I also found that "include Hobo::AjaxController" failed with an "Uninitialized Constant".</p>
    
    <p>My slow understanding aside, this all looks extremely cool.  I like how easy it is to define the tags, and getting an app with users / authentication baked in makes tons of sense.  You are taking a good page from the Django book.</p>

  date_gmt: Fri Jan 05 11:56:22 +0000 2007
  author_email: ""
  author_url: ""
- author: Tom
  date: Fri Jan 05 12:00:26 +0000 2007
  id: 66
  content: |
    <p>haakon - you've hit a problem with this post getting out of date with respect to the code. Try</p>
    
    <pre><code>hobo_controller
    </code></pre>
    
    <p>Instead of</p>
    
    <pre><code>include Hobo::AjaxController
    </code></pre>

  date_gmt: Fri Jan 05 12:00:26 +0000 2007
  author_email: tom@livelogix.com
  author_url: http://
- author: Extefearady
  date: Sat Jan 05 15:59:00 +0000 2008
  id: 20422
  content: |
    <p>You hit a sore point. 
    Extrefox</p>

  date_gmt: Sat Jan 05 15:59:00 +0000 2008
  author_email: extefearady@mymail-in.net
  author_url: http://lazer-stop-smoking.longeared.com
- author: Joseph
  date: Fri Jan 11 11:33:40 +0000 2008
  id: 21222
  content: |
    <p>Is there a reason i am getting invalid tag on hobo<em>rapid</em>javascripts?</p>

  date_gmt: Fri Jan 11 11:33:40 +0000 2008
  author_email: online@resonatinglight.com
  author_url: ""
- author: Brandon
  date: Mon Jan 28 17:41:54 +0000 2008
  id: 22854
  content: |
    <p>Tom: I wholeheartedly agree with you about making the dryml look like HTML.  It <em>might</em> make sense to use <namespace:tagname> if lots of us share tags and we want to avoid name collisions, but this is not going to be a problem between the base DRYML tags and HTML.  And I would assume that any developer worth their salt knows all the HTML tags and won't have any trouble at all know which ones are therefore DRYML.</p>
    
    <p>I <em>suppose</em> if enough people wanted it, it probably wouldn't be hard for you to add the ability to use a verbose syntax, such as <dry:page>, but I for one would never use it.</p>

  date_gmt: Mon Jan 28 17:41:54 +0000 2008
  author_email: brandon.zylstra@gmail.com
  author_url: http://www.zebrafishstudios.com
- author: Chihyung Song
  date: Wed Feb 13 13:47:30 +0000 2008
  id: 25167
  content: |
    <p>Can I you jQuery with Hobo?
    I'm using jRails so basic rails ajax helpers are works well.</p>
    
    <p>But If Hobo is using prototype and script.aculo.us internally, I can't(?) use jQuery(or must use jQuery with prototype together).</p>

  date_gmt: Wed Feb 13 13:47:30 +0000 2008
  author_email: scroco@naver.com
  author_url: http://www.innomovelab.com
- author: Brandon
  date: Mon Mar 31 09:08:13 +0000 2008
  id: 30344
  content: |
    <p>@Chihyung: actually jQuery is designed to make it easy to use alongside prototype and scriptaculous.  There's info on their site about how to do this.</p>

  date_gmt: Mon Mar 31 09:08:13 +0000 2008
  author_email: brandon.zylstra@gmail.com
  author_url: http://www.zebrafishstudios.com
- author: victor
  date: Thu May 29 16:35:02 +0000 2008
  id: 36029
  content: |
    <p>Is there a way to use hobo and jQuery and remove all references to all prototype/script.aculo.us stuff? Thanks in advance.</p>

  date_gmt: Thu May 29 16:35:02 +0000 2008
  author_email: mingde.hong@gmail.com
  author_url: ""
- author: Tom
  date: Thu May 29 22:45:53 +0000 2008
  id: 36068
  content: |
    <p>Victor -- not really, not an easy way. But we're thinking of moving to jQuery anyway.</p>

  date_gmt: Thu May 29 22:45:53 +0000 2008
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: victor
  date: Fri May 30 14:18:22 +0000 2008
  id: 36136
  content: |
    <p>Tom - thanks for responding. How soon will you move? It seems all js stuff are in one file hobo_rapid.js? It will be good for a lot of people since jQuery are getting so popular.</p>

  date_gmt: Fri May 30 14:18:22 +0000 2008
  author_email: mingde.hong@gmail.com
  author_url: ""
- author: Tom
  date: Fri May 30 14:38:01 +0000 2008
  id: 36138
  content: |
    <p>Victor -- I really have no idea when this might happen. There are so many other priorities that it might not happen for a good while, or even at all. Why don't you have a go at moving hobo-rapid.js in that direction yourself?</p>

  date_gmt: Fri May 30 14:38:01 +0000 2008
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: victor
  date: Sat May 31 14:19:16 +0000 2008
  id: 36238
  content: |
    <p>Tom - I don't understand most of the stuff in hobo-rapid.js. If I can , I will let you know.</p>

  date_gmt: Sat May 31 14:19:16 +0000 2008
  author_email: mingde.hong@gmail.com
  author_url: ""
author: Tom
title: Ajax, Hobo Style
excerpt: |+
  OK, next up we're going to see what Hobo brings to the Ajax table. In a nutshell -- the ability to refresh fragments of a page without pushing them out into separate partial files. To see how that works, let's knock up a quick demo application.
  
  
published: true
tags: []

date: 2006-12-05 17:44:22 +00:00
categories: 
- Documentation
author_email: tom@hobocentral.net
wordpress_url: http://hobotek.net/blog/2006/12/05/ajax-hobo-style/
author_url: http://www.hobocentral.net
status: publish
---
OK, next up we're going to see what Hobo brings to the Ajax table. In a nutshell -- the ability to refresh fragments of a page without pushing them out into separate partial files. To see how that works, let's knock up a quick demo application.


<a id="more"></a><a id="more-14"></a>

We're going to build on the [todo-list demo app](/blog/2006/11/11/dryml-meet-activerecord/) from an earlier post, so if you want to follow along you should start with that post. Just to recap, the app is trivially simple, consisting of a `TodoList` model which `has_many :tasks` and a `Task` model which `belongs_to :todo_list`. We created a controller for to-do lists with just a `show` action, and we implemented a DRYML view for that action.

We're going to add an ajaxified "New Task" form on that same page. Let's do the back-end first, so that it's possible to create tasks. We'll start by being good modern Rails citizens, and switch to RESTful routing. Add this line to `routes.rb`:

	map.resources :todo_lists, :tasks

Now create our controller

    $ ./script/generate controller tasks

#### app/controllers/tasks_controller.rb

    class TasksController < ApplicationController

	  def create
	    Task.create(params[:task])
	  end

	end

Now we'll add a simple ajax form to `todo_lists/show.dryml`. We'll use the familiar `remote_form_tag` helper. We'll use raw HTML for the form controls, just to be clear about exactly what's going on, What we won't do, for now, is deal with refreshing the page.

#### app/views/todo_lists/show.dryml

	<head>
	  <%= javascript_include_tag :defaults %>
	</head>
	<body>
	  <h1>Todo List: <name/></h1>

	  <ul_for attr="tasks"><name_link/></ul_for>

	  <% form_remote_tag :url => "/tasks", :method => :post do %>
	    <input type="hidden" name="task[todo_list_id]"
	                         value="<%= this.id %>"/>
	    <input type="text" name="task[name]"/>
	    <input type="submit" value="New Task"/>
	  <% end %>
	</body>
	
That should work as is, although you'll have to manually reload the page to see any new tasks. Let's fix that, Hobo style.

With DRYML, any fragment of the page can be marked as a *part*. A part can be rendered separately from the rest of the page, just like a partial. To create a part, just give any element a `part_id`. For this demo we'll add it to the `ul_for` tag.

#### app/views/todo_lists/show.dryml

	<head>
	  <%= javascript_include_tag :defaults %>
	</head>
	<body>
	  <h1>Todo List: <name/></h1>

	  <ul_for attr="tasks" part_id="task_list"><name_link/></ul_for>

	  <% form_remote_tag :url => "/tasks", :method => :post do %>
	    <input type="hidden" name="task[todo_list_id]"
	                         value="<%= this.id %>"/>
	    <input type="text" name="task[name]"/>
	    <input type="submit" value="New Task"/>
	  <% end %>
	</body>
	
Having done that, reload the page in the browser and have a look at the source. You should see something like (with bits cut out for the sake of clarity):

#### Generated HTML Source

	<head>
	  <!-- A BUNCH OF JAVASCRIPT INCLUDES -->
	</head>
	<body>
	  <h1>Todo List: Launch Hobo!</h1>

	  <span id='task_list'>
	  <ul>
		<!-- A BUNCH OF LIST ITEMS -->
	  </ul>
	  </span>

	<!-- THE FORM HERE -->
	</body>

	<script>
	var hoboParts = {}
	hoboParts.task_list = 'todo_list_1'
	</script>
	
The important bits to note are the `<span>` with the same ID as our part, and the JavaScript snippet at the end. The JavaScript was generated by Hobo to keep track of which model objects are displayed in which parts.
	
We can ask for a part to be updated, simply by adding a few parameters to the request. Hobo provides tags to make this blissfully easy, and we'll have a look at those shortly. For now though, just to show there's no magic going on, we'll add them by hand using hidden fields.

The parameters we need are:

  * `part_page`: The path of the current page template, e.g. "todo_lists/show". (Future development: maybe we can do away with this and use the HTTP referrer instead)

  * `render[][part]`: The name of the part we'd like to refresh. e.g. `task_list`

  * `render[][object]`: The "DOM ID" of the "context object" for that part. e.g. `todo_list_1`

Update the form as follows:

#### app/views/todo_lists/show.dryml (fragment)

	<% form_remote_tag :url => "/tasks", :method => :post do %>
	  <input type="hidden" name="task[todo_list_id]"
	                       value="<%= this.id %>"/>
	  <input type="text" name="task[name]"/>
	  <input type="submit" value="New Task"/>

	  <input type="hidden" name="part_page" value="todo_lists/show"/>
	  <input type="hidden" name="render[][part]" value="task_list"/>
	  <input type="hidden" name="render[][object]"
	                       value="todo_list_<% this.id %>"/>
	<% end %>
  
We now need to upgrade our controller to recognize this "render request". That just requires including a module, and calling one method:

#### app/controllers/tasks_controller.rb

	class TasksController < ApplicationController

	  include Hobo::AjaxController

	  def create
	    this = Task.create(params[:task])
	    hobo_ajax_response(this)
	  end

	end
	
The `hobo_ajax_response` method needs a page context. As you can see we're passing in the object just created.

You should now have a working ajax "New Task" feature.

The code might work but it's pretty ugly (heh). Let's clean it up using the appropriate Hobo tags. The tags we need come from a tag library that's provided with Hobo -- Hobo Rapid. Hobo Rapid is a very general purpose tag library that makes it extremely quick and easy to do the bread-and-butter stuff: links, forms, ajax...

We'll look at Hobo Rapid in more detail in another post. For now we'll see how to pretty-up our ajax demo.

To include Hobo Rapid in your application:

    $ ./script/generate hobo_rapid

Then edit your view to look as follows:

#### app/views/todo_lists/show.dryml

	<head>
	  <%= javascript_include_tag :defaults %>
	  <hobo_rapid_javascripts/>
	</head>
	<body>
	  <h1>Todo List: <name/></h1>

	  <ul_for attr="tasks" part_id="task_list"><name_link/></ul_for>

	  <create_form attr="tasks" update="task_list">
	    <edit attr="name"/>
	    <submit label="New Task"/>
	  </create_form>
	</body>
	
Yep - that's it :-) Try it -- it should be working.

The `<create_form>` tag can be read as: Include a form which will first create an object in the collection "tasks" of the current context (the `TodoList`), and then update the "`task_list`" part. Note that you don't need to say anything about *how* to update that part. Hobo knows.

`<booming-voice>`AND NOW [drum-roll] THE GRAND FINALE...`</booming-voice>`
	
How easy is it to update multiple parts in one go? For example, suppose the page had a count of the number of tasks -- that would need updating too. We'll use another handy little tag from Hobo Rapid: `<count/>` (Note this tag doesn't have any special ajax support. We could have used a regular ERB scriptlet and the ajax would still work). And for bonus marks, we'll DRY up all those `attr='tasks'` using a `<with>` tag, which just changes the context.

#### app/views/todo_lists/show.dryml

	<head>
	  <%= javascript_include_tag :defaults %>
	  <hobo_rapid_javascripts/>
	</head>
	<body>
	  <h1>Todo List: <name/></h1>

	  <with attr="tasks">
	    <ul_for part_id="task_list"><name_link/></ul_for>
	    <p><count part_id="task_count"/></p>

	    <create_form update="task_list, task_count">
	      <edit attr="name"/>
	      <submit label="New Task"/>
	    </create_form>
	  </with>
	</body>

To update multiple parts, just list the part names in the update attribute.

What more could you ask for? :-)
