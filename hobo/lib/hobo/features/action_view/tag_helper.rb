ActionView::Helpers::TagHelper.module_eval do

  alias_method :tag_without_doctype, :tag

  def tag(name, options = nil, open = false, escape = true)
    open = !scope.xmldoctype if defined?(scope)
    tag_without_doctype(name, options, open, escape)
  end

end
