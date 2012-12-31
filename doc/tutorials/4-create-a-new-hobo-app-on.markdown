# Create a new Hobo app on edge Hobo

Originally written by Tom on 2008-10-17.

# Install git

First up, you need to have git installed:

 - [git for windows](http://code.google.com/p/msysgit/)
 - [git for Mac OS](http://bc.tech.coop/blog/070827.html)
 - Linux user? I'm sure you don't need any help : )

# Understand the `hobo` command.

The main difference when working with edge Hobo is that you don't use the `hobo` command, as this command comes from the version of Hobo you have installed from the gem. Instead you want to manually replicate what this command does for you. There's not much to it -- it just runs a few generators.

To make this easier, the `hobo` command actually tells you what it's doing, with lines that start `-->`

e.g, if you run the `hobo` command you will see lines like:

    --> ruby script/generate hobo --add-routes

If you run all of these commands (listed below) in a blank Rails app, you will have a Hobo app. The advantage is that you can install edge Hobo first

# How to do it

## 1. Create a Rails app

    $ rails my_app

## 2. Install the Hobo plugin from the github repo

    $ cd vendor/plugins
    $ git clone git://github.com/tablatom/hobo.git

## 3. Run the hobo generators

    ruby script/generate hobo --add-routes
    ruby script/generate hobo_rapid --import-tags
    ruby script/generate hobo_user_model user
    ruby script/generate hobo_user_controller user
    ruby script/generate hobo_front_controller front --delete-index --add-routes
    
(I ommitted the '$' to indicate the prompt to make those copy-paste friendly)
    
And that's it. For bonus marks, make a script that does all this for you!

## 4. How to get updates

    $ cd vendor/plugins/hobo
    $ git pull

It's possible that some of Hobo's generated files have changed so you may need to run Hobo's generators again. Most often the only changes are in Hobo Rapid, so run

    $ ruby script/generate hobo_rapid

(don't forget to cd back to the root of the app)

