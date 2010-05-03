module Hobo
  # This methods are included in Hobo::ViewHints in order to load
  # the legacy i18n code if the deprecated method are used
  # It will be removed some day
  module LegacyI18nMethods
  
    def load_legacy_i18n(method, *args)
      Rails.logger.warn "The method '#{method}' is deprecated. "\
                        "Please, see Hobo::LegacyMethods.#{method} documentation."
      require 'hobo/legacy_i18n'
      send method, *args
    end
    
    # Deprecated method. Use ActiveRecord::Base.human_name 
    # and set a the activerecord.models.<model_name> key in a locale file.
    def model_name(*args)
      load_legacy_i18n :model_name, *args
    end
    
    # Deprecated method. Use ActiveRecord::Base.human_name passing a :count option, 
    # and set a the activerecord.models.<model_name> key in a locale file.
    def model_name_plural(*args)
      load_legacy_i18n :model_name_plural, *args
    end
    
    # Deprecated method. Use ActiveRecord::Base.human_attribute_name 
    # and set a the activerecord.attributes.<model_name>.<field_name> key in a locale file.
    def field_name(*args)
      load_legacy_i18n :field_name, *args
    end
    
    # Deprecated method. You can set the field names by setting
    # the activerecord.attributes.<model_name>.<field_name> keys in a locale file
    def field_names(*args)
      load_legacy_i18n :field_names, *args
    end
    
  end
end