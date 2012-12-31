# Setup Ruby-debug

Originally written by apolzon on 2010-08-03.

A good practice for getting acquainted with code, and pinning down issues in the code you write, is to use a debugger.  In many languages, we would have to setup an IDE to accomplish this.  In Ruby, however, there exists a good gem for accomplishing the same task.

## Setup ##

* Install the ruby-debug gem:
>        gem install ruby-debug
   * Note: the ruby-debug gem is a native gem, and won't yet compile on Ruby 1.9.1.  There isn't any really good reason to be running Hobo on 1.9.1 (other than speed), so I'm going to assume this isn't an issue for most.
* Add the gem to your Rails environment:
    * Open project_name/config/environment.rb
    * Right under Rails::Initializer.run do |config| enter "config.gem 'ruby-debug'" (without the double-quotes)
* Open project_name/config/environments/development.rb and add to the bottom of the file:
>        require 'rubygems'
>        require 'ruby-debug'
>        Debugger.start
* Reboot your Rails server and debug mode is enabled.  To use it, just add "debugger" (again, without the quotes) to anyplace you would normally put ruby code.  If you are trying to look at something in the view layer, enter the following:
>        <% debugger %>
Be sure not to use the <%= beesting as it will end up messing the output buffer up.

## Use ##
Once Ruby picks up the debugger line, it will pause execution and drop into a debugger console.  This will occur in the terminal window where your server is running.  You can investigate all the commands available using help, but I'll give you a quick primer on the commonly used functions.

* list
> Use this command to display the code around where you are
> This will default to showing 10 lines -- 1 before your cursor and 9 after.  Override this with list 1,100 (show me lines 1-100)
* next
> Use this to tell the debugger to execute this command and continue to the next one
* step
> Use this to tell the debugger to drop down into the code location of the next command to be executed.
* continue
> Use this to tell the debugger to execute normally until it hits another debugger line
* exit
> Use this to tell the debugger "I want to stop the server".  It will prompt you to be sure; just hit y and enter to fully stop.
* irb
> The command I actually use the most is "irb".  If you issue this command to the debugger, it will give you a fully working ruby console so that you can edit objects, look at the values of any property, etc.  Highly useful if you are having trouble figuring out what context you are in.  this.class is a very useful command.

This is my first recipe, so if I've been too vague (or wrong) in parts please let me know and I'll update any confusing sections.

