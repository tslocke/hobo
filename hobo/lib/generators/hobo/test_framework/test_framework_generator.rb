module Hobo
  class TestFrameworkGenerator < Rails::Generators::NamedBase

    FRAMEWORKS = %w[test_unit rspec shoulda rspec_with_shoulda]

    argument :fixture_replacement, :type => :string, :optional => true

    def self.banner
      "rails generate hobo:test_framework NAME [fixture_replacement] [options]"
    end

    def initialize
      super
      @finalize_hooks = []
    end

    class_option :fixtures,
           :type => :boolean,
           :desc => "Add the fixture option to the test framework",
           :default => true

    def setup_framework
      if FRAMEWORKS.include?(name)
        eval 'setup_' + name
      else
        say "'#{name}' is not supported. You should configure it manually."
        exit 1
      end
    end

    def fixture_replacement_installation
      return if fixture_replacement.blank?
      gem fixture_replacement, :group => :test
    end

    def finalize_installation
      # add the block only if it's not the default
      add_generators_block unless (name == 'test_unit' && options[:fixtures] && fixture_replacement.blank?)
      invoke Bundle::CLI, :update if @should_update
      @finalize_hooks.each {|h| h.call }
    end

private

    def setup_test_unit
    end

    def setup_rspec
      gem 'rspec-rails', '>= 2.0.0.beta.10', :group => :test
      @should_update = true
      @finalize_hooks << lambda {say "Finalizing rspec installation..."; invoke 'rspec:install'}
    end

    def setup_shoulda
      gem "shoulda", :group => :test
      @should_update = true
    end

    def setup_rspec_with_shoulda
      setup_rspec
      setup_shoulda
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
