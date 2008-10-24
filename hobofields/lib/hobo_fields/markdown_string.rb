module HoboFields

  class MarkdownString < RawMarkdownString
    include SanitizeHtml
    HoboFields.register_type(:markdown, self)
  end

end
