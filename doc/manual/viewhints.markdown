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

The collection of the user's recipes will be added to the main content of `users/show`.

You can declare additional child relationships. The order is significant, with the first in the list being the "primary collection". For example:

    class User < ActiveRecord::Base

      children :recipes, :questions, :answers

    end
{.ruby}

With this declaration, the user's show-page will be given an aside section (sidebar), in which cards for the `questions` and `answers` collections are displayed.


# The API

The view-hints API is used internally by Hobo Rapid. You may not ever need to use it yourself. For completeness it is documented here.

The view-hints for any model can be accessed using the `view_hints` method:

    MyModel.view_hints
{.ruby}

That will return the view-hints class from which the hints can be accessed. Each of the declaration methods can be called without arguments to retrieve the declared values. e.g.

    >> BlogPost.view_hints.model_name
    => "Post"


## Helpers

The following view helpers are defined to simplify access to view-hints information during rendering:

 - `this_field_name` -- returns the view-hints translated name of the field currently referenced by DRYML's `this_field`. That is, the field of the current context

 - `this_field_help` -- returns the translated help text associated with the field currently in context.


