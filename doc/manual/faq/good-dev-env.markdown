# What's a good development environment?

FIXME: Webrick, Unicorn, etc? And a basic Gemfile (e.g. conditionally include
ruby-debug, switch Rack to 1.2.4 (or am I alone in getting crashes
when I use 1.2.5?)) with all the core bits, and a commented section
with the "extras" like the jquery stuff that Bryan has published.
So... "install rvm, install ruby 1.9.2, update gem, install rails
3.0.11, install hobo 1.3, edit Gemfile, run bundle install, set
gemset... now you can start to make new hobo projects". "add jquery,
add ..." and now you can tackle some more complex projects. And the
regular set of checks on ruby version, gem version, gems, rails
versions, hobo versions; how to keep up to date and how to freeze for
production environments.
