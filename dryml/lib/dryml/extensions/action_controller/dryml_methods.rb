ActionController::Base.class_eval do

  before_filter do
    append_view_path Dryml::Railtie::PageTagResolver.new(self)
  end

  attr_accessor :dryml_fallback_tag

  def dryml_context
    @this
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
