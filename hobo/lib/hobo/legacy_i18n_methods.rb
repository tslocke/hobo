module Hobo
  # This methods are included in Hobo::ViewHints in order to load
  # the legacy i18n code if the deprecated method are used
  # It will be removed some day
  module LegacyI18nMethods
  
    def load_legacy_i18n(method, *args)
      Rails.logger.warn "The ViewHints methods 'model_name', 'model_name_plural' and 'field_name' \
have been deprecated. Please, set the names in a locale file and use the ActiveRecord::Base methods \
'human_name' and 'human_attribute_name' to retrieve them."
      # TODO: add a file with instructions about how to use canonical i18n in hobo
      require 'hobo/legacy_i18n'
      send method, *args
    end
    
    def model_name(*args)
      load_legacy_i18n :model_name, *args
    end
    
    def model_name_plural(*args)
      load_legacy_i18n :model_name_plural, *args
    end
    
    def field_name(*args)
      load_legacy_i18n :field_name, *args
    end
    
  end
end