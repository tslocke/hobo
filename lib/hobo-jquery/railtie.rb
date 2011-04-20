require 'hobo-jquery'
require 'rails'
module HoboJquery
  class Railtie < Rails::Railtie
    railtie_name :hobo_jquery

    rake_tasks do
      load "tasks/hobo-contrib.rake"
    end
  end
end
