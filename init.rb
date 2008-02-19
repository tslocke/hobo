gem 'hobosupport', "= 0.1"
require 'hobosupport'

ActiveRecord::Base.send(:include, HoboFields)

