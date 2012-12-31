# Hobo in Two Minutes

To build a Hobo 2.0 app you need to have a working Rails setup. If you can
create a Rails app and have it connect to a database, you're all set.
You need at least version 3.2.5 of Rails:

	$ rails -v

First install Hobo (currently we need to specify --pre, since Hobo
2.0.0 is not the official release yet):

	$ gem install hobo --pre

	$ hobo -v

Now create an app! We've only got two minutes so we'll create an ultra-useful Thing Manager.

	$ hobo new thingybob --setup

(The `--setup` option tells hobo to use the defaults rather than
asking questions about your application.)

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
