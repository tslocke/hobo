Hobo Lifecycles
{.document-title}

This chapter of the Hobo manual describes Hobo's "lifecycle" mechanism. This is an extension that lets you define a lifecycle for any ActiveRecord model. Defining a lifecycle is like a finite state machine -- a pattern which turns out to be extremely useful for modelling all sorts of processes that crop up in the world that we're trying to model. That might make Hobo's lifecycles sound similar to the well known `acts_as_state_machine` plugin, and in a way they are, but with Hobo style. The big win comes from the fact that, like many things in Hobo, there is support for this feature in all three of the MVC layers, which can make it very quick and easy to get up and running.


Contents
{: .contents-heading}

- contents
{:toc}


# Introduction

In the REST style, which is popular with Rails coders, we view our objects a bit like documents: you can post them to a website, get them again later, make changes to them and delete them. Of course, these objects also have behaviour, which we often implement by hooking functionality to the create / update / delete events (e.g. using callbacks such as `after_create` in ActiveRecord). At a pinch we may have to fall back to the RPC style, which Hobo has support for with the "Web Method" feature.

This works great for many situations, but some objects are *not* best thought of as documents that we create and edit. In particular, applications often contain objects that model some kind of *process*. A good example is *friendship* in a social app. Here's a description of how friendship might work:

 * Any user can **invite** friendship with another user
 * The other user can **accept** or **reject** (or perhaps **ignore**) the invite.
 * The friendship is only **active** once it's been accepted
 * An active friendship can be **cancelled** by either user.

Not a create, update or delete in sight. Those bold words capture the way we think about the friendship much better. Of course we *could* implement friendship in a RESTful style, but we'd be doing just that -- *implementing* it, not *declaring* it. The life-cycle of the friendship would be hidden in our code, scattered across a bunch of callbacks, permission methods and state variables. Experience has shown this type of code to be tedious to write, *extremely* error prone and fragile when changing.

Hobo lifecycles is a mechanism for declaring the lifecycle of a model in a natural manner.

REST vs. lifecycles is not an either/or choice. Some models will support both styles. A good example is a content management system with some kind of editorial workflow. An application like that might have an Article model, which can be created, updated and deleted like any other REST resource. The Article might also feature a lifecycle that defines how the article goes from newly authored, through one or more stages of review (possibly being rejected at any stage) before finally becoming accepted, and later published.


# An Example

Everyone loves an example, so here is one. We'll stick with the friendship idea. If you want to try this out, create a blank app and add a model:

    $ hobo new friends
    $ cd friends
    $ hobo generate model friendship

Here's the code for the friendship mode (don't be put off by the `MagicMailer`, that's just a made-up class to illustrate a common use of the callback actions -- sending emails):

    class Friendship < ActiveRecord::Base

      hobo_model

      # The 'sender' of the invite
      belongs_to :invitor, :class_name => "User"

      # The 'recipient' of the invite
      belongs_to :invitee, :class_name => "User"

      lifecycle do

        state :invited, :active, :ignored

        create :invite, :params => [ :invitee ], :become => :invited,
                         :available_to => "User",
                         :user_becomes => :invitor do
          MagicMailer.send invitee, "#{invitor.name} wants to be friends with you"
        end

        transition :accept, { :invited => :active }, :available_to => :invitee do
          MagicMailer.send invitor, "#{invitee.name} is now your friend :-)"
        end

        transition :reject, { :invited => :destroy }, :available_to => :invitee do
          MagicMailer.send invitor, "#{invitee.name} blew you out :-("
        end

        transition :ignore, { :invited => :ignored }, :available_to => :invitee

        transition :retract, { :invited => :destroy }, :available_to => :invitor do
          MagicMailer.send invitee, "#{invitor.name} reconsidered"
        end

        transition :cancel, { :active => :destroy }, :available_to => [ :invitor, :invitee ] do
          to = acting_user == invitor ? invitee : invitor
          MagicMailer.send to, "#{acting_user.name} cancelled your friendship"
        end

      end

    end
{.ruby}

Visually, the lifecycle can be represented as a graph, just as we would draw a finite state machine:

![Friendship Lifecycle](/images/manual/friendship-lifecycle.png)

Let's work through what we did there.

Because `Friendship` has a lifecycle declared, a class is created that captures the lifecycle. The class is `Friendship::Lifecycle`. Each instance of `Friendship` will have an instance of this class associated with it, available as `my_friendship.lifecycle`.

