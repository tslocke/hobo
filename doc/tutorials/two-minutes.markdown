# Hobo in Two Minutes

## Prerequisites

Before installing Hobo, you must have
[Ruby](http://www.ruby-lang.org/en/) and
[RubyGems](http://docs.rubygems.org/). You will also need the "git" command.

Installing Hobo 2.0 will auto install Rails 3.2. Be careful not to install Rails 4, it's currently not compatible.

For example, these are the steps you would need in Ubuntu 12.04:

```
    sudo apt-get update
    sudo apt-get install -y ruby1.9.3 rubygems nodejs libsqlite3-dev git
    export GEM_HOME=$HOME/.gem
    echo "export GEM_HOME=$HOME/.gem" >> .bashrc
    PATH="$HOME/.gem/bin:$PATH"
    echo 'PATH="$HOME/.gem/bin:$PATH"' >> .bashrc
```

## Install Hobo and create your first app

	$ gem install hobo

	$ hobo -v

	$ hobo new thingybob --setup

(The `--setup` option tells hobo to use the defaults rather than
asking questions about your application.   After you play with
Hobo a bit so that you understand the questions, you will probably
want to omit the `--setup`)


## Add a resource and start the app

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

Note: If you wish to download the gems directly, you can get them from
[RubyGems.org](http://rubygems.org).

The source code for Hobo is available at [github:Hobo/hobo](http://github.com/Hobo/hobo) and additional sources are available in the [github Hobo organization](https://github.com/Hobo)


