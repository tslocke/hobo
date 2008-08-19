# Load Hobo from the gem if is not already loaded 
# (i.e. if the plugin is not present)

unless defined? Hobo
  gem 'hobo'
  require 'hobo'
end
