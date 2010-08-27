require 'fileutils'
module Generators
  module Hobo
    Taglib = classy_module do

      argument :user_resource_name, :type => :string, :default => 'user', :optional => true

      class_option :admin,
                 :type => :boolean,
                 :desc => "Includes the tags for the admin site"

    end
  end
end
