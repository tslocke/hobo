require 'bundler/cli'
module Hobo
  class TestFrameworkGenerator < Rails::Generators::NamedBase

    include Generators::Hobo::TestOptions

    FRAMEWORKS = %w[test_unit rspec shoulda rspec_with_shoulda]

    def self.banner
      "rails generate hobo:test_framework NAME [options]"
    end

    def initialize(*)
      super
      @finalize_hooks = []
    end

    def setup_framework
      if FRAMEWORKS.include?(name)
        eval 'setup_' + name
      else
        say "'#{name}' is not supported. You should configure it manually."
        exit 1
      end
    end

    def fixture_replacement_installation
      return if options[:fixture_replacement].blank?
      gem options[:fixture_replacement], :group => :test
    end

    def finalize_installation
      # add the block only if it's not the default
      add_generators_block unless (name == 'test_unit' && options[:fixtures] && options[:fixture_replacement].blank?)
      invoke Bundler::CLI, :update if options[:update] && @should_update
      @finalize_hooks.each {|h| h.call }
    end

private

    def setup_test_unit
    end

    def setup_rspec
      gem 'rspec-rails', '>= 2.0.0', :group => [:test, :development]
      @should_update = true
      return unless options[:update]
      @finalize_hooks << lambda {say "Finalizing rspec installation..."; invoke 'rspec:install'}
    end

    def setup_shoulda
      gem 'shoulda', :group => :test
      @should_update = true
    end

    def setup_rspec_with_shoulda
      setup_rspec
      setup_shoulda
    end

    def add_generators_block
      n = name == 'rspec_with_shoulda' ? 'rspec' : name
      block = "\n  config.generators do |g|"
      block << "\n      g.test_framework :#{n}, :fixtures => #{options[:fixtures].inspect}" if !options[:fixtures] || name != 'test_unit'
      block << "\n      g.fallbacks[:#{n}] = :test_unit" unless name == 'test_unit'
      block << "\n      g.fixture_replacement = :#{options[:fixture_replacement]}" unless options[:fixture_replacement].blank?
      block << "\n    end\n"
      environment block
    end

  end
end
