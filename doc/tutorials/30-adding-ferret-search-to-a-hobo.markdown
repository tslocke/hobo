# Adding ferret search to a hobo application

Originally written by kevinpfromnm on 2009-07-06.

# Prerequisites #

First, you need the ferret gem.

<code>$ sudo gem install ferret</code>

Next, let's create a hobo app to use with ferret.

<code>$ hobo ferret_app</code>

Now, we need the <code>acts_as_ferret</code> plugin.

<code>$ ruby script/plugin install git://github.com/jkraemer/acts_as_ferret.git</code>

# Setup the model #

Let's make a model that will have a ferret index on it.

<code>$ ruby script/generate hobo_model_resource Post title:string body:text</code>

Now we'll tell ferret we want to have an index on the model and what fields we want indexed.

<code>ferret_app/app/models/post.rb</code>

    class Post < ActiveRecord::Base
    
      hobo_model # Don't put anything above this  
    
      fields do
        title :string
        body  :text
        timestamps
      end
    
    +  acts_as_ferret :fields => [:name, :body]
    +  
    +  def name
    +    title
    +  end
    
      # --- Permissions --- #
      
      def create_permitted?
        acting_user.administrator?
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

Note: the only reason I used a method for name was to indicate that ferret can index on more than just columns.  You can index any string a method returns so you can do indexes across complex joins or filtered text etc.

Now let's have hobo generate the migration and start up the server.

    $ ruby script/generate hobo_migration
    ...
    $ ruby script/server

Go ahead and create a user and add some sample posts.  Remember, you'll need unique content for at least 1 or 2 of them as we'll be testing out a search function.

# Test Searching #

Start up a console and run a couple of queries.

    $ ruby script/console
    Loading development environment (Rails 2.0.2)
    >> Post.find_with_ferret('test')
    => [#<Post id: 2, title: "test", body: "a test post", created_at: "2009-07-06 23:57:05", updated_at: "2009-07-06 23:57:05">]
    >> Post.find_with_ferret 'stranger'
    => [#<Post id: 1, title: "a sample post", body: "t gets stranger.\r\n\r\nThe error message says:\r\n      ...", created_at: "2009-07-06 22:55:33", updated_at: "2009-07-06 22:55:33">]

Ferret sorts it's results by relevance according to your search term.  You can do things like set weights on particular fields to make say, posts that match title come up sooner than posts that just match in the body.

# Pagination of Search Results #

So, now we can get results but how do we get them paginated?  This is likely to be a concern as if you're using ferret you most likely have more than just 10 rows (the default limit) in your table.

To make pagination easier, we'll extend the ActsAsFerret module with a paginated search method.  Create the following in a file:

<code>lib/ferret_pagination.rb</code>

    module ActsAsFerret
      module ClassMethods
        def paginate_search(query, options = {}, find_options = {})
          page     = options[:page] || 1
          per_page = options[:per_page] || 10
          total    = options[:total_entries]
          
          pager = WillPaginate::Collection.new(page, per_page, total)
          options.merge!(:offset => pager.offset, :limit => per_page)
          result = find_with_ferret(query, options, find_options)
          returning WillPaginate::Collection.new(page, per_page, result.total_hits) do |p|
            p.replace result
          end
        end
      end
    end

This is modified from a post describing how to do pagination with ferret to work properly with hobo and WillPaginate.

Note: this might not be necessary given the new find_with_ferret method that returns results similarly to normal finder methods.

Add a line to your environment.rb file to load in the new file.

<code>config/environment.rb</code>
    ...
    +require 'ferret_pagination.rb'

Remember, you'll need to restart the server to reload the environment for this to take effect.

# Setting up the controller #

We'll go ahead and modify the posts index method to use our new ferret pagination method.

<code>app/controllers/posts_controller.rb</code>

    def index
      # return everything if no search parameter
      query = params[:search].blank? ? '*' : params[:search]
      @posts = Post.paginate_search(
            query, 
            {:page => (params[:page] or 1), 
            :per_page => 10 } )  # you can also past an additional hash with finder options if needed
      @posts.member_class = Post # allows hobo index page to work as is
    end

If there is no search parameter supplied, it instead uses * to grab everything.

Test this out by adding ?search=searchterm in your address bar.  You should see only items that contain matches to your term come back.

# Finishing Up #

Last step is to add a search field to your index page for easy searching.

Looking up the index-page for Post in app/views/taglibs/auto/pages.dryml show this:

    <def tag="index-page" for="Post">
      <page merge title="Posts">
        <body: class="index-page post" param/>
        
        <content: param>
          <header param="content-header">
            <h2 param="heading">Posts</h2>
    
            <p param="count" if>There <count prefix="are"/></p>
          </header>
          
          <section param="content-body">
    
            <a action="new" to="&model" param="new-link"/>      
    
            <page-nav param="top-page-nav"/>
          
            <collection param/>
          
            <page-nav param="bottom-page-nav"/>
          </section>
        </content:>
      </page>
    </def>

Adding our search box after the content-header looks like a decent approach.

<code>app/views/posts/index.dryml</code>

    <index-page>
      <after-content-header:>
        <form action="posts" method="GET">
          <label for="search">Search Posts:</label><input type="text" name="search" />
        </form>
      </after-content-header:>
    </index-page>

You can also use the search field from a table plus, however sorting either needs to be dropped or redone because ferret sorts on relevance.

# Further Steps #

Obviously, the search form could stand to be integrated better style-wise with the rest of the app.  So adding some css styles to clean that up would be in order.

Ferret has advanced query features, like fuzzy searches, phrase search, field weighting, searching specific fields etc.  It might be useful to have a popup with information on advanced search syntax and/or adjust the weights of each field in the index.  Also, adding the created_at/updated_at fields might be useful as you can search over time ranges as well.  Updating the form or adding an advanced search form that helps build these extended searches could be useful.  Check this page for some more information http://www.railsenvy.com/2007/2/19/acts-as-ferret-tutorial (while it refers to an older version, other than the model calls it is mostly correct) or the project wiki which is up to date but a bit harder to follow http://rm.jkraemer.net/wiki/aaf.

As you develop your models, remember that ferret keeps the index up to date by using the save/destroy hooks.  So, using any ActiveRecord methods which make changes without instantiating the model will cause the index to lose sync with what's in the database.  This can make for a very aggravating bug to track down.  So avoid ActiveRecord::Base.update and delete in ferret indexed models.

Last but probably most important is this... if you're going to have multiple server or even a multi-threaded server hosting your app, you'll want to setup a ferret server.  This hosts your index and handles it with transactions to keep your index current.

