The Hobo User Model and Authentication System
{.document-title}

This chapter of the Hobo Manual documents Hobo's user model.   It's
documented for people who wish to use Hobo's user model and for those
who wish to use Hobo without using the Hobo user model.  This chapter
also documents the Hobo User Controller.

Contents
{.contents-heading}

- contents
{:toc}

# Introduction

A base Hobo app contains a model called `User` that includes
`hobo_user_model`.  The purpose of `hobo_user_model` is primarily to
include the *Hobo User Model* into your application's user model.  To
prevent confusion in this document, I'll use *Hobo User Model* to
denote the included functionality, and I'll use "user model" when I'm
talking about the model in your application that includes the *Hobo
User Model*.

*Hobo User Model* is a simple model that implements everything
Hobo needs from a user model, and a bare minimum functionality that
provides everything the vast majority of web sites require.
Basically, the *Hobo User Model* includes everything that Hobo itself
needs, plus a few very common features that are somewhat tricky to
implement yourself.  Everything else will need to be provided by your
user model.

The standard *Hobo User Model* is very easy to extend to add
additional functionality such as email verification, captcha, et
cetera.

However, one does not need to use the *Hobo User Model*.  The most
common reason not to use it is when adding Hobo to a legacy
application that already has its own user model.  It is also possible
that your site's requirements for a user model are significantly
different from what Hobo provides so that it is easier to start from
scratch than to adapt the Hobo User model.  For example, if your user
model does not use a password, it may be easier to not use the *Hobo
User Model*.

# Users in Hobo

Hobo requires some sort of user system to allow its [permission
system](/manual/permission) to work.  In other words, it is a system
that exists so that some sort of object can get passed to your
permission functions in the `acting_user` variable.

This object does not technically have to be a user.  As an example,
one could have a role-based system where each user could have more
than one role.   In this case, one could pass the user's current role
in the `acting_user` variable rather than the user itself.  It might
be confusing, but you could do it if you needed to.

In controller and views, the user is stored in the `current_user`
variable instead.  `acting_user` and `current_user` may be set to
different users.   This is very uncommon, but it is possible to have
`acting_user` set in a situation without a `current_user`.

## Guest

If there is no current user, `acting_user` and `current_user` are set
to an instance of the Hob::Model::Guest object.  This is not an ActiveRecord
object, it does not get stored in the database.  This object has the
following functions defined:

    def to_s
      "guest"
    end

    def guest?
      true
    end

    def signed_up?
      false
    end

    def login
      "guest"
    end

# The Hobo User Model

The best way to use the Hobo User Model is to invoke the
`hobo_user_model` and `hobo_user_controller` generators.  If you
generated your application with the `hobo` command, these generators
have already been run for you.

This will generate a user model with the default name of `User`,
although that can be changed when running the generator.  The
generators generate a user model that includes the *Hobo User Model*
and provides a minimum functionality.

## What's Required

Here's the bare minimum required to use Hobo with the Hobo User
Model.  This is a subset of what the generator generates.

    class User < ActiveRecord::Base
      hobo_user_model

      fields do
        email_address :email_address, :login => true
      end

      lifecycle do
        state :active, :default => true
        create :signup, :available_to => "Guest",
               :params => [:email_address, :password, :password_confirmation],
               :become => :active
      end

      def create_permitted?
        false
      end
      def update_permitted?
        false
      end
      def destroy_permitted?
        false
      end
      def view_permitted?(field)
        true
      end
    end

If you're familiar with the user model created by the generators, you
may notice what is missing: There's no `administrator` field or
function.  Surprisingly, Hobo does not require this, although it is a
very common pattern for Hobo programs.

Hobo does require that you have one column that you've set the
`:login` option on.  This tells the Hobo User Model which field is
used to log in to the site.  This is typically either the user's email
address or username.  Unless you provide the `:validate => false`
option, Hobo adds a couple of validations to your login attribute.
You should probably add the `:index => true` and `:unique => true`
options to your login column.

Hobo also requires that you have a lifecycle with an :active state.
You don't necessarily have to have an :inactive state -- in fact, it's
common to have more than one inactive state.  Perhaps you'll have a
state to indicate that a user has not completed registration and a
state that indicates a user has been deleted or banned.

If you don't want a lifecycle with an active state, you can redefine
the function `account_active?`, which returns true if the user is in
an active state, and `lifecycle_changing_password?`, which returns
true when the lifecycle's `active_step` is one that changes the
password.  `lifecycle_changing_password?` is used by
`changing_password?` and `new_password_required?`, so you could
redefine those instead of `lifecycle_changing_password?`.   Look in
`hobo/lib/hobo/user.rb` for the current definitions of these
functions.