The `Friendship` model will also have a field called `state` declared. The migration generator will create a database column for `state`.

The lifecycle has three states:

    state :invited, :active, :ignored
{.ruby}

There is one 'creator' -- this is a starting point for the lifecycle:

    create :invite, :params => [ :invitee ], :become => :invited,
                     :available_to => "User",
                     :user_becomes => :invitor do
       MagicMailer.send invitee, "#{invitor.name} wants to be friends with you"
     end
{.ruby}

That declaration specifies that:

 - The name of the creator is `invite`. It will be available as a method `Friendship::Lifecycle.invite(user, attributes)`. Calling the method will instantiate the record, setting attributes from the hash that is passed in

 - The `:params` option specifies which attributes can be set by this create step:

        :params => [ :invitee ]
{.ruby}

   any other key in the `attributes` hash passed to `invite` will be ignored.

 - The lifecycle state after this create step will be `invited`:

        :become => :invited,
{.ruby}

 - To have access to this create step, the acting user must be an instance of `User` (i.e. not a guest):

        :available_to => "User"
{.ruby}

 - After the create step, the `invitor` association of the `Friendship` will be set to the acting user:

       :user_becomes => :invitor
{.ruby}

 - After the create step has completed (and the database updated), the block is executed:

        do
          MagicMailer.send invitee, "#{invitor.name} wants to be friends with you"
        end
{.ruby}

There are five transitions declared: accept, reject, ignore, retract, cancel. These become methods on the lifecycle object (not the
lifecycle class), e.g. `my_friendship.lifecycle.accept!(user, attributes)`. Calling that method will:

 - Check if the transition is allowed

 - If it is, update the record with the passed in attributes. The attributes that can change are declared in a `:params` option, as we saw
   with the creator. None of the friendship transitions declare any `:params`, so no attributes will change, and

 - change the `state` field to the new state, then

 - save the record, as long as validations pass.

Each transition declares:

 - which states it goes from and to, e.g. `accept` goes from `invited` to `active`:

        transition :accept, { :invited => :active }
{.ruby}

   Some of the transitions are to a pseudo state: `:destroy`. To move to this state is to destroy the record.

 - who has access to it.

        :available_to => :invitor
        :available_to => :invitee
{.ruby}

   In the create step the `:available_to` option was set to a class name, here it is set to a method (a `belongs_to` association) and to be
   allowed, the acting user must be the same user returned by this method. There are a variety ways that `:available_to` can be used, which
   will be discussed in detail later.

 - a callback (the block). This is called after the transition completes. Notice that in the block for the `cancel`
   transition we're accessing `acting_user`, which is a reference to the user performing the transition.

Hopefully that worked example has clarified what lifecycles are all about. We'll move on and look at the details now.


# Key concepts

Before getting into the API we'll recap some of the key concepts very briefly.

As mentioned in the introduction, the lifecycle is essentially a finite state machine. It consists of:

 - One or more *states*. Each has a name, and the current state is stored in a simple string field in the record. If you like to think of a finite state machine as a graph, these are the nodes.

 - Zero or more *creators*. Each has a name, and they define actions that can start the lifecycle, setting the state to be some start-state.

 - Zero or more *transitions*. Each has a name, and they define actions that can change the state. Again, thinking in terms of a graph, these are the arcs between the nodes.

The creators and the transitions are together known as the *steps* of the lifecycle.

There are a variety of ways to limit which users are allowed to perform which steps, and there are ways to attach custom actions (e.g. send an email) both to steps and to states.


# Defining a lifecycle

Any Hobo model can be given a lifecycle like this:

    class Friendship < ActiveRecord::Base

      hobo_model

      lifecycle do
        ... define lifecyle steps and states ...
      end

    end
{.ruby}

Any model that has such a declaration will gain the following features:

 - The lifecycle definition becomes a class called `Lifecycle` which is nested inside the model class (e.g. `Friendship::Lifecycle`) and is a subclass of `Hobo::Lifecycles::Lifecycle`. The class has methods for each of the creators.

 - Every instance of the model will have an instance of this class available from the `#lifecycle` method. The instance has methods for each of the transitions:

        my_friendship.lifecycle.class # => Friendship::Lifecycle
        my_friendship.lifecycle.reject!(user)
{.ruby}

