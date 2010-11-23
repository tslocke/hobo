ActionView::Helpers::TranslationHelper.module_eval do

  # Improved security escaping interpolated variables
  # Improved management: when it returns a string it is always html_safe
  # It assumes the base translation string is html_safe
  # It removes the <span> tag when the key is missing, because it would mess up
  # the dryml tags when ht or t is used in some place

  def translate(key, options = {})
    options.each_pair { |k,v| options[k] = h(v) }
    translation = I18n.translate(scope_key_by_partial(key), options.merge!(:raise => true))
    if translation.respond_to?(:html_safe)
      translation.html_safe
    else
      translation
    end
  rescue I18n::MissingTranslationData => e
    keys = I18n.normalize_keys(I18n.locale, key, options[:scope]).join('.')
    "[MISSING: #{keys}]"
  end
  alias_method :t, :translate

end
