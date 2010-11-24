module Hobo
  module Helper
    module Translations

      include Normalizer

=begin

hobo_translate / ht

Wrapper around the Rails :translate helper with hobo added features.

It can be used as a regular helper or as a dryml tag.

Hobo Added Features

The first part of the key must be a model name (e.g.: user.index.title -> user). This method will add a "model" interpolation variable set to the translated and pluralized Model.model_name.human. Besides, it will add a default 'hobo.' fallback, (e.g.: hobo.index.title) at the beginning of the fallback chain.

You can also pass any other :translate option like for example :count.

Example:

<%= ht :key=>'user.index.title', :default=>'Index'  %>
<ht key="user.index.title">Index</ht>
#=> "Index" # if "user.index.title" or "hobo.index.title" is not found
#=> "User Index" # with the below en.yml file

=== en.yml ===
en:
  hobo:
    index:
      title: %{model} Index

=end

      def hobo_translate(*args)
        key, options = normalize_args(*args)
        keys = key.to_s.split(".")
        model_name = keys.shift
        model_class = begin model_name.camelize.constantize; rescue; end
        unless model_class && model_class < ActiveRecord::Base
          raise Hobo::I18nError, %(wrong model name: "#{model_name}" (extracted from translation key: "#{key}"). You might want to use the translate/t tag/method instead.)
        end
        options[:default].unshift("hobo.#{keys.join(".")}".to_sym)
        options[:model] = model_class.model_name.human(:count=>options[:count]||1)
        translate key.to_sym, options
      end
      alias_method :ht, :hobo_translate



    end
  end
end
