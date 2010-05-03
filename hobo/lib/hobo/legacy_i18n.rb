# This file contains the legacy i18n code transparently loaded
# by legacy apps. (See also 'hobo/legacy_i18n_methods')
# It also contain a patch to the Model.human_name and Model.human_attribute_name
# to mantain backward compatibility
# It will be removed some day

module ActiveRecord
  class Base
    class << self

      def human_name_with_legacy_i18n(options={})
        if options[:count].blank? || options[:count] == 1
          view_hints.model_name
        else
          view_hints.model_name_plural nil, options[:count]
        end
      end
  
      def human_attribute_name_with_legacy_i18n(attr, options={})
        view_hints.field_name attr
      end
  
      alias_method_chain :human_name, :legacy_i18n
      alias_method_chain :human_attribute_name, :legacy_i18n

    end
  end
end

module Hobo
  class ViewHints
    
    setter :field_names, {}

    class << self
      
      def model_name(new_name=nil)
        # fixes a previous bug:
        # storing just one translation per model makes multi-loclale apps completely buggy
        # (i.e. you have translations of mixed locale in the same response)
        # Storing and retrieving the translated name make sense only for single-locale apps 
        # or when the current locale is the default_locale (:en by default)
        if I18n.locale == I18n.default_locale
          if new_name.nil?
            # we return the stored translated name or we lookup for it
            # also we fall back to the canonical human_name that looks where the name should be
            @model_name ||= I18n.t "#{_name.tableize}.model_name",
                            :default => model.human_name_without_legacy_i18n,
                            :count => 1
          else
            # In case of setting a new name for the default locale, we need no translation
            @model_name = new_name
          end
        else 
          # with any non default_locale we lookup the translation in the canonical way
          # also we don't need any default because human_name has an automatic default
          model.human_name_without_legacy_i18n
        end
      end

      # this method does not make any sense for multi-pluralized languages
      def model_name_plural(new_name=nil, count=2)
        # fixes a previous bug:
        # storing just one translation per model makes multi-loclale apps completely buggy
        # (i.e. you have translations of mixed locale in the same response)
        # Storing and retrieving the translated name make sense only for single-locale apps 
        # or when the current locale is the default_locale (:en by default)
        if I18n.locale == I18n.default_locale
          if new_name.nil?
            # we return the stored translated name or we lookup for it
            # also we fall back to the canonical human_name that looks where the name should be
            # change from legacy code: _name.pluralize is better than model_name.pluralize, 
            # because it does not try to english-pluralize non english model names, 
            # and sticks to the english pluralization of the english name
            @model_name_plural ||= I18n.t "#{_name.tableize}.model_name_plural",
                                          :default => model.human_name_without_legacy_i18n(:count=>count),
                                          :count => count
          else
            # In case of setting a new name for the default locale, we need no translation
            @model_name_plural = new_name
          end
        else 
          # with any non default_locale we lookup the translation in the canonical way
          # also we don't need any default because human_name has an automatic default
          model.human_name_without_legacy_i18n :count=>count
        end
      end

      def field_name(field)
        I18n.t "#{_name.tableize}.#{field}", 
               :default => model.human_attribute_name_without_legacy_i18n(field), 
               :count => 1
      end
    
    end
  end
end