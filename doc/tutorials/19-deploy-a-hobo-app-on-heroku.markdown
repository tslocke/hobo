# Deploy a Hobo app on Heroku

Originally written by Tom on 2008-11-10.

This recipe will take you through the process of getting a Hobo app deployed on [Heroku Garden](http://herokugarden.com). We'll work through creating a brand new app and getting it deployed, and then discuss how you would use the same approach with an existing app.

**Prerequisites:** you will need git and the herokugarden gem (`gem install herokugarden`)

# Deploying a new Hobo app with Heroku Garden

**1. Log in to Heroku Garden and create the new app.** Rather annoyingly, Heroku doesn't prompt you for the app name, so we'll start by renaming the app. Click on your email address down in the Heroku bar on the right. That will take you back to "My Apps". Then click "Settings" for the new app, and you'll be able to rename it. Keep the browser open on that page.

For the recipe we'll assume you've called it `hoboapp`, but remember that all Heroku apps live in one global namespace, so you'll need to use your own name. Use your name wherever you see `hoboapp`.

**2. Grab a local clone of the app**:

    $ herokugarden clone hoboapp
    $ cd hoboapp

**3. Switch to Rails 2.2.2.** By default a new Heroku Garden app will be configured to use Rails 2.1, but Hobo needs Rails 2.2.2. Edit `config/environment.rb` and change the `RAILS_GEM_VERSION` to:

    RAILS_GEM_VERSION = '2.2.2'

(Should be the first line of the file).

**4. Add Hobo as a git submodule.** This adds an extra step to making things work with Heroku, but Hobo is a moving target and being able to keep up to date with changes is critical. Having Hobo as a submodule makes this much easier.
    
    $ git submodule add git://github.com/tablatom/hobo.git vendor/plugins/hobo
    
When we push our changes, Heroku will not grab the Submodule for us. The easiest way to fix that is to write a simple Rake task that will update any submodules in the app.

**5. Create a rake task to do the submodule update.**. Create a file `lib/tasks/git_submodules.rake` containing the following: 

    task :git_submodules do
      puts `git submodule init 2>&1`
      puts `git submodule update 2>&1`
    end
    
**6. "Hoboize" the blank Rails app.** We'll run the standard Hobo generators:

    ruby script/generate hobo --add-routes
    ruby script/generate hobo_rapid --import-tags
    ruby script/generate hobo_user_model user
    ruby script/generate hobo_user_controller user
    ruby script/generate hobo_front_controller front --delete-index --add-routes

**7. Run the migration generator** to create the initial migration, which will just create the `users` table.

    ruby script/generate hobo_migration
    
(Chose the 'g' or 'm' option)

**8. Commit the code into the repo**:

    $ git add .
    $ git commit -am "Hoboize the app"
    
**9. push your code up to Heroku**. Note that you will get an error about the Hobo gem not being available. That's OK.

    $ git push
    
**10. Run the rake task that we defined above.** The heroku gem allows us to run remote rake tasks:

    $ herokugarden rake hoboapp git_submodules
    
It may take a while, but you should eventually see the normal output from the `git submodule init` and `git submodule update` commands.
    
**11. Run migrations.** We can use the `herokugarden` remote rake tasks again:

    herokugarden rake hoboapp db:migrate

**12. run Hobo's taglib generators.** Return to your terminal and run:

    $ herokugarden rake hoboapp hobo:generate_taglibs
    
**13. Install `will_paginate`.** In the file browser on Heroku's edit page, expand the 'vendor' folder and click "Gems and plugins". Select "Available" instead of "Installed" from the menu, and search for `will_paginate`. I found that installing the gem version did not work, so install the plugin version.
    
You should now be able to click the "view" link in the top right of the Heroku editor and see your deployed app up and running.

# Deploying an existing app.

As far as I know, Heroku want to host the git repo for you, so again we'll need to create a blank Heroku app. Perform steps 1 to 4 exactly as above.

Steps 6 and 7 should not be necessary if we already have a running app. We want instead to copy our existing code into this repo, overwriting the files that are already there, but make sure you don't overwrite the `.git` directory. Also, if your app already has Hobo in `vendor/plugins`, don't copy that over, as you've just created a submodule for Hobo.

Having copied the files in we want to commit them to git, push them up to Heroku and so on. In other words, perform steps 7 to 13 exactly as above.

