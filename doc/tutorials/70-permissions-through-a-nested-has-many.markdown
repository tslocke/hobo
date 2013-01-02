# Permissions through a nested has_many relationship.

Originally written by jarad on 2011-05-11.

I have a app where the ability to assign many different users to review a project is needed. Each project should only be viewable by either the administrator or the assigned reviewers.

What I did was discover a handy gem named "nested\_has\_many\_through" which allowed the hobo permissions access to the nested data.

See [https://github.com/romanvbabenko/nested_has_many_through](https://github.com/romanvbabenko/nested_has_many_through) for more information about the gem in the recipe.
  
  
Be sure to add the gem. Put this line in your Gemfile:

    gem "nested_has_many_through"
  
and run:

    bundle install
  
  
  

The models:

Generate the project model:

    $ hobo g resource project.rb name:string

app/models/project.rb

    class Project < ActiveRecord::Base

    hobo_model # Don't put anything above this

    fields do
      name        :string
      description :text
      timestamps
    end

    has_many :reviews
    has_many :users, :through => :reviews

    # --- Permissions --- #

    def create_permitted?
      acting_user.administrator?
    end

    def update_permitted?
      acting_user.administrator? || acting_user.in?(users)
    end

    def destroy_permitted?
      acting_user.administrator?
    end

    def view_permitted?(field)
      acting_user.administrator? || acting_user.in?(users)
    end

Now generate your review model:

    $ hobo g resource review.rb name:string

app/models/review.rb

    class Review < ActiveRecord::Base
    
    hobo_model # Don't put anything above this
    
    fields do
      name :string
      timestamps
    end
    
    belongs_to :project
    has_many :review_assignments, :dependent => :destroy
    has_many :users, :through => :review_assignments, :accessible => true
    
    # Get a nice view of the relationships  
    children :review_assignments
    children :users
    
    # --- Permissions --- #


Then create your review assignment model:

    $ hobo g model review_assignment


app/models/review_assignment.rb

    class ReviewAssignment < ActiveRecord::Base
    
    hobo_model # Don't put anything above this

    fields do
      timestamps
    end
    
    has_many :users
    has_many :reviews
    
    # --- Permissions --- #

This is very handy if you want only admins to have the ability to create reviews and assign users. All that is needed is to move the reviews controller to the admin directory *(app/controllers/admin/)* and replace the first line of the file with this:

    class Admin::ReviewsController < Admin::AdminSiteController

  
or when creating your model run the following command (*I have not tried this so YMMV*)

    hobo g resource admin::reviews name:string

  
Now we're all set, run the following from the command line.

    $ hobo g migration


    $ rails s

  
Add some users and programs then go to reviews and assign users to their programs. This application has been posted on Github, so feel free to check it out. [https://github.com/jdowning/Has-Many-Reviewers](https://github.com/jdowning/Has-Many-Reviewers)

