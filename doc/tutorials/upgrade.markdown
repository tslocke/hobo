Upgrading an Application from Hobo 1.0 to Hobo 2.0
{.document-title}

Notes from an upgrade of an application from Hobo 1.0 to Hobo 2.0

Contents
{: .contents-heading}

- contents
{:toc}

# Introduction

We have a small intranet application running on Rails 2.3.2 and Hobo 1.0.  However, we want to make this site iPhone friendly.  The easiest way to make the site mobile friendly is to upgrade to Hobo 2.0 so we can easily use the bootstrap theme.  Upgrading to the latest version of Rails will also make it possible for us to place the app outside of the firewall.

We'll document the process of upgrading this app so you can use it as a guide to upgrading your app.   Not everything will apply if you're upgrading from Hobo 1.1 or Hobo 1.3, but it should still be very helpful.

# Upgrading to Hobo 2.0

## Back up your Database

The first thing we're going to do is to take a backup of the database from the production server so that we can use it for development.

    $ mysqldump bop_production > bop.sql

## Generating a New App

When doing a major upgrade, it is often useful to generate a new application to compare against your old application.  You can then compare old and new to get an idea of what you need to change.   For example, there might be some new configuration items that have appeared in config/application.rb that you want to take advantage of.

In our case, we don't even have a config/application.rb becuase our app is running on Rails 2.   So we're going to take the opposite approach; we're going to generate a new app, and slowly move code from the old app into the new app.   This has the significant advantage that the new application should be in a working state at all times.  It might take longer, but it isn't as scary.   So for major upgrades, I suggest this approach.

     $ gem install hobo --pre
     $ hobo new bop2 -d mysql

In our case, we're going to generate a new private invite-only app.  This wasn't an option when the old app was generated, but we're going to take advantage of it now.   I don't expect it to throw us for too many loops since the old app used the Hobo user model pretty much unchanged.

We're going to choose the 'clean' theme to start with.  It's easy enough to switch themes later, so we'll minimize our initial work by using the same theme that was included in Hobo 1.0.

Also make sure you skip the initial migration.  We're going to be using a copy of our old application's database, so we're not going to use migrations.  Instead we're just going to load it from the backup:

     $ rake db:create
     $ mysql bop2_development < ../bop/bop.sql

## Updating the User Model

Our first step is to compare app/models/user.rb in both our old and new applications.

    $ diff bop/app/models/user.rb bop2/app/models/user.rb

gives

    @@ -3,45 +3,70 @@ class User < ActiveRecord::Base
       hobo_user_model # Don't put anything above this

       fields do
    -    name :string, :unique
    -    email_address :email_address, :unique, :login => true
    +    name          :string, :required, :unique
    +    email_address :email_address, :login => true
         administrator :boolean, :default => false
         timestamps
       end
{.diff}

This is the most important area to check.  In our case, the differences are insignificant.  Some of the flags have changed slightly, but the columns are essentially identical.

    +  attr_accessible :name, :email_address, :password, :password_confirmation
{.diff}

This new line is required if you have `config.active_record.whitelist_attributes = true`, and you should.


    -  # This gives admin rights to the first sign-up.
    +  # This gives admin rights and an :active state to the first sign-up.
       # Just remove it if you don't want that
    -  before_create { |user| user.administrator = true if RAILS_ENV != "test" && count == 0 }
    -  
    -  
    +  before_create do |user|
    +    if !Rails.env.test? && user.class.count == 0
    +      user.administrator = true
    +      user.state = "active"
    +    end
    +  end
{.diff}

We just ignore this change because our user count is above 0.

    +
    +  def new_password_required_with_invite_only?
    +    new_password_required_without_invite_only? || self.class.count==0
    +  end
    +  alias_method_chain :new_password_required?, :invite_only
    +
       # --- Signup lifecycle --- #

       lifecycle do

    -    state :active, :default => true
    +    state :invited, :default => true
    +    state :active
            ...  snip ...
       end
    -  
    +
    +  def signed_up?
    +    state=="active"
    +  end
{.diff}

