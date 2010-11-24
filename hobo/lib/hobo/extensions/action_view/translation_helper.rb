ActionView::Helpers::TranslationHelper.module_eval do

  include Hobo::Helper::Translations::Normalizer

  # simple wrapper around the translate helper
  # it implements a dryml <translate> and a <t> tag
  # Improved security: interpolated variables are escaped
  # Improved management: when it returns a string it is always html_safe
  # It assumes the base translation string is html_safe
  # It removes the <span> tag when the key is missing, because it would mess up
  # the dryml tags when ht or t is used in some place

  def translate(key, options={}, normalize=true)
    key, options = normalize_args(key, options) if normalize
    translation = I18n.translate(scope_key_by_partial(key), options.merge!(:raise => true))
    if translation.respond_to?(:html_safe)
      translation.html_safe
    else
      translation
    end
  rescue I18n::MissingTranslationData => e
    keys = I18n.normalize_keys(e.locale, e.key, e.options[:scope]).join('.')
    "[MISSING: #{keys}]"
  end
  alias_method :t, :translate

end
