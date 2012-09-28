View Hints
{: .document-title}

This API is used internally in Hobo, for example in the Rapid tag library, to create a user interface according to your declarations. That's really all there is to it.

It's important to note that the view-hints mechanism is entirely optional, and may not be appropriate for all applications (especially larger applications). Everything you can do with view-hints can be done with much more flexibility by defining DRYML tags and page templates. What view-hints give you is a way to achieve common UI customisations very quickly and easily.

## Child relationships

Many web applications arrange the information they present in a hierarchy. By declaring a hierarchy using the `children` declaration, Hobo can give you a much better default user interface.

At present, the `children` declaration only influences Rapid's show-page -- it governs the display of collections of `<card>` tags embedded in the show-page. If you declare a single child collection, e.g.:

    class User < ActiveRecord::Base

      ....
      children :recipes

    end

## Parent relationships

Defining a child relationship also defines a parent relationship on
the first child.  If this is not sufficient or correct, you may
explicitly define the parent relationship:

    class Recipe < ActiveRecord::Base
      view_hints.parent :user
    end

To remove the automatic relationship, you can pass nil:

    parent nil

{.ruby}

The a collection of the user's recipes will be added to the main content of `users/show`.

You can declare additional child relationships. The order is significant, with the first in the list being the "primary collection". For example:

    class User < ActiveRecord::Base

      children :recipes, :questions, :answers

    end
{.ruby}

With this declaration, the user's show-page will be given an aside section (sidebar), in which cards for the `questions` and `answers` collections are displayed.


# The API

The view-hints API is used internally by Hobo Rapid. You may not ever need to use it yourself. For completeness it is documented here.

The view-hints for any model can be access using the `view_hints` method:

    MyModel.view_hints
{.ruby}

That will return the view-hints class from which the hints can be accessed. Each of the declaration methods can be called without arguments to retrieve the declared values. e.g.

    >> BlogPost.view_hints.model_name
    => "Post"


## Helpers

The following view helpers are defined to simplify access to view-hints information during rendering:

 - `this_field_name` -- returns the view-hints translated name of the field currently referenced by DRYML's `this_field`. That is, the field of the current context

 - `this_field_help` -- returns the translated help text associated with the field currently in context.


## Legacy Hints

Hobo >= 1.3.* generators do not generate view hints files anymore.
Their functionality has been moved elsewhere, but some backwards
compatibility has been maintained.  If you used any old version of
Hobo you might be interested in reading this section, if you are new
to Hobo, just skip it.

## Renaming

The old view hints renaming has been moved into the locale files. That
happens because keeping module and attribute names hardcoded in
strings was i18n hostile. Locale files have been introduced to support
rails i18n and have their own conventions, and work well for english
to english translations too. Hobo just uses that already implemented
tool following the already established conventions.

Here is the uncommented default config/locale/app.en.yml file

    en:
      hello: "Hello world"

      attributes:
        created_at: Created at
        updated_at: Updated at

      activerecord:
        models:
          user:
            one: User
            other: Users
        attributes:
          user:
            created_at: Created at
            name: Name
            password: Password
            password_confirmation: Password Confirmation
            email_address: Email Address
        attribute_help:
          user:
            email_address: We will never share your address with third parties

Notice:

- Yaml files use a fixed number of spaces (2) to indent levels. Tabs are illegal
- Quote marks are not mandatory
- The locale file structure is a rails convention: you can have more details by reading the [rails 3 i18n guide](http://edgeguides.rubyonrails.org/i18n.html)

You can rename models and attributes by changing or adding key/values in the specific activerecord.models and activerecord.attributes sections, adding also any attributes help you might need in the activerecord.attribute_help section (which is a hobo specific section). For example:

    en:
      hello: "Hello world"

      attributes:
        created_at: Created at
        updated_at: Updated at

      activerecord:
        models:
          user:
            one: User
            other: Users
          contact:
            one: Friend
            other: Friends
        attributes:
          user:
            created_at: Created at
            name: Name
            password: Password
            password_confirmation: Password Confirmation
            email_address: eAddress
          contact:
            name: Nickname
            email_address: eAddress
        attribute_help:
          user:
            email_address: We will never share your address with third parties
          contact:
            name: This is the nickname

Just be careful: don't mess up the indentation!

Note that the key/values inside the first `attributes:` group are used as the default for all models.

## Hints

The ViewHints.children and theViewHints.inline_booleans methods have been moved into the model, but they are used in the exactly same way they were used before.

The view_hints are now a subclass of Hobo::Model::ViewHints instead of
Hobo::ViewHints. You can access the view_hints class by accessing the
Model.view_hints method, so for example User.view_hints.children will
return the children of the User model. The same applies to the parent,
parent_defined, sortable? and paginate? methods which remain in the
view hint class.

## Deprecated methods

- model_name
- model_name_plural
- field_name
- field_names

When called they raise an error with an explanation.