The lifecycle has changed completely because we switched to invite only.

       # --- Permissions --- #

       def create_permitted?
    -    false
    +    # Only the initial admin user can be created
    +    self.class.count == 0
       end

       def update_permitted?
    -    acting_user.administrator? || (acting_user == self && only_changed?(:crypted_password, :email_address))
    +    acting_user.administrator? ||
    +      (acting_user == self && only_changed?(:email_address, :crypted_password,
    +                                            :current_password, :password, :password_confirmation))
         # Note: crypted_password has attr_protected so although it is permitted to change, it cannot be changed
         # directly from a form submission.
       end
{.diff}

And it appears that our permissions haven't changed substantially, either.  So we're just going to leave our new user.rb unchanged.  That's not surprising, since our git log shows us that we didn't really modify our user.rb from stock.   If you modified your user.rb more heavily than we did, it's quite likely that you'll have to copy most of those changes into the new user.rb.

## Running the New App

At this point our new application won't do much, but should be working.   So we fire it up with `rails s`, and we point a browser at it.  We can successfully log in as an admin, and navigating to /admin/users/ shows our user list.   Sweet!

## Adding a Simple Resource

Now we're going to check our app for a very simple model.  Here's one of ours:

    class Facility < ActiveRecord::Base

      hobo_model # Don't put anything above this

      fields do
        name :string
        code :string
        lock_version :integer
        timestamps
      end
      has_many :claims

      # --- Permissions --- #

      def create_permitted?
        acting_user.administrator?-
      end

      def update_permitted?
        acting_user.administrator?
      end

      def destroy_permitted?
        acting_user.administrator?
      end

      def view_permitted?(field)
        true
      end

    end
{.ruby}

That's about as simple as a model gets, so let's see what a similar Hobo 2.0 model looks like.

    $ hobo generate resource facility name:string code:string lock_version:integer
    $ diff --unified=0 --ignore-all-space ../bop/app/models/facility.rb app/models/facility.rb

results in

    -  has_many :claims
    +  attr_accessible :name, :code, :lock_version

We can't yet add the `has_many :claims` line because we haven't moved the claim model yet.  The new line is `attr_accessible`, which is required by the standard Rails 3.2 security model.   We'll go ahead and remove `lock_version` from this line since it's for optimistic locking and should never be included in a form.

    $ diff --unified=0 --ignore-all-space ../bop/app/controllers/facilities_controller.rb app/controllers/facilities_controller.rb

Shows no changes.   Sweet!   `app/views/facilities/` is empty in both cases.  Finally, let's check out old `app/views/taglibs/application.dryml` for any mention of `facilit[y|ies]`.   There's a mention inside the claim view, the claim form and also this:

    <extend tag="form" for="Facility">
      <old-form merge>
        <field-list: fields="name, code"/>
      </old-form>
    </extend>

Let's copy that into our new application.dryml and fire our new app up again.  It works!

## Rich Types

We had a rich type in `app/models/dollars.rb`.   Since Hobo 1.3, rich types should be placed in `app/rich_types/`, so we'll copy it there.  We also had a custom view for it in application.dryml, so we copy that across to.

## Associations

We do a few more simple models.  But rather than generating the new models, we'll just copy them from our old application and add appropriate `attr_accessible` lines.

The other change we'll make is that we add the `:inverse_of` option to all our `has_many` and `belongs_to` relationships:

    class Facility < ActiveRecord::Base
      has_many :claims, :inverse_of => :facilities
    end

    class Claim < ActiveRecord::Base
      belongs_to :facility, :inverse_of => :claims
    end

In older versions of Hobo, this is a very useful optimization.  In Hobo 2.0, `:inverse_of` is sometimes required.  We'll just add it everywhere rather than figure out where it's required.

