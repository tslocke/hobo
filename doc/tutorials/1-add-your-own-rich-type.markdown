# Add your own rich type

Originally written by Tom on 2008-10-16.

Say your application features currency value, and you'd like them all formatted nicely. A great way to implement this in Hobo is by creating a new type, e.g. `Dollars` and customising the way those values are displayed. That way your dollar values will be displayed correctly throughout the site and you won't need to think about that issue again.


## Start with a blank app

To make this how-to very concrete let's start from scratch with a new application:

        $ hobo my_app
        $ cd my_app
        $ ./script/generate hobo_model_resource product name:string

## Create the type

Now we'll dive right in and create the new type. Create `app/models/dollars.rb` like this:

        class Dollars < DelegateClass(BigDecimal)

          COLUMN_TYPE = :decimal

        end
{: .ruby}

Let's talk that through. It's common with Rich types to create a new subclass of the 'normal' type that ActiveRecord would use. For example, Hobo's `HtmlString` is a subclass of `String`. Unfortunately, subclassing `BigDecimal` is problematic for reasons we won't bother going in to. Fortunately Ruby saves us with the very nifty `DelegateClass`. This allows us to walk like a `BigDecimal` and talk like a `BigDecimal`, which is perfectly good enough in Ruby.

We then declare 

        COLUMN_TYPE = :decimal
{: .ruby}

which tells the migration generator what type of column to generate for these things. That's arguably redundant seeing as we already defined these things as being a special kind of `BigDecimal`. This step might go away in the future.


## View layer

To render these dollar values nicely in the app, we need to define a custom `<view>` tag. So in application.dryml we need:

    <def tag="view" for="Dollars">$<%= number_to_currency(this) %></def>
{: .dryml}


## Declare a field with the custom type

Now our type is ready to go. We can edit `app/modes/product.rb` like this:

        class Product < ActiveRecord::Base

          hobo_model

          fields do
            name :string
            price Dollars, :precision => 12, :scale => 2
            timestamps
          end
         
          ...
        end
{: .ruby}

Notice the type of the `price` column is given as the class constant `Dollars`. We can pass the same options that we could to a regular `:decimal` column

# Create the database

If we now run the migration geneartor:

        $ ./script/generate hobo_migration

You'll see that the price column is `:decimal` type (the users table has been omitted for brevity):

        ---------- Up Migration ----------
        create_table :products do |t|
          t.string   :name
          t.decimal  :price, :scale => 2, :precision => 12
          t.datetime :created_at
          t.datetime :updated_at
        end
        ----------------------------------

        ---------- Down Migration --------
        drop_table :products
        ----------------------------------
{: .ruby}

## Try it out

That's it! You can now fire up the app and sign up to become the administrator. Create a product with a price, and see the nice dollar formatting.

## Bonus - a custom input for dollars

Add this to `app/views/taglibs/application.dryml`

        <def tag="input" for="Dollars" attrs="name">
          $ <%= text_field_tag(name, this, attributes) %>
        </def>
{: .dryml}

You'll now have a dollar sign in front of every dollar field in your forms.

