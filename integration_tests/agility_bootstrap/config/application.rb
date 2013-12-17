require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Agility
  class Application < Rails::Application
  
    config.generators do |g|
      g.test_framework :shoulda, :fixtures => true
      g.fallbacks[:shoulda] = :test_unit
      g.fixture_replacement = :factory_girl_rails
    end
  
    config.hobo.dryml_only_templates = true
    # Hobo: the front subsite loads front.css & front.js
    config.assets.precompile += %w(front.css front.js)
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.i18n.enforce_available_locales = true

  end
end

ActiveSupport::Deprecation.debug = true