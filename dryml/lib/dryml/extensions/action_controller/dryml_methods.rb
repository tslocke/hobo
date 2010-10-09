ActionController::Base.class_eval do

  before_filter do
    append_view_path Dryml::Railtie::PageTagResolver.new(self)
  end

  # dryml does not use layouts
  def action_has_layout?
    false
  end

  def dryml_context
    @this
  end

  def dryml_fallback_tag(tag_name)
    @dryml_fallback_tag = tag_name
  end

  def call_dryml_tag(tag, options={})
    # TODO: Figure out what this bit is all about :-)
    if options[:with]
      @this = options[:with] unless options[:field]
    else
      options[:with] = dryml_context
    end
    Dryml.render_tag(view_context, tag, options)
  end

end