The `lifecyle` declaration can take three options:

 - `:state_field` - the name of the database field (a string field) to store the current state in. Default '`state`'

 - `:key_timestamp_field` - the name of the database field (a datetime
   field) to store a timestamp for transitions that require a key
   (discussed later). Set to `false` if you don't want this
   field. Default '`key_timestamp`'.

 - `:key_timeout` - keys will expire after this amount of time.
   Default `999.years`.

Note that both of these fields are declared `never_show` and `attr_protected`.

Within the `lifecycle do ... end` a simple DSL is in effect. Using this we can add states and steps to the lifecycle.


## Defining states

To declare states:

    lifecycle do
      state :my_state, :my_other_state
    end
{.ruby}

You can call `state` many times, or pass several state names to the same call.

Each state can have an action associated with it:

    state :active do
      MagicMailer.send [invitee, invitor], "Congratulations, you are now friends"
    end
{.ruby}

You can provide the `:default => true` option to have the database default for the state field be this state:

    state :invited, :default => true
{.ruby}

This will take effect the next time you generate and apply a hobo_migration.

## Defining creators

A creator is the starting point for a lifecycle. They provide a way for the record to be created (in addition to the regular `new` and `create` methods). Each creator becomes a method on the lifecycle class. The definition looks like:

    create name, options do ... end
{.ruby}

The name is a symbol. It should be a valid ruby name that does not conflict with the class methods already present on the `Hobo::Lifecycles::Lifecycle` class.

The options are:

 - `:params` - an array of attribute names that are parameters of this create step. These attributes can be set when the creator runs.

 - `:become` - the state to enter after running this creator. This does not have to be static but can depend on runtime state. Provide one
   of:

   - A symbol -- the name of the state
   - A proc -- if the proc takes one argument it is called with the record, if it takes none it is `instance_eval`'d on the record. Should
     return the name of the state
   - A string -- evaluated as a Ruby expression with in the context of the record

 - `:if` and `:unless` -- a precondition on the creator. Pass either:

   - A symbol -- the name of a method to be called on the record
   - A string -- a Ruby expression, evaluated in the context of the record
   - A proc -- if the proc takes one argument it is called with the record, if it takes none it is `instance_eval`'d on the record

   Note that the precondition is evaluated *before* any changes are made to the record using the parameters to the lifecycle step.

 - `:new_key` -- generate a new lifecycle key for this record by setting the `key_timestamp` field to be the current time.

 - `:user_becomes` -- the name of an attribute (typically a `belongs_to` relationship) that will set to the `acting_user`.

 - `:available_to` -- Specifies who is allowed access to the creator. This check is in addition to the precondition (`:if` or `:unless`).
   There are a variety of ways to provide the `:available_to` option, discussed later on

The block given to `create` provides a callback which will be called
after the record has been created. You can give a block with a single
argument, in which case it will be passed the record, or with no
arguments in which case it will be `instance_eval`'d on the record.

Once you have defined a creator action for your model, you will
probably want to use it instead of the standard `new` method on your
model.  For example:

    new_friendship = Friendship::Lifecycle.my_creator(user, :param1 => "foo")
    new_friendship.save!

The first parameter of the creator is the user that is used for
permission checks via the `:available_to` option.  The second
parameter is a hash where the keys should correspond to the attribute
names listed in the `:params` option.

## Defining transitions

A transition is an arc in the graph of the finite state machine -- an operation that takes the lifecycle from one state to another (or, potentially, back to the same state.). The definition looks like:

    transition name, { from => to }, options do ... end
{.ruby}

The name is a symbol. It should be a valid ruby name.

The second argument is a hash with a single item:

    { from => to }
{.ruby}

 (We chose this syntax for the API just because the `=>` is quite nice to indicate a transition)

This transition can only be fired in the state or states given as `from`, which can be either a symbol or an array of symbols. On completion of this transition, the record will be in the state give as `to` which can be one of:

 - A symbol -- the name of the state
 - A proc -- if the proc takes one argument it is called with the record, if it takes none it is `instance_eval`'d on the record. Should
   return the name of the state
 - A string -- evaluated as a Ruby expression with in the context of the record

