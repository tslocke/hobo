ActiveModel::Translation.class_eval do

    # adds a default pluralization and singularization for english
    # useful to avoid to set a locale 'en' file and avoid
    # to pass around pluralize calls for 'en' defaults in hobo
    def human_attribute_name_with_en_pluralization_default(attribute, options={})
      if I18n.locale.to_s.match(/^en/)
        default = Array.wrap(options[:default])
        if options[:count] == 1 || options[:count].blank?
          default = attribute.to_s.singularize.humanize
        else
          default = attribute.to_s.pluralize.humanize
        end
        options = options.merge(:default=>default)
      end
      human_attribute_name_without_en_pluralization_default(attribute, options)
    end

    alias_method_chain :human_attribute_name, :en_pluralization_default

    # Similar to human_name_attributes, this method retrieves the localized help string
    # of an attribute if it is defined as the key "activemodel.attribute_help.<attribute_name>",
    # otherwise it returns "".
    def attribute_help(attribute, options = {})
      defaults = lookup_ancestors.map do |klass|
        :"#{self.i18n_scope}.attribute_help.#{klass.model_name.underscore}.#{attribute}"
      end

      defaults << :"attribute_help.#{attribute}"
      defaults << options.delete(:default) if options[:default]
      defaults << ''

      options.reverse_merge! :count => 1, :default => defaults
      I18n.translate(defaults.shift, options)
    end

end
