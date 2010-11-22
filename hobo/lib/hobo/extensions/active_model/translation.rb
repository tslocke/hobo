ActiveModel::Translation.class_eval do

    # adds a default pluralization and singularization for english
    # useful to avoid to set a locale 'en' file and avoid
    # to pass around pluralize calls for 'en' defaults in hobo
    def human_attribute_name_with_en_pluralization_default(attribute, options={})
      if I18n.locale.to_s.match(/^en/)
        unless options[:count].blank? # skip default if we don't pass any count
          default = options[:count] == 1 ?
                    attribute.to_s.singularize.humanize : # singularize possible plural attributes
                    attribute.to_s.pluralize.humanize
          options.merge! :default => default
        end
      end
      human_attribute_name_without_en_pluralization_default(attribute, options)
    end
    alias_method_chain :human_attribute_name, :en_pluralization_default

    # Similar to human_name_attributes, this method retrieves the localized help string
    # of an attribute if it is defined as the key "activemodel.attribute_help.<attribute_name>",
    # otherwise it returns "".
    def attribute_help(attribute, options = {})
      defaults = lookup_ancestors.map do |klass|
        :"#{self.i18n_scope}.attribute_help.#{klass.to_s.underscore}.#{attribute}"
      end

      defaults << :"attribute_help.#{attribute}"
      defaults << options.delete(:default) if options[:default]
      defaults << ''

      options.reverse_merge! :count => 1, :default => defaults
      I18n.translate(defaults.shift, options)
    end

end
