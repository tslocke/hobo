module Hobo
  class I18nGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def self.banner
      "rails generate hobo:i18n #{self.arguments.map(&:usage).join(' ')}"
    end

    argument :locales,
             :type => :array,
             :default => ["en"],
             :banner => "en it ..."

    def check_supported_locales
      locales.each do |l|
        unless File.exists?(File.join(self.class.source_root, "hobo.#{l}.yml") )
          say "The locale '#{l}' is not supported by Hobo!"
          exit
        end
      end
    end

    def copy_locale_files
      locales.each do |l|
        copy_file "hobo.#{l}.yml", "config/locales/hobo.#{l}.yml"
        copy_file "app.#{l}.yml", "config/locales/app.#{l}.yml"
      end
    end

    def remove_en_file
      remove_file 'config/locales/en.yml'
    end

    def add_default_count_helper
      return if File.read('app/helpers/application_helper.rb') =~ /def default_count\b/
      inject_into_file 'app/helpers/application_helper.rb',
        File.read( File.expand_path('../templates/default_count_injection.rb', __FILE__)),
        :after => "module ApplicationHelper\n"
    end


  end
end
