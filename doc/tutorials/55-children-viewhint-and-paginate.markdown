# Children Viewhint and Paginate

Originally written by cbenedict on 2010-07-28.

This recipe answers [How do I get pagination to work for child collections on a show page defined with the children view hint?](/questions/58-how-do-i-get-pagination-to)

<h1>Intro</h1>
If you have models with belongs\_to and has\_many relationships and have used the children view hint on the parent model, you will get a collection of cards on the bottom of the main page or on the sidebar depending on how many child models you specify and in what order.  See (<http://cookbook.hobocentral.net/manual/viewhints#child_relationships>) for more information on this behavior.

You may have noticed, however, that automatic pagination does not happen.  :-(

It would be nice if the children viewhint supported parameters that would enable this.  Maybe the author of the generator spitting out the Rapid show page is reading this...heck, I might try a hack of it myself.

But until then, there are two ways to support this behavior.  This recipe documents them.

<h1>Prerequisites</h1>
Create a demo app.

    $ hobo paginate_children

<h2>Create models</h2>
Let's create models that support parent/children relationships.  How about Post and Comment?

    $ cd paginate_children
    $ ruby script/generate hobo_model_resource Post name:string
    $ ruby script/generate hobo_model_resource Comment name:string

Edit the models to define the parent/child relationship.
<pre>paginate_children/app/models/post.rb</pre>

    class Post < ActiveRecord::Base
        hobo_model # Don't put anything above this

        fields do
            name :string
            timestamps
        end

    +   has_many :comments

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

<pre>paginate_children/app/models/comment.rb</pre>
    class Comment < ActiveRecord::Base

        hobo_model # Don't put anything above this

        fields do
            name :string
            timestamps
        end

    +   belongs_to :post

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

<h2>Add children viewhint</h2>
<pre>paginate_children/app/viewhints/post_hints.rb</pre>
Add the viewhint for comments to the post model.

    class PostHints < Hobo::ViewHints
        # model_name "My Model"
        # field_names :field1 => "First Field", :field2 => "Second Field"
        # field_help :field1 => "Enter what you want in this field"
        # children :primary_collection1, :aside_collection1, :aside_collection2
    +   children :comments
    end

<h2>Overriding will_paginate default per_page value</h2>
In order for us to be able to see pagination work with only a few child entries, use this monkey patch to change the default per\_page value from 30 to 3.  Add this code to the end of paginate\_children/config/environment.rb:

    # Set will_paginate default per_page to 15 instead of the default 30
    ActiveRecord::Base.instance_eval do
        def per_page; 3; end
    end

<h2>Startup</h2>
Migrate your models and startup the server.

    $ ruby script/generate hobo_migration
    ...
    $ ruby script/server

At this point, you should be able to add the administrative user.  Go ahead also and add a post and add 4 comments attached to that post.

<h1>Two techniques</h1>
There are two techniques to achieve this.
1.  You create a paginated collection instance variable in the post controller and then override the show page to use this variable.  You also have to add the paginate tags so the pager controls show.
2.  Use the index owner action on the comment controller.

<h2>Collection instance variable</h2>
We need to set up pagination for the comments collection.  Add a comments instance variable to the posts\_controller.
<pre>paginate_children/app/controllers/posts_controller.rb</pre>

    class PostsController < ApplicationController

        hobo_model_controller

        auto_actions :all

    +   def show
    +       hobo_show do
    +           @comments = this.comments.paginate(:page => params[:page])
    +       end
    +   end
    end

Next, override the comments collection in the Post show page to use the instance variable just created and add the paginate tags.
<pre>paginate_children/app/views/taglibs/application.dryml</pre>

    <include src="rapid" plugin="hobo"/>

    <include src="taglibs/auto/rapid/cards"/>
    <include src="taglibs/auto/rapid/pages"/>
    <include src="taglibs/auto/rapid/forms"/>

    <set-theme name="clean"/>

    <def tag="app-name">Paginate Children</def>

    +<extend tag="show-page" for="Post">
    +    <old-show-page merge>
    +        <collection: replace>
    +            <page-nav with="&@comments" param="top-page-nav"/>
    +            <collection with="&@comments" />
    +            <page-nav with="&@comments" param="bottom-page-nav"/>
    +        </collection>
    +    </old-show-page>
    +</extend>

<h3>Test it out</h3>
If you added 4 or more comments to a post, that post's show page should show those comments paginated with 3 entries per page.

<h2>Index owner action</h2>
You can get pagination behavior out of the box by using the index owner action on the comment controller as defined below.
<pre>paginate_children/app/controllers/comments_controller.rb</pre>

    class CommentsController < ApplicationController

        hobo_model_controller

        auto_actions :all

    +   auto_actions_for :post, [:index]
    end

You can the use the url http://localhost:3000/posts/:id/comments to access the show page for the post id referenced by :id.  The comments collection will be paginated (and note that this is not because of the code from technique 1...see app/views/taglibs/auto/rapid/pages.dryml and look for index-for-post-page).  The problem with this technique (unless I am missing something) is that the wiring up of the navigation to this url is not done by the framework automatically.

