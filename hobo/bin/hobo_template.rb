#!/usr/bin/env ruby

# just during hobo-development
gem 'hobo_support', :path => '../hobo3/hobo_support'
gem 'hobo_fields', :path => '../hobo3/hobo_fields'
gem 'dryml', :path => '../hobo3/dryml'
gem 'hobo', :path => '../hobo3/hobo'

# regular use
# gem 'hobo', '>= 1.3.0.pre0'

exec 'rails g hobo:setup_wizard'
