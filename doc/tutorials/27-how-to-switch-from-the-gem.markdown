# How to switch from the gem to edge as a plugin

Originally written by Bryan Larsen on 2009-04-24.

If you're currently running the Hobo gem, and wish to run Hobo as a plugin, here are the steps you should follow.

If you're using git:

    git submodule add git://github.com/tablatom/hobo.git vendor/plugins/hobo

otherwise:

    ./script/plugin install git://github.com/tablatom/hobo.git

Now edit `config/environment.rb` to remove the `config.gem 'hobo'` line.  Edit `Rakefile` to remove the line `require 'hobo/tasks/rails'` if it exists.

Before running the next step, I suggest that you check your project in to change control.

    rake hobo:run_standard_generators

You can now enter 'd' on any conflicts to determine whether you have any changes that will be overwritten, and then enter 'y' or 'n' as appropriate.

Alternatively, if you checked your project into change control as I suggested, answer 'y' to all of the questions.  OK, that's a little extreme -- you can answer 'n' to any of the `application.*` files.  Now use your change control system to determine if any of the changes you had previously made have been overwritten.  Files with changes that may have been overwritten include `user.rb`, `users_controller.rb` and `environment.rb`.

