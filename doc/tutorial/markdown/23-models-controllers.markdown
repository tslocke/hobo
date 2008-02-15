## Adding Models and Resource Controllers

### Create the models

The POD demo has a simple data-model. Let's start with a look at three models and the relationships between them. There are many users, (Hobo has already created the user model for us), a user has many adverts, and conversely each advert belongs to a user. There are also categories, such as Computers, Musical Instruments, etc. Each advert belongs in one category, and conversely, each category contains many adverts.

In Rails terms, we would write:

    class User < ActiveRecord::Base
      has_many :adverts
    end

    class Advert < ActiveRecord::Base
      belongs_to :user
      belongs_to :category
    end

    class Category < ActiveRecord::Base
      has_many :adverts
    end
{: .ruby}

The models need some data in them. Users won't need any extra fields beyond what hobo gives us automatically, but adverts will need a title and a body, and categories will need a name. With Hobo we declare the fields inside the models. We would code this as follows (don't do anything yet -- this is just to give you an overview of the data-model):

    class Advert < ActiveRecord::Base
      fields do
        title :string
        body  :text
      end
      belongs_to :user
      belongs_to :category
    end

    class Category < ActiveRecord::Base
      fields do
        name :string
      end
      has_many :adverts
    end
{: .ruby}

OK let's go ahead and create these models. As mentioned, `User` is already done. Let's generate `Advert` and `Category`

(Tip: keep the development server running in its terminal, and open up a new terminal in which to run these commands. That way you can just refresh the browser when you want to see the changes to the web-app)

    ruby script/generate hobo_model advert
    ruby script/generate hobo_model category

We need to edit the files that have been created in `app/models`. Let's start with `advert.rb`. Open it up in your editor, it should look like:

    class Advert < ActiveRecord::Base

      hobo_model

      fields do
        timestamps
      end


      # --- Hobo Permissions --- #
      # Ignore everything below here for now
    end
{: .ruby}
    
There are a few differences from the skeleton file we described above. Firstly, there are four stub methods for Hobo's permission system -- we'll ignore those for now. There's the `hobo_model` declaration, which all Hobo-enhanced models need, and there's the word `timestamps` in the `fields` block. `timestamps` tells Hobo to add the standard `created_at` and `updated_at` fields to this model (Active Record will maintain these fields automatically).

We need to add the two associations:

    belongs_to :user
    belongs_to :category
{: .ruby}

And the two fields:
    
    fields do
      title :string
      body  :text
      timestamps
    end
{: .ruby}
    
The file should end up looking like this:
    
    class Advert < ActiveRecord::Base

      hobo_model

      fields do
        title :string
        body  :text
        timestamps
      end

      belongs_to :user
      belongs_to :category

      # --- Hobo Permissions --- #
      # Don't change anything below here yet
    end
{: .ruby}

Similarly, edit the `app/models/category.rb` to look like this:

    class Category < ActiveRecord::Base

      hobo_model

      fields do
        name :string
        timestamps
      end

      has_many :adverts


      # --- Hobo Permissions --- #
      # Don't change anything below here yet
    end
{: .ruby}
    
Finally, we need to add just one thing to `app/models/user.rb` -- the `has_many :adverts` declaration. The file should end up looking like this:

    class User < ActiveRecord::Base

      hobo_user_model

      fields do
        username :string, :login => true, :name => true
        administrator :boolean
        timestamps
      end
  
      has_many :adverts

      set_admin_on_first_user

      # --- Hobo Permissions --- #
      # Don't change anything below here yet
    end
{: .ruby}
    
With those changes in place, we're ready to create the database tables:

    ruby script/generate hobo_migration
    
That should output:

    --------- Up Migration ----------
    create_table :adverts do |t|
      t.string   :title
      t.text     :body
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
      t.integer  :category_id
    end

    create_table :categories do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end
    ----------------------------------

    ---------- Down Migration --------
    drop_table :adverts
    drop_table :categories
    ----------------------------------
    What now: [g]enerate migration, generate and [m]igrate now or [c]ancel?
{: .ruby}
    
Notice how the generator knows to create the two foreign keys on the adverts table according to Active Record conventions. Respond with `m` and give something like "add adverts and categories" as the migration name.

That's the basics of the model layer in place. You won't see any changes in the app yet though, because there are no controllers for our new models.

### Create the controllers

We'll look at controllers in a bit more detail later. For now we just need some controllers in place so we can play with the app. We can generate them like this:

    ruby script/generate hobo_model_controller advert
    ruby script/generate hobo_model_controller category
    
Note that you provide the *singular* model name to the generator.

Refresh the browser and you should see:

<img src="images/front-with-models.png">

You can also browse to "Adverts" and "Categories" pages.


