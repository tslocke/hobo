# Hierarchies - Using acts_as_tree

Originally written by cbenedict on 2010-06-27.

<h1>Intro</h1>
The acts\_as\_tree gem (<http://rubygems.org/gems/acts_as_tree>) provides support for organizing rows in a table into a parent/child hierarchy.  This is useful for structures where entries have subentries and so on.  Category listings often have this structure.  Hobo does not have native support for this gem, so this is my attempt to add some support.  I welcome feedback on how to make this more flexible/usable.

<h1>Prerequisites</h1>
First, you need to get the acts\_as\_tree gem.

    $ sudo gem install acts_as_tree

Now create a demo app.

    $ hobo tree_demo

Add the gem to your environment.rb so that the gem autoloads into your application at startup.
<pre>tree_demo/config/environment.rb</pre>

    # Be sure to restart your server when you modify this file

    # Specifies gem version of Rails to use when vendor/rails is not present
    RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

    # Bootstrap the Rails environment, frameworks, and default configuration
    require File.join(File.dirname(__FILE__), 'boot')

    Rails::Initializer.run do |config|
        config.gem 'hobo'
    +   config.gem 'acts_as_tree'
    ...

<h1>Create a model</h1>
Let's create a model of Categories that support's parent/child relationships.

    $ ruby script/generate hobo_model_resource Category name:string parent_id:integer

Edit the new model to define the hierarchical relationship.
<pre>tree_demo/app/models/category.rb</pre>

    class Category < ActiveRecord::Base
        hobo_model # Don't put anything above this

        fields do
            name      :string
            parent_id :integer
            timestamps
        end

    +   acts_as_tree :order => :name

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

Migrate the model modification and start the server.

    $ ruby script/generate hobo_migration
    ...
    $ ruby script/server

<h1>Add new tag definition</h1>
 
Add the following tag definition to a new tag library.  This new tag displays a hierarchical unordered list of a model that has acts\_as\_tree defined.  Credit to <http://snippets.dzone.com/tag/acts_as_tree> for the original code snippet to do this.  I adapted it to work with hobo. 
<pre>tree_demo/app/views/taglibs/tree.dryml</pre>

    <!-- My hack to display an unordered list of links for acts-as-tree hierarchy.
         If you pass to="collection" attribute, the links will change to 
         index_for_collection view of the parent -->
    <def tag="links-for-tree" attrs="to">
        <%
            def tree_ul(acts_as_tree_set, init=true, &block)
                if acts_as_tree_set.size > 0
                    %><ul><%
                    acts_as_tree_set.collect do |item|
                        next if item.parent_id && init 
                        %><li><%
                        yield item
                        tree_ul(item.children, false, &block) if item.children.size > 0
                        %></li><%
                    end
                    %></ul><%
                else
                    %>(none)<%
                end
            end
            def emit_link(my_item, to)
                item_for = to.nil? ? my_item : my_item.send(to)
                %><a with="&item_for"><%= my_item.name %></a> <%= "(#{item_for.count})" if item_for.respond_to?('count') %><%
            end        
        %>
        <% tree_ul(this, true) {|item| emit_link(item, to) } %>
    </def>

<h1>Modify view to display hierarchy</h1>
Open up the applications.dryml file.  We are going to override the default categories index page and replace the collection of Categories with the new links-for-tree tag.  You also have to add an include for the new tag library file created that contains the links-for-tree tag.
<pre>tree_demo\app\views\taglibs\application.dryml</pre>

    <include src="rapid" plugin="hobo"/>

    <include src="taglibs/auto/rapid/cards"/>
    <include src="taglibs/auto/rapid/pages"/>
    <include src="taglibs/auto/rapid/forms"/>
    +<include src="taglibs/tree"/>

    <set-theme name="clean"/>

    <def tag="app-name">Tree Demo</def>

    +<extend tag="index-page" for="Category">
    +    <old-index-page merge>
    +        <collection: replace>
    +            <links-for-tree/>
    +        </collection:>
    +    </old-index-page>
    +</extend>

<h1>Test it out</h1>
Go to the Categories link and add some new categories.  Be sure to add subcategories and set up their parent.  When you go back to the Categories index page, you should see a hierarchy list of links to categories instead of a flat collection.

<h1>Further steps</h1>
<h2>Relationships</h2>
The links-for-tree tag supports index\_for\_\* relationships, meaning that if you pass the 'to=' attribute, where 'to' represents the name of a has\_many relationship on the passed in context, then the links that will be rendered will be links to the related object that belongs to the context.

For example, if Tasks belong to a Category, and you wanted to create a Category side bar on the Tasks index page that would link to index\_for\_category to narrow the scope to show only those tasks that belong to the clicked category, you would code:

    <links-for-tree with="&Category.all" to="tasks" />
<h2>New collection tag</h2>
After writing this tag, it occurred to me that the existing collection tag (or perhaps a new one) could be modified to show categorized cards that belong to a model that has a parent/child relationship.  I could envision some jQuery magic that would roll down/up sections that contain cards by clicking on the model names of the hierarchical relationship.  For next time...