The options are:

 - `:params` - an array of attribute names that are parameters of this transition. These attributes can be set when the transition runs.

 - `:if` and `:unless` -- a precondition on the transition. Pass either:

   - A symbol -- the name of a method to be called on the record
   - A string -- a Ruby expression, evaluated in the context of the record
   - A proc -- if the proc takes one argument it is called with the record, if it takes none it is `instance_eval`'d on the record

 - `:new_key` -- generate a new lifecycle key for this record by setting the `key_timestamp` field to be the current time.

 - `:keep_key` -- (new in v1.0.3).  Normally, the lifecycle key is cleared on a transition to prevent replay vulnerabilities.   If this option is set, the key is not cleared

 - `:user_becomes` -- the name of an attribute (typically a `belongs_to` relationship) that will set to the `acting_user`.

 - `:available_to` -- Specifies who is allowed access to the transition. This check is in addition to the precondition (`:if` or
   `:unless`). There are a variety of ways to provide the `:available_to` option, discussed later on.

The block given to `transition` provides a callback which will be
called after the record has been updated. You can give a block with a
single argument, in which case it will be passed the record, or with
no arguments in which case it will be `instance_eval`'d on the record.

Each transition becomes a method on the lifecycle object (with `!`
appended).  The first parameter to the method is the user and the
second optional parameter is a hash of the params defined in :params.

An example call:

    bar.lifecycle.foo!(user, :baz => "bat" )

### Repeated transition names

It is not required that a transition name is distinct from all the others. For example, a process may have many stages (states) and there may be an option to abort the process at any stage. It is possible to define several transitions called `:abort`, each starting from a different start state. You could achieve a similar effect by listing all the start states in a single transition, but by defining separate transitions, each one could, for example, be given a different action (block).


## The `:available_to` option

Both create and transition steps can be made accessible to certain users with the `:available_to` option. If this option is given, the step is considered 'publishable', and there will be automatic support for the step in both the controller and view layers.

The rules for the `:available_to` option are as follows. Firstly, it can be one of three special values:

 - `:all` -- anyone, including guest users, can trigger the step

 - `:key_holder` -- (transitions only) anyone can trigger the transition, provided `record.lifecycle.provided_key` is set to the correct key. Discussed in detail later.

 - :self -- (transitions only) the `acting_user` and the record the transition is called on must be one and the same. Only makes sense for user models of course.

If `:available_to` is not one of those, it is an indication of some code to run (just like the `:if` option for example):

  - A symbol -- the name of a method to call

  - A string -- a ruby expression which is evaluated in the context of the record

  - A proc -- if the proc takes one argument it is called with the record, if it takes none it is `instance_eval`'d on the record

The value returned is then used to determine if the `acting_user` has access or not. The value is expected to be:

 - A class -- access is granted if the `acting_user` is a `kind_of?` that class.

 - A collection -- if the value responds to `:include?`, access is granted if `include?(acting_user)` is true. e.g.

 - A record -- if the value is neither a class or a collection, access is granted if the value *is* the `acting_user`

Some examples:

Say a model has an owner:

    belongs_to :owner, :class_name => "User"
{.ruby}

You can just give the name of the relationship (since it is also a method) to restrict the transition to that user:

    :available_to => :owner
{.ruby}
Or a model might have a list of collaborators associated with it:

    has_many :collaborators, :class_name => "User"
{.ruby}

Again it's easy to make the lifecycle step available to them only (since the `has_many` does respond to `:include?`):

    :available_to => :collaborators
{.ruby}

If you were building more sophisticated role based permissions, you could make sure you role object responds to `:include?` and then say,
for example:

    :available_to => "Roles.editor"
{.ruby}

A common problem experienced by hoboists is how to turn a boolean
condition on a user object into something suitable for :available_to.
The best way to do so is via a named scope.

    class User < ActiveRecord::Base
       ...
       named_scope :administrator, :conditions => {:administrator => true}
       ...
    end

allows you to do:

    :available_to => "User.administrator"

In fact, the above named_scope definition was just provided for
illustrative purpose, since [Automatic Named Scopes](../scopes) will
provide that specific definition for you.

The nice thing about named scopes is that it uses database queries to
do the matching, so can be very efficient.   But if you are having
trouble expressing your condition as a database query, you can use
Proc to provide a snippet of code that either returns acting_user or nil:

    :available_to => Proc.new { acting_user if acting_user.administrator? }

# Validations

TO DO

Short version: validations have been extended so you can give the name of a lifecycle step to the :on option. e.g.

    validates_presence_of :notes, :on => :submit
{.ruby}

Also now supports `record.lifecycle.valid_for_foo?` where `foo` is a lifecycle transition.


# Controller actions and routes

