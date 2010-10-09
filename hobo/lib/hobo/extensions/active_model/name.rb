ActiveModel::Name.class_eval do
    # adds a default pluralization for english
    # useful to avoid to set a locale 'en' file and avoid
    # to pass around pluralize calls for 'en' defaults in hobo
    def human_with_en_pluralization_default(options={})
      if I18n.locale.to_s.match(/^en/)
        unless options[:count] == 1 || options[:count].blank?
          default = ActiveSupport::Inflector.pluralize(@human)
          options.merge! :default => default
        end
      end
      human_without_en_pluralization_default(options)
    end
    alias_method_chain :human, :en_pluralization_default

end
