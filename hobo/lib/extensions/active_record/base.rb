class ActiveRecord::Base
  class << self
    # adds a default pluralization for english
    # useful to avoid to set a locale 'en' file and avoid
    # to pass around pluralize calls for 'en' defaults in hobo
    def human_name_with_en_pluralization_default(options={})
      if I18n.locale.to_s.match(/^en/) 
        unless options[:count] == 1 || options[:count].blank?
          default = options[:default].class.eql?(Array) ? options[:default] : [options[:default]]
          default << self.name.underscore.pluralize.humanize
          options = options.merge(:default=>default) 
        end
      end
      human_name_without_en_pluralization_default(options)
    end
    
    alias_method_chain :human_name, :en_pluralization_default
    
    # adds a default pluralization and singularization for english
    # useful to avoid to set a locale 'en' file and avoid
    # to pass around pluralize calls for 'en' defaults in hobo
    def human_attribute_name_with_en_pluralization_default(attribute, options={})
      if I18n.locale.to_s.match(/^en/) 
        default = options[:default].class.eql?(Array) ? options[:default] : [options[:default]]
        if options[:count] == 1 || options[:count].blank?
          default << attribute.to_s.singularize.humanize
        else
          default << attribute.to_s.pluralize.humanize
        end
        options = options.merge(:default=>default) 
      end
      human_attribute_name_without_en_pluralization_default(attribute, options)
    end
    
    alias_method_chain :human_attribute_name, :en_pluralization_default

    # Similar to human_name_attributes, this method retrieves the localized help string 
    # of an attribute if it is defined as the key "activerecord.attribute_help.<attribute_name>", 
    # otherwise it returns "".
    def attribute_help(attribute_key_name, options = {})
      defaults = self_and_descendants_from_active_record.map do |klass|
        :"#{klass.name.underscore}.#{attribute_key_name}"
      end
      defaults << options[:default] if options[:default]
      defaults.flatten!
      defaults << ""
      options[:count] ||= 1
      I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => [:activerecord, :attribute_help]))
    end

  end
end
