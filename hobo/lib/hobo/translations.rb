module Hobo

  module Translations

    # --- Translation Helper --- #
    #
    # Uses RoR native I18n.translate.
    #
    # Adds some conventions for easier hobo translation. 
    # 1. Assumes the first part of the key to be a model name (e.g.: users.index.title -> user)
    # 2. Tries to translate the model by lookup for: (e.g.: user-> activerecord.models.user)
    # 3. Adds a default fallback to the beginning of the fallback chain 
    #    by replacing the first part of the key with "hobo" and using the translated model name 
    #    as additional attribute. This allows us to have default translations 
    #    (e.g.: hobo.index.title: "{{model}} Index")
    # 
    # Is also used as a tag in the dryml-view files. The syntax is:
    # <ht key="my.app">My Application</ht>
    #   --> Will lookup the "my.app"-key for your locale and replaces the "My Application" content 
    #       if found.
    #
    # <ht key="my" app="Program">My Application</ht>
    #   --> Will look up both the "my"- and "app"-key for your locale, and replaces the 
    #       "My Application" with the "my"-key contents (interpolated using the "app"-key.
    #       sample.en.yml-file:
    #       "no":
    #         my: "Mitt {{app}}"
    #       The output should be: Mitt Program
    # 
    # Otherwise with features as the ht method, step 1, 2 and 3 above. 
    def self.ht(key, options={})
      
      # Check if called as a tag, i.e. like this <ht></ht>
      if (key.class == Hash)
        if key.has_key?(:default) && !key[:default].blank?
          Rails.logger.warn "hobo-i18n: 'default' should not be used as an attribute on the ht-tag. If used, then you need to make sure that the tags inner-contents are not used. These are normally treated as defaults automatically, but if there is a default attribute then that inner-content will be hidden from this method - and will not be replaced with the translation found."
        end
        defaults = options[:default];
        # Swap key and options, remove options[:key] 
        options = key 
        key = options.delete(:key) # returns value for options[:key] as well as deleting it
        # Set options[:default] to complete the tag-argument-conversion process.
        options[:default] = (defaults.class == Proc) ? [defaults.call(options)] : (options[:default].blank? ? [] : [options[:default]])
      else
        # Not called as a tag. Prepare options[:default].
        if options[:default].nil?
          options[:default]=[]
        elsif options[:default].class != Array
          options[:default] = [options[:default]]
        end
      end
      
      # assume the first part of the key to be the model
      keys = key.to_s.split(".")
      if keys.length > 1
        model = keys.shift()
        subkey = keys.join(".")
      else
        subkey = key
      end
    
      # add :"hobo.#{key}" as the first fallback
      options[:default].unshift("hobo.#{subkey}".to_sym)
    
      # translate the model
      unless model.blank?
        translated_model = I18n.translate( "activerecord.models.#{model.singularize.underscore}", :default=>model).titleize
        options[:model] = translated_model
      end
    
      key_prefix = "<span class='translation-key'>#{key}</span>" if defined?(HOBO_SHOW_LOCALE_KEYS) && HOBO_SHOW_LOCALE_KEYS
    
      Rails.logger.info "..translate(#{key}, #{options.inspect}) to #{I18n.locale}" if defined?(HOBO_VERBOSE_TRANSLATIONS)
      
      translation = I18n.translate(key.to_sym, options)
      if translation.respond_to? :to_str
        key_prefix ? translation.to_str+key_prefix : translation
      else
        "translation invalid: #{key}"
      end
    end

    # if somebody includes us, give them ht as an instance method
    def self.included(base)
      translation_class = self
      base.class_eval do
        define_method :ht do |*args|
          translation_class.ht(*args)
        end
      end
    end
  end
end
