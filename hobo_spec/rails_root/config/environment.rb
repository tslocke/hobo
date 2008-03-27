RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.log_level = :debug
  config.cache_classes = true
  config.whiny_nils = true
  config.load_paths << "#{File.dirname(__FILE__)}/../../../hobo/lib/"
  
  config.action_controller.session = {
    :session_key => '_hobo_test_session',
    :secret      => '5d90a378c21b465d10c48d8e79572008'
  }
end

