# Create an admin subsite

Originally written by James on 2008-10-16.

This recipe answers [Using hobo_subsite to generate an admin interface?](/manual/faq/33-using-hobo-subsite-to-generate-an)

A `hobo_subsite` generator has been added to Hobo since this guide was written. The following should still work but is a bit out of date.
{: .note}

A sub-site is part of a web-app that has the appearance and behavior of a separate site. The most
common example of a sub-site is an "admin" section. This guide shows how to create a typical
admin sub-site in Hobo.

The typical approach to creating a sub-site is to duplicate the required model controllers. So you
might have a public facing view of the users at `/users` and the administrators view of the same
model at `/admin/users`. These would be managed by two distinct controllers, each with their own
set of enabled actions which might not necessarily be the same. For example the admin users controller
might have a "new" action at `/admin/users/new`, while the public facing users controller might
not enable this action at all if it isn't appropriate.

### Step by Step

At the time of writing, Hobo's generators are unable to generate sub-site controllers so it is 
necessary to create the files manually.

Create a new directory `app/controllers/admin/`

Create a base controller for the sub-site in `app/controllers/admin/admin_controller.rb`:

    class Admin::AdminController < ApplicationController
  
      hobo_controller

      # require administrator to access any controller in the sub-site
      before_filter :admin_required
      def admin_required
        redirect_to login_url unless logged_in? && current_user.administrator?
      end

      # the default page when visiting the sub-site
      def index
        redirect_to '/admin/users'
      end
    end
{: .ruby}

Now create a model controller in the admin sub-site. As an example we will create a controller to manage users. The following goes in `app/controllers/admin/users_controller.rb`:

    class Admin::UsersController < Admin::AdminController

      hobo_model_controller User
  
      auto_actions :index, :edit, :destroy, :update
  
    end
{: .ruby}
  
Notice two things that are slightly different to normal:

* The controller inherits from `Admin::AdminController` instead of `ApplicationController`
* You have to explicitly specify the name of the model as an argument to `hobo_model_controller`. In a non-sub-site controller Hobo can usually work this out automatically so it isn't needed.

Add a route for the home page of the sub-site in `config/routes.rb`:

    map.admin  'admin', :controller => 'admin/admin', :action => 'index'
{: .ruby}

This will enable the route `/admin` which will redirect automatically to
`/admin/users` as we set up above.

In the base controller we wrote `include_taglib 'admin'`. This means that the tags
in `app/views/taglibs/admin.dryml` will be loaded for every action in the sub-site.
This is a convenient place to re-define `<page>`, set a theme and define any tags that
are specific to the sub-site. As an example, create `app/views/taglibs/admin.dryml`
and add the following:

    <def tag="page" extend-with="admin" attrs="layout">
      <% layout ||= 'aside' %>
      <page-without-admin layout="#{layout}" merge>
        <scripts: param>
          <param-content/>
          <javascript name="admin"/>
        </scripts:>
        <stylesheets: param>
          <param-content/>
          <stylesheet name="admin"/>
        </stylesheets:>
        <main-nav: replace>
          <navigation class="main-nav">
            <nav-item with="&User">Users</nav-item>
          </navigation>
        </main-nav:>    
      </page-without-admin>
    </def>
{: .dryml}

Here we've defined an admin specific version of `<page>` that uses an aside layout by
default. We've also added admin specific javascript and stylesheet files which you will
need to create in `public/javascripts/admin.js` and `public/stylesheets/admin.css`. Finally
we have defined our admin specific nav bar containing a link to our users model controller
because Hobo excludes users from the nav bar by default.

We'll want to tweak Rapid's generic pages to be a bit more admin oriented. By adding the following
to `admin.dryml` we can replace the normal list on an index page with an admin style table:

    <def tag="index-page" extend-with="admin">
      <index-page-without-admin merge>
        <collection: replace>
          <table-plus fields="this" param/>
        </collection:>
      </index-page-without-admin>
    </def>
{: .dryml}

If we add additional model controllers to the admin sub-site they will all use this modified
version of `<index-page>`. Similar admin specific tweaks can be made to the other generic pages
and tags.

Notice the `fields` attribute on `<table-plus>`. This attribute is given a list of fields that will appear as columns in the table. Our shared definition of `<index-page>` can't put anything model-specific in there, so we just use "this" which will give a single column with links to each show-page. The good thing is that it's easy to customise this for specific models. For example, say we'd like to add an `email_address` column for the `User` model, just create `app/views/admin/users/index.dryml` like this:

	<index-page>
	  <table-plus: fields="this, email_address"/>
	</index-page>
{: .dryml}
	
Notice that the call to `<index-page>` picks up our customised version, since we've overridden it for the entire admin sub-site.


