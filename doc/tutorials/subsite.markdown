# Adding an Administration subsite to an existing Rails 3 application

This tutorial will show how you can create an administrative subsite
for an existing Rails application.   This will allow the administrator
to create, update and destroy any database row without writing any
view code -- only three lines of controller code for each model!

It should also be useful for those who wish to add a subsite to a Hobo
application.  If you already have a Hobo application, some of the
steps mentioned here will be unnecessary.

In this tutorial, we've placed the Hobofied controllers and views in a
subsite.  However, it is certainly possible to mix Hobo code
into your existing controllers.  If you have any questions, [the
mailing list](http://groups.google.com/group/hobousers) is probably
your best resource.

## Install Hobo

The application that I'm going to convert is called **scheduler**.
Let's add a Hobo dependency to it.

    $ gem install hobo

Inside the Gemfile add:

    gem 'hobo'

It might be a good idea to run your application and confirm that
everything still works.

Now might also be a good time to make sure you have your source code
backed up, preferably in an SCM tool like git or subversion.  We're
going to be running some generators: they will ask you before eventually
overwriting some existing file, but just in case you make any mistake.

Notice: When you run in a conflict with an existing file you can see the diffs
by typing 'd'. Check also the other options.

## Run the Hobo generators

Now we'll ask Hobo to copy it's shared files into your application.
These are mostly javascript, css and dryml files

    $ hobo g assets
    $ hobo g rapid

Now let's create our admin subsite:

    $ hobo g subsite admin --make-front-site
    $ hobo g front_controller admin::front --add-routes

Note that if you use `admin_subsite` rather than `subsite`, the
subsite will be limited to the administrator.  For this to work, you
will need to complete the section labelled "Updating your User Model",
below.

## Hobofying a model

Adding the Hobo magic to a model requires two things:

Add this to the top of your model:

    Class Event < ActiveRecord::Base
      hobo_model # Don't put anything above this
      ...

Secondly, all Hobo models require four permission functions.  Here is
what I use in my user model:

    # --- Permissions --- #

    def create_permitted?
      false
    end

    def update_permitted?
      acting_user.administrator? || (acting_user == self && only_changed?(:crypted_password, :email_address))
      # Note: crypted_password has attr_protected so although it is permitted to change, it cannot be changed
      # directly from a form submission.
    end

    def destroy_permitted?
      acting_user.administrator?
    end

    def view_permitted?(field)
      true
    end

For now, I recommend returning _true_ from all of these permission
functions.  After hobofying your User model, these functions will
become easier to write.

If your model does not have a column called "name", I recommend
defining a function on your model that returns a human readable
summary of the row.

## Creating a controller for the hobofied model:

I'm going to create an Admin::Event controller for my event model.
This file goes in `app/controllers/admin/events_controller.rb`:

    class Admin::EventsController < Admin::AdminSiteController
      hobo_model_controller Event
      auto_actions :all
    end

At this stage you should be able to run your application.  If you
browse to "/admin/events", you can create, remove, update and destroy
any events you have permission to access.

## Modifying the views

If you need to modify the views for your subsite, you may create
subdirectories in `app/views/admin`.  For example,
`app/views/admin/foos/show.dryml` is the show view for the foos
controller.

`app/views/taglibs/admin_site.dryml` is the equivalent of
application.dryml for your subsite.

## Updating your User model

At this stage you have created an administrator interface, and could
stop here.   However, as far as Hobo is concerned, any users are
logged in as a guest.  To distinguish administrators from normal users
from random surfers, hackers and bots, we will need to set up an
authentication system.

### If you don't have one

If you don't currently have a User model, type:

    $ hobo g user_resource User
    $ hobo g migration

The last generator will ask if you wish to run the migration immediately.  Enter "m" to tell it to do so.

The following pages will now be available:

* `/users/signup`
* `/forgot_password`
* `/login`
* `/logout`

### If you have a User model

Most likely, you already have a User model and authentication system.
In most cases, it is quite easy to make this Hobo compatible.

First of all, you should add the following line to the top of your
model:

    hobo_model # Don't put anything above this

Do not use `hobo_user_model` -- this will pull in authentication
functions and database columns.

Many User models have the columns *name:string* and
*administrator:boolean*.  If your model does not, create appropriate functions to
mimic this behaviour.  For example:

    def name
      "#{first_name} #{last_name}"
    end

    def administrator
      role == "administrator"
    end

Also, Hobo requires the following functions to be defined on your
User model.  Define appropriately.  Here is what I used:

    def to_s
      name
    end

    def guest?
      false
    end

    def signed_up?
      true
    end

    def login
      email_address
    end

Finally, you need to let Hobo know who the current user is.  This is
done by setting a session variable when the user logs in:

    session[:user] = user.typed_id

In my case, a very similar line was placed in `SessionsController::create`

From now on, an instantiated User or Guest object will be available in
`current_user` in your controllers and views.  It will also be
available in `acting_user` in your permission functions in your
hobofied models.
