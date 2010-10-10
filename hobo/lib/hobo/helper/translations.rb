module Hobo
  module Helper
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
      # The "count" option set the integer passed or to the Model.count if : dynamic is passed.
      # The following lines are the same:
      #
      # <ht key="modelname.any.key" count="&:dynamic">
      # <ht key="modelname.any.key" count="&model.count">
      #
      # Otherwise with features as the ht method, step 1, 2 and 3 above.
      def ht(key, options={})

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

        # will skip useless code in case the first part of the key is 'hobo'
        model = '' if model.eql?('hobo')

        unless model.blank?
          klass = begin
                    model.singularize.camelize.constantize
                  rescue NameError
                  end
          # add :"hobo.#{key}" as the first fallback
          options[:default].unshift("hobo.#{subkey}".to_sym)
          # set the count option in order to allow multiple pluralization
          count = options.delete(:count)
          count = default_count if count.blank?
          c = count.try.to_i || count==:dynamic && klass.try.count
          # translate the model
          # the singularize method is used because Hobo does not keep the ActiveRecord convention in its tags
          # no default needed because human_name defaults to the model name
          # try because Hobo class is not an ActiveRecord::Base subclass
          translated_pluralized_model = klass.try.model_name.try.human(:count=>c)
          options[:model] = translated_pluralized_model
        end
        options[:count] = c

        key_prefix = "<span class='translation-key'>#{key}</span>" if defined?(HOBO_SHOW_LOCALE_KEYS) && HOBO_SHOW_LOCALE_KEYS

        Rails.logger.info "..translate(#{key}, #{options.inspect}) to #{I18n.locale}" if defined?(HOBO_VERBOSE_TRANSLATIONS)

        translation = I18n.translate(key.to_sym, options)
        if translation.respond_to? :to_str
          key_prefix ? translation.to_str+key_prefix : translation
        else
          "translation invalid: #{key}"
        end
      end

    end
  end
end