As well as providing the lifecycle mechanism in the model, Hobo also supports the lifecycle in the controller layer, and provides an automatic user interface in the view layer. All of this can be fully customised of course. In this section we'll look at the controller layer features, including the routes that get generated.

Lifecycle steps that include the `:available_to` option are considered *publishable*. It is these that Hobo generates controller actions for. Any step that does not have the `:available_to` option can be thought of as 'internal'. Of course you can call those create steps and transitions from your own code, but Hobo will never do that for you.

## `auto_actions`

The lifecycle actions are added to your controller by the `auto_actions` directive. To get them you need to say one of:

 - `auto_actions :all`
 - `auto_actions :lifecycle` -- adds *only* the lifecycle actions
 - `auto_actions :accept, :do_accept` (for example) -- as always, you can list the method names explicitly (the method names that relate to lifecycle actions are given below)

You can also remove lifecycle actions with:

 - `auto_actions ... :except => :lifecycle` -- don't create any lifecycle actions or routes
 - `auto_actions ... :except => [:do_accept, ...]` -- don't create the listed lifecycle actions or routes


## Create steps

For each create step that is publishable, the model controller adds two actions. Going back to the friendship example, two actions will be created for the `invite` step. Both of these actions will pass the `current_user` to the lifecycle, so access restrictions (the `:available_to` option) will be enforced, as will any preconditions (`:if` and `:unless`).

### The create page action

`FriendshipsController#invite` will be routed as `/friendships/invite` for GET requests.

This action is intended to render a form for the create step. An object that provides metadata about the create step will be available in `@creator` (an instance of `Hobo::Lifecycles::Creator`).

If you want to implement this action yourself, you can do so using the `creator_page_action` method:

    def invite
      creator_page_action :invite
    end
{.ruby}

Following the pattern of all the action methods, you can pass a block in which you can customise the response by setting a flash message, rendering or redirecting. `do_creator_action` also takes a single option:

 - `:redirect` -- change where to redirect to on a successful submission. Pass a symbol to redirect to that action (show actions only) or an array of arguments which are passed to `object_url`.  Passing a String or a Hash will pass your arguments straight to `redirect_to`.

### The 'do create' action

`FriendshipsController#do_invite` will be routed as `/friendships/invite` for POST requests.

This action is where the form should POST to. It will run the create step, passing in parameters from the form. As with normal form submissions (i.e. create and update actions), the result will be an HTTP redirect, or the form will be re-rendered in the case of validation failures.

Again you can implement this action yourself:

    def do_invite
      do_creator_action :invite
    end
{.ruby}

You can give a block to customise the response, or pass the redirect option:

 - `:redirect` -- change where to redirect to on a successful submission. Pass a symbol to redirect to that action (show actions only) or an array of arguments which are passed to `object_url`.  Passing a String or a Hash will pass your arguments straight to `redirect_to`.


## Transitions

As with create steps, for each publishable transition there are two actions. For both of these actions, if `params[:key]` is present, it will be set as the `provided_key` on the lifecycle, so transitions that are `:available_to => :key_holder` will work automatically.

We'll take the friendship `accept` transition as an example.

### The transition page

`FriendshipsController#accept` will be routed as `/friendships/:id/accept` for GET requests.

This action is intended to render a form for the transition. An object that provides metadata about the transition will be available in `@transition` (an instance of `Hobo::Lifecycles::Transition`).

You can implement this action yourself using the `transition_page_action` method

    def accept
      transition_page_action :accept
    end
{.ruby}

As usual, you can customise the response by passing a block. And you can pass the following option:

 - `:key` -- the key to set as the provided key, for transitions that are `:available_to => :key_holder`. Defaults to `params[:key]`

### The 'do transition' action

`FriendshipsController#do_accept` will be routed as `/friendships/:id/accept` for POST requests.

This action is where the form should POST to. It will run the transition, passing in parameters from the form. As with normal form submissions (i.e. create and update actions), the result will be an HTTP redirect, or the form will be re-rendered in the case of validation failures.

You can implement this action yourself using the `do_transition_action` method:

    def do_accept
      do_transition_action :accept
    end
{.ruby}

As usual, you can customise the response by passing a block. And you can pass the following options:

 - `:redirect` -- change where to redirect to on a successful submission. Pass a symbol to redirect to that action (show actions only) or an array of arguments which are passed to `object_url`.
 - `:key` -- the key to set as the provided key, for transitions that are `:available_to => :key_holder`. Defaults to `params[:key]`


