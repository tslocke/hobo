# Hobo Tutorial -- Agility

In this tutorial we'll be creating a simple "Agile Development" application -- _Agillity_. The application tracks projects which consist of a number of user stories. Stories have a status (e.g. accepted, under development...) as well as a number of associated tasks. Tasks can be assigned to users, and each user can see a heads-up of all the tasks they've been assigned to on their home page.

This is a bit of an in-at-the-deep-end tutorial -- we build the app the way you would assuming you had already got the hang of the way Hobo works. In the later stages new concepts start coming thick and fast. The goal here is to show you what's possible, and give you a flavour of Hobo-style application development, rather that to provide detailed background on how everything workds. Don't worry about it, it's fun!


# Part 1 -- Getting Started


## Introduction to Hobo

Hobo is a bunch of extensions to Ruby on Rails that are designed to make developing any kind of web application a good deal faster and more fun. This tutorial is designed to show off Hobo's ability to get quite sophisticated applications up and running extremely quickly. 

While Hobo is very well suited to this kind of throw-it-together-in-an-afternoon application, it is equally useful for longer term projects, where the end result needs to be very meticulously crafted to the needs of its users. Hopefully the tutorial will give you an idea of how to take your Hobo/Rails application much further.µ

For more info on Hobo please see [hobocentral.net](http://hobocentral.net)

## Before you start

You'll need the following installed on your computer:

 * A working Ruby on Rails setup

We're assuming you know at least the basics of Rails. If not, you should probably work through a Rails tutorial before attempting this one.

Also:

 * The HoboSupport gem (`gem install hobosupport`)

And finally, although Hobo is in fact a group of Rails plugins, it is also available as a gem which gives you the useful `hobo` command:

 * Hobo! (`gem install hobo`)

Let's get started!

## Create the app

The `hobo` command is like the Rails command, it will create a new blank Rails app that is set-up for Hobo. It's the equivalent of running the `rails` command, installing a few plugins and running a few generators. 

    $ hobo agility

With Hobo, you get a bare-bones application immediately. Let's run it:

    $ cd agility
    $ ./script/server

(Tip: Windows users: 1. Really? 2. Whenever you see `./script/something`, you will need to instead do `ruby script/something`)

If you try and sign up you'll see that part is not working yet - because we haven't created the `users` table. There's a good reason why the `hobo` command doesn't do that automatically but we'll gloss over that for now. To create the table, use Hobo's migration generator:

(Tip: leave the server running and open a new terminal window)

    $ ./script/generate hobo_migration

Respond to the prompt with `m` and then give the migration a name

You should now be able to sign up. By default, Hobo gives administrator status to the first user that signs in. (The concept of an administrator is built into Hobo, but if it doesn't make sense for your application it's trivial to do away with).

In the next section we'll be starting to flesh out the basics of the app.


## Interface first Hobo style

The next thing we're going to do is sketch out our models. If you're a fully signed up devotee of the Rails Way,  that should ring a few alarm bells. What happened to [interface first][]? We do believe in Interface First. Absolutely. But for Hobos, interface first means first priority, not first task. 

[Interface First]: http://gettingreal.37signals.com/ch09_Interface_First.php

The reason is, we think we've rewritten this rule:

> Design is relatively light. A paper sketch is cheap and easy to change. html designs are still relatively simple to modify (or throw out). That's not true of programming. Designing first keeps you flexible. Programming first fences you in and sets you up for additional costs.

In our experience, experimenting with an app by actually building a prototype with Hobo, is _far_ quicker than creating html designs. How's that for getting real? We could waffle for a good while on this point, but that's probably best saved for a blog post. For now let's dive in and get this app running.


## The models

Let's review what we want this app to do:

 * Track multiple projects
 * Each having a collection of stories
 * Stories are just a brief chunk of text
 * A story can be assigned a current status and a set of outstanding tasks
 * Tasks can be assigned to users
 * Users can get an easy heads up of the tasks they are assigned to

Sounds to me like we just designed our models. We'll need:

 * Project (with a name)
	has many stories
	
 * Story (with a title, description and status)
	belongs to a project
	has many tasks
	
 * Task (with a description)
	belongs to a story
	has many users (through task-assignments)
	
 * User (we'll stick with the standard fields provided by Hobo)
	has many tasks (through task-assignments)
	
Hopefully the connection between the goal and those models is clear. If not, you'll probably find it gets easier once you've done it a few times. Before long you'll be throwing models into your app without even stopping to write the names down. Of course -- chances are you've got something wrong, made a bad decision. So? Just throw them away and create some new ones when the time comes. We're sketching here!

Here's how we create these with a Hobo generator:

	$ ./script/generate hobo_model_resource project name:string
	$ ./script/generate hobo_model_resource story   title:string body:text status:string
	$ ./script/generate hobo_model_resource task    description:string
	$ ./script/generate hobo_model_resource task_assignment
	
The field declarations have been created by the generators, but not the associations. Go ahead and edit the associations in the models to reflect the description above. Don't forget

 * `:dependent => :destroy` declarations where needed (probably all the `has_many` associations)
 * `belongs_to :user` and `belongs_to :task` on TaskAssignment

Now watch how Hobo can create a single migration for all of these:

	$ ./script/generate hobo_migration
	
Note: Hobo's automatic routing happens when the application starts. You'll need to stop and start the web-server in order for the application to reflect all these new models and controllers.
	
Fire up the app. It's kind of a weird UI at this stage, but we do actually have a working application. Make sure you are logged in as the user who signed up first, and spend a few minutes populating the app with projects, stories and tasks. 

With some more very simple changes, and without even touching the views, we can get surprisingly close to a decent UI.


# Part 2 -- Removing actions

By default Hobo has given us a full set of restful actions routes for every single model/controller pair. Many of these routes are inappropriate for our application. For example, why would be want an index page listing every Task in the database? We only really want to see tasks listed against stories and users. We need to disable the routes we don't want.

There's an interesting change of approach here that often crops up with Hobo development. Normally you'd expect to have to build everything yourself. With Hobo, you often get given everything you want and more besides. Your job is to take away the parts that you *don't* want.

Taking that example -- removing the index action from TasksController, here's how we'd do that. in `app/controllers/tasks_controller.rb`, change 

	auto_actions :all
	
To

	auto_actions all, :except => :index
	
Restart the server and you'll notice that Tasks has been removed from the main nav-bar. Hobo's generic pages (which are just clever defaults that you can override as much or as little as you like) know how to adapt to changes in the actions that you make available.

Here's another similar trick. Browse to one of your stories. See that "New Task" link at the bottom? That's kind of clunky for the user -- it would be much nicer if the new task form (which only has one field after all) was in-line in the same page. Edit the `auto_actions` declaration in `stories_controller` to look like this:

	auto_actions :all, :except => :new_task
	
Restart the server and refresh the story page. Ta da!
	
So far we've seen the black-list style where you list what you *don't* want. There's also white-list style where you list what you do want, e.g.

    auto_actions :index, :show

There's also a handy shortcut to get just the read-only routes (i.e. the ones that don't modify the database)

	auto_actions :read_only
	
The opposite is handy for things that are manipulated by ajax but never viewed directly:

	auto_actions :write_only

Work through your controllers and have a think about which actions you want. You might end up with something like:

 * Projects: `:all`
 * Stories `:write_only, :show, :edit, :new`
 * Tasks: `:write_only, :edit`
 * TaskAssignments: `:write_only` (or maybe we don't even need this controller?)

Have a play with the application with this set of actions in place (don't forget to restart the server). Looking pretty good!


# Part 3 -- Permissions

So far we've only done two things to are app: created some models & controllers, and specified which actions are available. There's one more thing we typically do when creating a new Hobo app, before we even touch the view layer. We modify permissions in the model layer.

## Introduction to permissions

You might have noticed methods like this one in the generated models:

	def creatable_by?(user)
	  user.administrator?
	end
{: .ruby}

That tells Hobo that only administrators are allowed to create this kind of model. Before every create, update and delete (destroy) operation, Hobo calls one of these methods passing the current user. Only if the method returns true is the operation allowed to continue.

Furthermore, the *Rapid* DRYML tag library (that's the part of Hobo that creates the UI automatically for you) knows how to interrogate the models permissions and adapt accordingly. For example, Rapid won't generate a "New Project" link if the current user does not have permission to create a project.

You can see this feature in action by logging out and browsing around the app. You'll notice that all the 'new' and 'edit' links have disappeared. If you experiment by change `user.administrator?` to `true` in some permission methods, you'll see operations start to become available.

## Customize the permissions in Agility

For the purposes of the tutorial you can make your own decisions about who should be allowed to do what. In the spirit of agile methods, we probably don't want to lock things down too much. Here's a suggestion:

 * Only administrators can create, edit and delete projects
 * Stories and tasks are open to change by all logged in users.

A permission that says "only logged in users" looks like this:

	def creatable_by?(user)
	  !user.guest?
	end
	
You might need to sign up a new user so you've got a non-admin to test things with.

Tip: Hobo provides an easy way to switch user so you can see how things look to different people. Just visit (substituting `localhost` and `3000` as appropriate):

	http://localhost:3000/dev/set_current_user?name=Fred
	
*Not available in production mode!* Once you've typed this once, your can use your browser's history completion to quickly flick between different users.

## Permissions for data integrity

The permissions system is not just for opening operations for some users but not others, it is also used to prevent operations that don't make sense for anyone. For example, you've probably noticed that the default UI allows stories to be moved from one project to another. That's probably not a sensible operation for *anyone* to be doing. We can prevent it with this method in `story.rb`:

	def updatable_by?(user, new)
	  !user.guest? && same_fields?(new, :project)
	end

Note that the `updatable_by?` method is called with `self` in the current state, and the `new` argument is an instance of the same class in the proposed new state. The `same_fields?` helper is a convenient way to assert that certain fields have not been changed. There's also `only_changed_fields?` which is more convenient if you want to prevent changes to all but a certain few fields.

Rapid will respond to this change by removing the project selector from the edit-story page.

Make a similar change to prevent tasks being moved from one story to another.

## Edit permission

One permission method that is not present by default is`editable_by?`. This method tells Rapid if the user is allowed to see an edit control for a given field. The reason this method is often omitted is that Hobo does a pretty good job of figuring out edit permission automatically from the rules you've given for update permission (if you think about it, these are two sides of the same coin).

Sometimes however, Hobo can't figure out edit permission unless you tell it explicitly. A common example is `has_many` associations. If you don't specify edit permission for these, Hobo just defaults to not-editable. That's why, up until now, the task assignments are completely absent from the UI. We can fix that by adding this to `task.rb`:
	
	def users_editable_by?(user)
      !user.guest?
    end
  
We also need to tell Hobo that it's ok for the TaskAssigment objects can be created and deleted automatically as a side effect of saving changes to the Task. Change the `has_many :users` declaration in `task.rb` to:

	has_many :users, :through => :task_assignments, :managed => true
  
You should now get a nice javascript powered control for assigning users in the edit-task page.


# Part 4 -- Customizing views

It's pretty surprising how far you can get without even touching the view layer. That's the way we like to work with Hobo - get the models and controllers right and the view will probably get close to what you want. From there you can override just those parts of the view that you need to.

Hobo uses the DRYML template language for the views. DRYML is a tag based template language -- it allows you to define and use your own tags right alongside the regular HTML tags. Tags are like helpers, but a lot more powerful. DRYML is quite different to other tag-based template languages, thanks to features like the implicit context and nestable parameters. DRYML also an extension of ERB so you can still use the ERB syntax you're familiar with from Rails. 

DRYML is probably the single best part of Hobo. It's very good at high-level re-use because it allows you to make very focussed changes if a given piece of pre-packaged HTML is not *quite* what you want.

A full coverage of DRYML is well beyond the scope of this tutorial. Instead we're going to take a few specific examples of changes we'd like to make to Agility, and see how they're done.


## Add assigned users to the tasks

At the moment, the only way to see who's assigned to a task is to click the task's edit link. Not good. Let's add a list of the assigned users to each task when we're looking at a story.

DRYML has a feature called *polymorphic tags*. These are tags that are defined differently for different types of object. Rapid makes use of this feature with a system of cards. The tasks that are displayed on the story page are rendered by the `<card>` tag that Rapid provides. You can define custom cards for particular models. Furthermore, if you call `<base-card>` you can define your card by tweaking the default, rather than starting from scratch. This is what DRYML is all about. It's like a smart-bomb, capable of taking out little bits of unwanted HTML with pin-point strikes and no collateral damage.

The file `app/views/taglibs/application.dryml` is a place to put tag definitions that will be available throughout the site. Add this definition to that file:

	<def tag="card" for="Task">
	  <base-card>
	    <creation-details: replace>
	      <div class="users">
	        Assigned users: <repeat:users join=", "><a/></repeat><else>None</else>
	      </div>
	    </creation-details:>
	  </base-card>
	</def>
	
OK there's a lot of new concepts thrown at you at once there :-) 
	
First off, refresh the story page. You'll see that in the cards for each task, we've replaced the creation time and date (which we don't really want to see) with the list of assigned users. The users are clickable - they link to each users home page (which doesn't have much on it at the moment).

The card that we defined calls `<base-card>` which gives us the default card from Rapid, but it overrides some of the content using DRYML's named parameters (`<creation-details:>`). The `replace` attribute means we want to remove the creation-details entirely. For the replacement we insert a `<div>` and use the `<repeat>` tag to insert the list of links. Some things to note:
	
 * The `<repeat>` tag provides a `join` attribute which we use to insert the commas
 * The link is created with a simple empty `<a/>`. It links to the 'current context' which, in this case, is the user.
 * The `:users` in `<repeat:users>` switches the context. It selects the `users` association of the story.
 * DRYML has a multi-purpose `<else>` tag. When used with repeat, it provides a default for the case when the collection is empty.
	
	
## Add a task summary to the user's home page

Now that each task provides links to the assigned users, the user's page is looking rather bare. What we'd like to see there is a list of all the tasks the user has been assigned to. Having them grouped by story would be helpful too.

To achieve this we want to create a custom template for `users/show`. If you look in `app/views/users` you'll see that it's empty. When a page template is missing, Hobo tries to fall back on a defined tag. For a 'show' page, that tag is `<show-page>`. The Rapid library provides a definition of `<show-page>`, so that's what we're seeing at the moment. As soon as we create `app/views/users/show.dryml`, that file will take over from the generic `<show-page>` tag. Try creating that file and just throw "Hello!" in there for now. You should see that the user's show page now displays just "Hello" and has lost all of the page styling. 

If you now edit `show.dryml` to read "`<show-page>`" you'll see we're back where we started. The `<show-page>` tag is just being called explicitly instead of by convention. Now we can start to customize. Edit `show.dryml` to read:

	<show-page>
	  <content-body:>Hello</content-body:>
	</show-page>
	
The "Hello" message is back, but now it's embedded in the properly marked-up page. We've used the named parameter 'content-body', which is provided by the definition of `<show-page>` in Rapid.

Now let's get the content we're after - the user's assigned tasks, grouped by story. It's only five lines of markup:

	<show-page>
	  <content-body:>
	    <h2><Your/> Assigned Tasks</h2>
	    <repeat with="&this.tasks.group_by(&:story)">
	      <h3><a with="&this_key"/></h3>
	      <collection class="tasks"/>
	    </repeat>
	  </content-body:>
	</show-page>
	
Again - lots of new stuff there. Let's quickly run over what's going on

 * The `<Your>` tag is a handy little gadget. It outputs "Your" if the context is the current user, otherwise it outputs the user's name. You'll see "Your Assigned Tasks" when looking at yourself, and "Fred's Assigned Tasks" when you're looking at Fred.
	
 * We're using `<repeat>` again, but this time we're setting the context to the result of a Ruby expression (`with="&...expr..."`). 
	
 * The expression `this.tasks.group_by(&:story)` gives us the grouped tasks. (`this` will be the user, because we're on the `users/show` page)

 * We're repeating on a hash this time. Inside the repeat `this` (the implicit context) will be an array of tasks, and `this_key` will be the story. So `<a with="&this_key">` gives us a link to the story. 
	
 * The `<collection>` is used to render a collection of anything. By default it renders `<card>` tags in a `<ul>` list. Like `<card>` it can be overridden for specific types.
	
That's probably a lot to take in all at once -- the main idea here is to throw you in and give you an overview of what's possible. The [DRYML Guide][] will shed more light.

[DRYML Guide]: http://hobocentral.net/docs/dryml
	
## Improve the project page with a searchable, sortable table

The project page is currently workable, but we can easily improve it a lot. Rapid provides a tag `<table-plus>` which renders a table with support for sorting by clicking on the headings, and a built-in search bar for filtering the rows displayed. Searching and sorting are done server-side so we need to modify the controller as well as the view for this one.

As with the user's show-page, to get started put a simple call to `<show-page/>` in `app/views/projects/show.dryml`

The `<show-page>` tag has a concept of a "primary collection". This is the collection of cards that are rendered in the page. In this case Rapid has chosen the `stories` collection as the primary collection, which is why we see cards for all of the stories. The only thing we want to change at this stage is the way that collection is rendered, so we override the content of the `<primary-collection:>` parameter.

As an experiment, try this:

	<show-page>
	  <primary-collection:>
	    <repeat join=", "><a/></repeat>
	  </primary-collection:>
	</show-page>
	
You should now see that in place of the story cards, we now get a simple comma-separated list of links to the stories. Not what we want of course, but it illustrates the concept of overriding the primary-collection. We didn't even have to set the context because it's already set to the collection by `<how-page>`

Here's how we get the table-plus:

	<show-page>
	  <primary-collection:>
	    <table-plus fields="this, status">
	      <empty-message:>No stoires match your criteria</empty-message:>
	    </table-plus>
	  </primary-collection:>
	</show-page>
	
The `fields` attribute to `<table-plus>` lets you specify a list of fields that will become the columns in the table. We could have said `fields="title, status"` which would have given us the same content in the table, but by saying `this`, the first column contains links to the stories, rather than just the title as text.

Now for the controller side. Add a `show` method to `app/controllers/projects_controller.rb` like this:
	
	def	show
	  @project = find_instance
	  @project_stories = 
	    @project.stories.apply_scopes(:search    => [params[:search], :title],
	                                  :order_by  => parse_sort_param(:title, :status))
	end
	
[To do -- explain how that works!]
	
# Part 5 -- odds and ends

We're now going to work through some more easy but very valuable enhancements to the app. We're going to add

 * A menu for story statuses. The free-form text field is a bit poor after all. We'll do this first with a hard-wired set of options, and then add the ability to manage the set of available statuses.

 * Add filtering o stories by status to the project page

 * Drag and drop re-ordering of tasks. This effectively gives us prioritization of tasks.

 * Markdown or textile formatting of stories. This is implemented by changing *one symbol* in the source code.

Off we go.

## Story status menu.

We're going to do this in two stages - first a fixed menu that requires a source-code change to alter the available statuses. We'll then remove that restriction by adding a StoryStatus model. We'll also see the migration generator in action again.

The fixed menu is brain-dead simple. Track down the declaration of the status field in `story.rb` (it's in the `fields do ... end` block), and change it to read something like:

	status enum_string(:new, :accepted, :discussion, :implementation, :user_testing, :deployed, :rejected)
	
Job done. If you want the gory details, `enum_string` is a *type constructor*. It creates an anonymous class that represents this enumerated type (a subclass of String). You can see this in action by trying this in the console:

	>>> Story.find(:first).status.class

The menu is working in the edit-story page now. It would be nice though if we had a ajaxified editor right on the story page. Edit `app/views/stories/show.dryml` to be:

	<show-page>
	  <field-list: tag="editor"/>
	</show-page>
	
What did that do? `<show-page>` uses a tag `<field-list>` to render a table of fields. DRYML's parameter mechanism allows the caller to customize the parameters that are passed to `<field-list>`. On our story page the field-list contains only the status field. By default `<field-list>` uses the `<view>` tag to render read-only views of the fields, but that can be changed by passing a tag name to the `tag` attribute. We're passing `editor` which is a tag for creating ajax-style in-place editors. 
	
	
## Have a configurable set of statuses

In order to support management of the statuses available, we'll create a StoryStatus model

	$ ./script/generate hobo_model_resource story_status name:string
	
Whenever you create a new model + controller with Hobo, get into the habit of thinking about permissions and controller actions. In this case, we probably want only admins to be able to manage the permissions. As for actions, we probably only want the write actions, and the index page:

	auto_actions :write_only, :index
	
Next step, we can remove the 'status' field from the Story model, and instead add an association with the StoryStatus model:

	belongs_to :status, :class_name => "StoryStatus"
	
Now run the migration generator

	$ ./script/generate hobo_migration
	
You'll see that the migration generator considers this change to be ambiguous. Whenever there are columns removed *and* columns added, the migration generator can't tell whether you're actually removing one column and 
adding another, or if you are renaming the old column. It's also pretty fussy about what it makes you type. We really don't want to play fast and lose with your precious data, so to confirm that you want to drop the 'status' column, you have to type in full: "drop status".

Once you've done that you'll see that the generated migration includes the creation of the new foreign key and the removal of the old status column. If you wanted to do something clever with the existing status values you're free to edit the migration and add some data processing before you run it.

That's it. The page to manage the story statuses should appear in the main navigation.

Now that we've got more structured statuses, let's do something with them...

## Filtering stories by status

Rapid's `<table-plus>` is giving us some nice searching and sorting features on the project page. We can easily add some filtering into the mix, so that it's easy to, say, see only new stories. 

First we'll add the filter control to the header of the table-plus. Rapid provides a `<filter-menu>` tag which is just what we need. We want to add it to the header section, before the stuff that's already there. In DRYML, you can prepend or append content to any named parameter. To prepend content to the header, we use `<prepend-header:>`, like this:

	<table-plus fields="this, status">
	  <prepend-header:>
	    <div class="filter">
	      Display by status: <filter-menu param-name="status" options="&StoryStatus.all"/>
	    </div>
	  </prepend-header:>
	  <empty-message:>No stoires match your criteria</empty-message:>
	</table-plus>
	
If you try to use the filter, you'll see it adds a `status` parameter in the query string. We need to pick that up and do something useful with it in the controller. We can use the `apply_scopes` method again, which is already being used, so it's just a matter of adding one more keyword argument:

Needs support in the controller. Add this option to `apply_scopes`:

	:status_is => params[:status]
	
Status filtering should now be working.

[To do: explain the scope being used there]


# Task re-ordering

We're now going to add the ability to re-order a story's tasks by drag-and-drop. There's support for this built into Hobo, so there's not much to do. First we need the `acts_as_list` plugin:

	./script/plugin install acts_as_list
	
Now two changes to our models:
	
 * Task needs `acts_as_list :scope => :story`
 * Story needs `:order => :position` on the `has_many :tasks` declaration

The migration generator knows about `acts_as_list`, so you can just run it and you'll get the new position column on Task.

	$ ./script/generate hobo_migration
	
And that's it! You will need to restart the server because there's a new route for the reorder action.

You'll notice a slight glitch -- the tasks position has been added to the new-task and edit-task forms. We don't want that. The easiest way to fix this is slightly different for the new form and the edit form.

For the new form, we actually don't ever want the position to be set when the task is created -- that's handled by acts-as-list. We can reflect this in the Task's create permissions:

	def creatable_by?(user)
	  !user.guest? && position.nil?
	end
	
When it comes to updating the task, we don't want to ban updates to the position field, or drag-and-drop re-ordering will be prevented too. So it's really just a UI issue -- we'll do the fix in the view layer. 

Create a custom `app/views/tasks/edit.dryml` like this.

	<edit-page>
	  <field-list: skip="position"/>
	</edit-page>

	
# Markdown / Textile formatting of stories

We'll wrap up with a really easy one. Hobo renders model fields based on their type. You can add your own custom types and there's bunch built it, including textile and markdown formatted strings.

Location the `fields do ... end` section in the Story model, and change

	body :text
	
To 

	body :markdown # or :textile

You may need to install the relevant ruby gem: either BlueCloth (markdown) or RedCloth (textile)

That's it! Hope you had fun. I'm sure there are lots of ways you'd like to take this app forward. Have a play and don't forget to take advantage of the forums and IRC channel (#hobo on freenode) if you get stuck. Check the next section if you want some ideas

# Part 6 -- Ideas for extending the app.

## More access controls

It might make sense if users can create their own projects, and control who can view them and who can edit them. For example, you might want to invite a client to have a read-only view of how the project is progressing.


## Milestones

A pretty obvious addition is to have project milestones, and be able to associate tickets with milestones.


## Add comments to stories

It's always useful to be able to have a discussion around things, and a trail of comments is a nice easy way to support this.