## Copy Controllers

We had a few helper functions in `application_controller.rb`, so we'll move those into the new `application_controller.rb`.  We just copied our other controllers straight across.

## Plugins

Our old application used several plugins.  We used Google to find modern versions of them, and installed them.  In most cases this just required adding them to Gemfile.

## Views

Most of our views can be copied straight across from the old application to the new one.  One major exception is application.dryml.  In Hobo 2.0 how plugins and themes are loaded has changed, and application.dryml has been split into two files:  front_site.dryml and application.dryml.   In our case we left behind the top of our old application.dryml and copied the rest, everything below the `<def tag="app-name">` line.

There was an `<extend tag="page">` clause in our old application.dryml that added some javascript for one of the plugins we were using.  We were able to remove this completely because the Rails3 version of the plugin loads the javascript via the asset pipeline.   It also added added jQuery to our pages, which is now included in every Hobo 2.0 application.

## Mail

Mail changed significantly in Rails 3.  We aren't going to bother fixing it for our app.  If any of our users need to reset their password, we'll do it manually.  We only have three users, so I'm not too worried!

## Javascript

There was a very small amount of custom Javascript in our application, in a `<custom-javascript>` section on a few pages.   We moved that into its own file in `app/assets/javascripts/application/`.  This means that it will be loaded on every page, but since we plan on using turbolinks, this is actually faster than only loading it on the pages that need it.

Our javascript code used jQuery so we didn't have to convert it, but if it was prototype.js code we probably would have converted it into jQuery code.

# Switching to Bootstrap Theme

Now that the app is ported, let's switch to the bootstrap theme so that it looks good on an iPhone.

Add `hobo_bootstrap` and `hobo_bootstrap_ui` to Gemfile and run `bundle`

In `app/assets/stylesheets/front.scss`, `admin.scss`, `app/assets/javascripts/front.js`, `admin.js`, `app/views/taglibs/front_site.dryml` and `admin_site.dryml`:

- change `hobo_clean` (or `hobo_clean_admin`) to `hobo_bootstrap`
- add `hobo_bootstrap_ui` after `hobo_jquery_ui`.

## Updating Index Views

The Clean theme uses a list of cards on index pages, the Bootstrap theme uses a table.   In the old version of the app, to customize this page we customized the card in application.dryml.

We went through and tweaked all of our index pages appropriately using [the instructions in the manual](http://hobocentral.net/tagdef/hobo_bootstrap/hobo_bootstrap/index-page).

In most cases, we switched to `<table-plus>`, the last suggestion [in the manual](http://hobocentral.net/tagdef/hobo_bootstrap/hobo_bootstrap/index-page).

# Tweaks

We made a few easy tweaks that Hobo 2.0 enabled.

## Thin

Adding 'thin' to Gemfile made a lot of annoying warning messages go away

## Turbolinks

We massively sped up our application by installing [Turbolinks](https://github.com/rails/turbolinks).   We added turbolinks to our Gemfile, and added `//= require turbolinks` to the *bottom* of both admin.js and front.js.

If you have custom Javascript, turbolinks will probably break it, but fixing it up is easy.   See the [README](https://github.com/rails/turbolinks) for more information.

## hot-input

Now that we're on 2.0 we can take advantage of some of the new features.  In particular, we updated the most frequently used page to take advantage of `<hot-input>` for a nice bump in usability.

# More information

The app that we upgraded was a fairly vanilla Hobo application.  Upgrades from Rails 2 to Rails 3 can be fairly involved; the fact that this was a Hobo application made this much easier because Hobo has changed a lot less than Rails has over the few years.   There are myriad articles on the web talking about upgrading to Rails 3.0 and Rails 3.2, you'll probably want to consult some of those.   You'll also want to refer to the [CHANGES document for Hobo 2.0](http://hobocentral.net/manual/changes20) and for [Hobo 1.3](http://hobocentral.net/manual/changes13).


