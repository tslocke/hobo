module Generators
  module Hobo
    Taglib = classy_module do

      class_option :user_resource_name,
                   :type => :string,
                   :desc => "User Resource Name",
                   :default => 'user'

      class_option :admin,
                   :type => :boolean,
                   :desc => "Includes the tags for the admin site"

    end
  end
end
