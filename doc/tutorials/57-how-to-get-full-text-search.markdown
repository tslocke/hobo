# How to get full text search working with Sunspot

Originally written by kevinpfromnm on 2010-08-06.

This recipe answers [How do I setup full text search?](/manual/faq/63-how-do-i-setup-full-text)

Basically we'll be following [sunspots quickstart guide](http://wiki.github.com/outoftime/sunspot/adding-sunspot-search-to-rails-in-5-minutes-or-less) with a couple of tweaks for hobo.

## Setup a hobo app

For this, I'll make the, at this point, stereotypical blog application.

    hobo search_demo
    cd search_demo
    ./script/generate hobo_model_resource Post title:string body:text
    script/generate hobo_migration

## Install Sunspot and dependencies

> First, you’ll need to install Sunspot::Rails, which integrates Sunspot search seamlessly into your Rails app. This will install Sunspot 
> and RSolr as dependencies.
> 
> `$ sudo gem install sunspot_rails`
> 
> Add it to your config/environment.rb:
> 
> `config.gem 'sunspot_rails', :lib => 'sunspot/rails'`
> 
> Run the generator to create the config/sunspot.yml file:
> 
> `$ script/generate sunspot`
> 
> To get the Sunspot rake tasks, you’ll need to require the tasks from your app’s Rakefile:
> 
> `require 'sunspot/rails/tasks'`
> 
> Now it’s time to start Solr. Solr is a standalone HTTP server, but Sunspot comes packaged with a copy of it that’s already configured to  
> work with Sunspot; use the rake task to fire it up:

Here's where I diverge from their path and add in that you need to copy the solr/conf and solr/lib directories from the gem installation directory if you have run `acts_as_solr` in the past.  That or delete the solr/ directory from your app before running this next command.

> `$ rake sunspot:solr:start`
> 
> The first time you run this command, it will create a solr/ directory in your Rails root. This contains Solr’s configuration, as well as
> the actual data files for the Solr index. You’ll probably want to add solr/data to your .gitignore. If you later would like to play 
> with Solr’s configuration (e.g., customizing the filter chain for text fields), you’ll find the configuration files in solr/conf.

## Tell sunspot what to index

Add this to your Post model

      searchable do
        text :title, :default_boost => 2
        text :body
      end

This tells sunspot to index the post model, with full text searching on the title and body fields with title matching being twice as relevant by default.

Now, tell sunspot to index any existing post data.  You can skip this step if you have a blank application and instead add a few posts.

`$ rake sunspot:reindex`

## Adding search to your controller

Here, we'll diverge a little because Hobo makes this easier for us.  We're going to add the search to the normal index method if a query parameter is supplied.

    class PostsController < ApplicationController

      hobo_model_controller

      auto_actions :all

      def index
        if params[:query]
          @posts = Post.search do
            keywords(params[:query])
            paginate(:page => (params[:page] or 1), :per_page => 10)
          end.results
          @posts.member_class = Post
        else
          hobo_index
        end
      end
    end

A quick explanation is in order, Post.search is sunspots search method.  The block describes how to search and return results.  Right after the block, the .results is not a typo.  Sunspots search method returns a search type object with search scores and objects but for a quick and dirty search, we're just interested in the, well, results.

Now, we can actually test this out at this point by going to `http://localhost:3000/posts?query=someword`.  Be sure to pick a word you know is in at least 1 but not all posts.

Obviously we can't leave it like that for the end user but we're most of the way there.

## Add search to view

We need to tweak the index page to show a search box.

`app/views/posts/index.dryml`

    <index-page>
      <before-collection:>
        <form action="&object_url(Post)" method="GET">
          <label for="query">Search Posts</label>
          <input type="text" name="query" value="#{@query}" />
          <submit label="Search" />
        </form>
      </before-collection:>
    </index-page>


And have the controller save the query parameter for the view by changing the if line as follows.

`app/controllers/posts_controller.rb`

    + if @query = params[:query]
    - if params[:query]

And now search is easily accessible.

Exercises left for the reader: 
* possibly change live-search box to use sunspot or remove entirely from view
* explore other Post.search options to increase usefulness
* perhaps each post has an owner and/or comments that you want to search to include.  add these to the searchable method in the Post model
* this isn't production ready as you'll want a separate solr server that isn't the one bundled with sunspot

