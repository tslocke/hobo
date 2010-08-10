module Hobo
  class TestFrameworkGenerator < Rails::Generators::NamedBase

    FRAMEWORKS = %w[test_unit rspec shoulda rspec_with_shoulda]

    argument :fixture_replacement, :type => :string, :optional => true

    def self.banner
      "rails generate hobo:test_framework NAME [fixture_replacement] [options]"
    end

    class_option :fixtures,
           :type => :boolean,
           :desc => "Add the fixture option to the test framework",
           :default => true

    def setup_framework
      if FRAMEWORKS.include?(name)
        eval 'setup_' + name
      else
        say "'#{name}' is not supported.'"
        exit
      end
    end

private

    def setup_test_unit
      # add the block only if it's not the default
      add_generators_block unless (name == 'test_unit' && options[:fixtures] && fixture_replacement.blank?)
    end

    def setup_rspec
      say 'Setting up rspec...'
      gem 'rspec-rails', '>= 2.0.0.beta.10', :group => :test
      puts run 'bundle install'
      invoke 'rspec:install'
      add_generators_block
    end

    def setup_shoulda
      say 'Setting up shoulda...'
      gem "shoulda", :group => :test
      puts run 'bundle install'
      add_generators_block
    end

    def setup_rspec_with_shoulda
      say 'Setting up rspec and shoulda...'
      gem "shoulda", :group => :test
      setup_rspec
    end

    def add_generators_block
      block = 'config.generators do |g|'
      block << "  g.test_framework :#{name}, :fixtures => #{options[:fixtures].inspect}" if !options[:fixtures] || name != 'test_unit'
      block << "\n  g.fallbacks[:#{name}] = :test_unit" unless name == 'test_unit'
      block << "\n  g.fixture_replacement => :#{fixture_replacement}" unless fixture_replacement.blank?
      block << "\nend"
      environment block
    end

  end
end