## Subsite routes

By default, Hobo generates the routes of your transition through the front subsite. If you want it to point the route
of any creator/transition action to a different subsite, you can pass the :subsite option (e.g.: :subsite => 'any_subsite')


# Keys and secure links

Hobo's lifecycles also provide support for the "secure link" pattern. By "secure" we mean that on one other than the holder of the link can access the page or feature in question. This is achieved by including some kind of cryptographic key in the URL, which is typically sent in an email address. The two very common examples are:

 - Password reset -- following the link gives the ability to set a new password for a specific account. By using a secure link and emailing it to the account holders email address, only a person with access to that email account can chose the new password.

 - Email activation -- by following the link, the user has effectively proved that they have access to that email account. Many sites use this technique to verify that the email address you have given is one that you do in fact have access to.

In fact the idea of a secure link is more general than that. It can be applied in any situation where you want a particular person to participate in a process, but that person does not have an account on the site. For example, in a CMS workflow application, you might want to email a particular person to ask them to verify that the content of an article is technically correct. Perhaps this is a one-off request so you don't want to trouble them with signing up. Your app could provide a page with "approve"/"reject" buttons, and access to that page could be protected using the secure link pattern. In this way, the person you email the secure link to, and no one else, would be able to accept or reject the article.

Hobo's lifecycles provide support for the secure-link pattern with the following:

 - A field added to the database called (by default) "`key_timestamp`". This is a date-time field, and is used to generate a key as follows:

        Digest::SHA1.hexdigest("#{id_of_record}-#{current_state}-#{key_timestamp}")
{.ruby}

 - Both create and transition steps can be given the option `:new_key => true`. This causes the `key_timestamp` to be updated to `Time.now`.

 - The `:available_to => :key_holder` option (transitions only). Setting this means the transition is only allowed if the correct key has been provided, like this:

        record.lifecycle.provided_key = the_key
{.ruby}

Hobo's "model controller" also has (very simple) support for the secure-link pattern. Prior to rendering the form for a transition, or accepting the form submission of a transition, it does (by default):

    record.lifecycle.provided_key = params[:key]
{.ruby}

## Implementing a lifecycle with a secure-link

Stringing this all together, we would typically implement the secure-link pattern as follows. We're assuming some knowledge of Rails mailers here, so you may need to read up on those.

 - Create a mailer (`script/generate mailer`) which will be used to send the secure link.

 - In your lifecycle definition, two steps will work together:

    - A create or transition will initiate the process, by generating a new key, emailing the link, and putting the lifecycle in the correct state.

    - A transition from this state will be declared as `:available_to => :key_holder`, and will perform the protected action.

 - Add `:new_key => true` to the create or transition step that initiates the process.

 - On this same step, add a callback that uses the mailer to send the key to the appropriate user. The key is available as `lifecycle.key`. For example, the default Hobo user model has:

        transition :request_password_reset, { :active => :active }, :new_key => true do
          UserMailer.deliver_forgot_password(self, lifecycle.key)
        end
{.ruby}

 - Add `:available_to => :key_holder` to the subsequent transition -- the one you want to make available only to recipients of the email.

 - The mailer should include a link in the email, and they key should be part of this link as a query parameter. Hobo creates a named route for each transition page, so there will be a URL helper available. For example, if the transition is on `User` and is called `reset_password`, the link in your mailer template should look something like:

        <%= user_reset_password_url :host => @host, :id => @user, :key => @key %>
{.ruby}

  (it's up to you to set @host, but you could use `Hobo::Controller.request_host`)

That should be it.


## Testing active step.

In some rare cases your code might need to know if a lifecycle step is currently in progress or not (e.g. in a callback or a validation). For this you can access either:

    record.lifecycle.submit_in_progress.active_step.name
{.ruby}

Or, if you are interested in a particular step, it's easier to call:

    record.lifecycle.submit_in_progress?
{.ruby}

Where `submit` can be any lifecycle step.



# Lifecycles in Rapid: pages, forms and buttons

TO DO.

Have a look in the auto-generated taglibs:

 - `pages.dryml` contains pages for each publishable create and transition.

 - `forms.dryml` contains forms for each publishable create and transition.

There are a couple of tags in `rapid_lifecycles.dryml` that provide buttons for executing transition steps (e.g. an "Accept Friendship" button).

# Other bits to do:

Invariants (do we even need/want these?)
