# Getting an app working with new heroku.com (not herokugarden.com)

Originally written by kevinpfromnm on 2009-07-24.

## Generate your app ##

There's two possible approaches, either using the hobo gem which is easy with Heroku's .gems file or by installing hobo as a plugin.

Create your app if you haven't already

    hobo appname # or rails appname if you're going to install hobo as a plugin to be able to use edge hobo
    cd appname
    git init
    git add .
    git commit -m "Initial commit"

Make a heroku app to push your changes

    heroku create # enter your credentials if prompted (first use only)
    
As long as you run this within a git initialized directory, it will add a new remote of heroku

    git push heroku master

Note: heroku does not have all versions of rails gem available by default.  Current list as of this posting is rails (2.3.2, 2.2.2, 2.1.0, 2.0.2).  Check http://installed-gems.heroku.com/ for most up to date list.  If your most recent version isn't one of these, make sure to either update the .gems file (see next step) to include your version or change your <code>config/environment.rb</code> to reference one of those rails versions.

## Gem Installation ##

Just add a file to the root of your app called .gems with the following:

    hobo -v '0.8.8'

The -v '0.8.8' is optional but a good idea to specify the hobo gem version you wish to use so you don't accidentally grab a later version with breaking changes in it.  Any other gems you might need go on separate lines.  

Check this .gems file into git.

    git add .gems
    git commit -m "Added gemspec file"
    git push heroku

Heroku will pick up on the new .gems file and automatically grab appropriate gems.

## Plugin installation ##

This is not much different than the regular hobo edge install but you can't use submodules with heroku.com at this point.

    cd vendor/plugins
    git clone git://github.com/tablatom/hobo.git
    rm hobo/.git -rf
    rm hobo/.gitignore
    cd ../../.. # back to your base app directory
    git add .
    git commit -m "Added hobo plugin."
    git push heroku

## Final notes ##

Heroku does not automatically run migrations so you'll need to run <code>heroku rake db:migrate</code> if you add any migrations.

