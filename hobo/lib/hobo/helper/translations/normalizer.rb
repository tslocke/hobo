require 'active_support/core_ext/string/output_safety'
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
          escape_options(options)
          options[:default] = Array.wrap options[:default]
          [key, options]
        end

        def escape_options(options)
          options.each_pair do |k,v|
            options[k] = case v
                         when Array
                            v.map {|i| i.respond_to?(:html_safe) ? ERB::Util.html_escape(i) : i}
                         else
                           v.respond_to?(:html_safe) ? ERB::Util.html_escape(v) : v
                         end
          end
        end

      end
    end
  end
end
