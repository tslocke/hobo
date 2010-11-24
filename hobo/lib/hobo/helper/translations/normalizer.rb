module Hobo
  module Helper
    module Translations
      module Normalizer

        private

        def normalize_args(key, options={})
          if (key.class == Hash) # called as a tag
            if key.has_key?(:default) && !key[:default].blank?
              Rails.logger.warn "hobo-i18n: 'default' should not be used as an attribute on *translate tags. If used, then you need to make sure that the tags inner-contents are not used. These are normally treated as defaults automatically, but if there is a default attribute then that inner-content will be hidden from this method - and will not be replaced with the translation found."
            end
            defaults = options[:default]
            options = key
            key = options.delete(:key)
            # Set options[:default] to complete the tag-argument-conversion process.
            options[:default] = defaults.call(options) if defaults.class == Proc
          end
          options.each_pair { |k,v| options[k] = h(v) }
          options[:default] = Array.wrap options[:default]
          [key, options]
        end


      end
    end
  end
end
