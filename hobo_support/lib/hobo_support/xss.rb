require 'active_support/core_ext/string/output_safety'
class Array
  def safe_join(sep=$,)
    if self.all? {|i| i.html_safe?}
      self.join(ERB::Util.html_escape(sep)).html_safe
    else
      self.join(sep)
    end
  end
end



