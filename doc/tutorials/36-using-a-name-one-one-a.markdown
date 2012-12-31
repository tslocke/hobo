# using a name-one one a model with a generated field for a name:

Originally written by Bryan Larsen on 2009-08-26.

Suppose you have a model that uses a generated field for its name:

    class User
      def name
        "#{first_name} #{last_name}"
      end
    end

Now suppose that you have an `Institution` that `belongs_to :contact, :class_name => "User"`.  And suppose you want to use a name-one to choose the contact:

    <extend tag="form" for="Institution">
      <old-form merge>
        <field-list:>
          <contact-view:>
            <name-one/>
          </contact-view:>
        <field-list:>
      </old-form>
    </extend>

The next step is to autocomplete support to the users controller.  I recently added support to `hobo_completions` to allow the completer to search more than one field.   (In other words, this will not work with Hobo 0.8.8, you need 0.8.9 or edge Hobo)  Let's take advantage of this:

    class UsersController < ApplicationController
      autocomplete :name, :query_scope => [:first_name_contains, :last_name_contains]
    end

Now the autocompleter should work.   However, if you submit the form, you get an error complaining that `find_by_name` doesn't exist.   Let's fix that:

    class User < ActiveRecord::Base

      def self.find_by_name(name)
        names = name.split(' ')
        (0..(names.length-2)).inject(nil) do |result, n|
          result ||= self.find_by_first_name_and_last_name(names[0..n].join(' '), names[1..(n+1)].join(' '))
        end
      end

The code is a little tricky simply because we wish to handle both "Vince van Vickel" and "Mary Sue Jones" appropriately.

