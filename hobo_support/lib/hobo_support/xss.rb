require 'active_support/core_ext/string/output_safety'
class Array
  # it always returns an html_safe? string preserving the html_safe?
  # items and separator, excaping the rest
  def safe_join(sep=$,)
    map {|i| ERB::Util.html_escape(i)}.join(ERB::Util.html_escape(sep)).html_safe
  end
end



