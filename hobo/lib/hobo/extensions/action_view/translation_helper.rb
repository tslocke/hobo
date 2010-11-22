ActionView::Helpers::TranslationHelper.module_eval do

  # we need to remove the <span> tag because it will mess up
  # the dryml tags when ht is used in some place
  # we redefine the method since we cannot catch the rescued exception
  # although the only difference is the rescue block
  def translate(key, options = {})
    translation = I18n.translate(scope_key_by_partial(key), options.merge!(:raise => true))
    if html_safe_translation_key?(key) && translation.respond_to?(:html_safe)
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
