I18n.module_eval do
  class << self

    def translate_with_show_keys(key, options = {})
      translation = translate_without_show_keys(key, options)
      return translation unless translation.is_a?(String)
      keys = normalize_keys(locale, key, options[:scope]).join('.')
      "[#{keys}]" + translation
    end
    alias_method_chain :translate, :show_keys

    alias_method :t_without_show_keys, :t
    alias_method :t, :translate_with_show_keys

  end
end

