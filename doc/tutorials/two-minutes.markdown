# Hobo in Two Minutes

To build a Hobo 2.0 app you need to have a working Rails setup. If you can
create a Rails app and have it connect to a database, you're all set.

You need at least version 3.2.5 of Rails:

	$ rails -v

## Windows && OS X

First install Hobo.

	$ gem install hobo

	$ hobo -v

Now create an app! We've only got two minutes so we'll create an ultra-useful Thing Manager.

	$ hobo new thingybob --setup

(The `--setup` option tells hobo to use the defaults rather than
asking questions about your application.   After you play with
Hobo a bit so that you understand the questions, you will probably
want to omit the `--setup`)

Now skip the "Linux" section and move on to the "common" section.

## Linux

First install Hobo.

	$ gem install hobo

	$ hobo -v

Now create an app! We've only got two minutes so we'll create an ultra-useful Thing Manager.

	$ hobo new thingybob

It will ask you `Do you want to start the Setup Wizard now?`.  Answer "n".  We need to fix up the Rails Gemfile, and then we'll start the Setup Wizard.

Using your editor of choice, edit the file `Gemfile`.   There is a line that looks like this:

     # gem 'therubyracer', :platforms => :ruby

Remove the `#` from the beginning of the line to uncomment it.  Then run:

     $ bundle
     $ hobo generate setup_wizard --wizard=false

(The `--wizard=false` option tells hobo to use the defaults rather than
asking questions about your application.   After you play with
Hobo a bit so that you understand the questions, you will probably
want to omit the `--wizard=false`)

# Common

There will be lots of output produced as Hobo runs the rails command
and runs the setup generator. This process may take a while, depending
on your internet connection and computer speed.

	$ cd thingybob
	$ hobo g resource thing name:string body:text
	$ hobo g migration

	...Respond to the prompt with 'm'
	...then press enter to chose the default filename

	$ rails s

And browse to

	http://localhost:3000

And there is your app! You should be able to

* Sign up
* Create and edit Things
* Search for things

That's it. Why not try another of the tutorials on your left.