The last four functions are the standard Hobo
[permission](/manual/permissions) functions.  `hobo_user_model`
incorporates `hobo_model`, so all of the requirements for
`hobo_model` still apply.

## What it Provides

### Passwords

If you use `hobo_user_model` in your model, Hobo automatically
adds these columns to your model:

        fields do
          crypted_password          :string, :limit => 40
          salt                      :string, :limit => 40
        end

It also adds the "virtual columns" `password` and
`password_confirmation`, as well as validators for them.  I call these
"virtual columns" because they behave very similarly to a column, but
they do not get saved in the database.   Instead, they are
SHA1 one-way-hashed with the salt to create `crypted_password`.  Therefore
the password may not be retrieved by looking in the database.  The
only recourse to a lost password is resetting the password.

The *Hobo User Model* adds a validation to the password:
the password must be 6 characters or greater and must not consist
solely of lowercase letters.   To change the validation, redefine the
`validate_password` function

    def validate_password
      errors.add(:password, Hobo::Translations.ht("hobo.messages.validate_password", :default => "must be at least 6 characters long and must not consist solely of lowercase letters.")) if new_password_required? && (password.nil? || password.length<6 || /^[[:lower:]]*$/.match(password))

    end

If you wish to verify a password, you can use the `authenticated?`
function.  It will return true if the password you pass to
`authenticated?` is the valid password.

### The Remember Token

The "remember token" is a cookie that's stored on the user's browser
that indicates that the user has successfully logged in and does not
need to log in again.  Technically, it's not a whole cookie, it's a
cookie fragment in the Rails session.

     fields do
          remember_token            :string
          remember_token_expires_at :datetime
     end

The [login-page](/api_tag_defs/login-page) Rapid tag sets this as the
user logs in if the user has selected the "Remember me" check box.  If
you do not use the default login page, you can set this token by
calling the `remember_me` function.  `forget_me` is the reverse
function.

Currently the remember token is hard coded for 2 weeks.  If you need
this to be configurable, we accept patches and often listen to
requests on the mailing list.

# Hobo User Controller

Adding a call to `hobo_user_controller` at the top of a controller
brings in the *Hobo User Controller* functionality as well as the
standard Hobo controller functionality.

The *Hobo User Controller* adds the following actions:

 - `login`: displays the login form on GET and logs in on POST
 - `logout`: log out
 - `forgot_password`: displays the forgot password form and triggers the `request_password_reset` lifecycle transition
 - `reset_password`: displays the reset password form and triggers the `reset_password` lifecycle transition
 - `account`: displays the account page
 - `signup`: the signup form or the `signup` lifecycle creator

These actions are built using the following helper functions, allowing
you to define your own versions of these actions but still leave Hobo
to do the heavy lifting.

 - `hobo_login(options)`: options are `:success_notice`, `:failure_notice` and `:redirect_to`
 - `hobo_signup(&b)`: the optional block is passed to the :signup creator action
 - `hobo_do_signup(&b)`: the block is optional
 - `hobo_logout(options)`: `:notice` and `:redirect_to` are the options
 - `hobo_forgot_password`
 - `hobo_do_reset_password(&b)`: the block is optional

*Hobo User Controller* actions are built in a manner similar to the
 standard Hobo controller functions, so reference the [controllers
 chapter](/manual/controllers) for more information on their use.

*Hobo User Controller* also provides the function
 `logout_current_user` which may be called to log out the current user.

# Using Hobo without the Hobo User Model

It is possible to use the entire Hobo stack without using the Hobo
User Model.  You may wish to do this if you have a legacy login system
or you need a system without passwords.

This chapter documents the requirements Hobo has of the user model you
wish to use.

## hobo\_model

The first requirement is that the model must be a `hobo_model`.  (It
could be a `hobo_user_model` instead, but that defeats the purpose of
this section).  In particular, Hobo requires the `typed_id`
functionality of `hobo_model`.

## Guest functions

Hob::Model::Guest implements a valid user model, so the functions it defines
should also be defined in your user model.  These functions are
`to_s`, `guest?`, `signed_up?` and `login`.

## Other functions

It's quite useful to have an attribute or function called `name` or
an attribute that has the :name option set.

## Setting the current\_user

To allow Hobo to properly set `current_user`, you must set the `:user`
session variable:

    session[:user] = user.typed_id

This is typically set when the user logs in.
`SessionsController::create` is a typical location for this line of code.
