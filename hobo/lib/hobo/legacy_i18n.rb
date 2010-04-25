# This file contains the legacy i18n code transparently loaded
# by legacy apps. (See also 'hobo/legacy_i18n_methods')
# It also contain a monkey patch to the Model.human_name and Model.human_attribute_name
# It will be removed some day
module Hobo
  class ViewHints
    class << self
    
      def model_name(new_name=nil)
        if new_name.nil?
          @model_name ||= Hobo::Translations.ht("#{_name.tableize}.model_name", :default => _name.titleize)
        else
          @model_name = Hobo::Translations.ht("#{_name.tableize}.model_name", :default => new_name)
        end
      end
                
      def model_name_plural(new_name=nil)
        if new_name.nil?
          @model_name_plural ||= Hobo::Translations.ht("#{_name.tableize}.model_name_plural", :default => model_name.pluralize)
        else
          @model_name_plural = Hobo::Translations.ht("#{_name.tableize}.model_name_plural", :default => new_name)
        end
      end

      def field_name(field)
        Hobo::Translations.ht("#{_name.tableize}.#{field}", :default => field_names.fetch(field.to_sym, field.to_s.titleize))
      end
    
    end
  end
end