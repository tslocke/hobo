module Generators
  module Hobo
    TestOptions = classy_module do

      class_option :test_framework, :type => :string,
      :desc => "Use a specific test framework"

      class_option :fixtures, :type => :boolean,
      :desc => "Add the fixture option to the test framework", :default => true

      class_option :fixture_replacement, :type => :string,
      :desc => "Use a specific fixture replacement"

      class_option :update, :type => :boolean,
      :desc => "Run bundle update to install the missing gems"

    end
  end
end
