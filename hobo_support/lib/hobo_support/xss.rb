class Array
  def safe_join(sep=$,)
    if (sep.nil? || sep.html_safe?) && self.all? {|i| i.html_safe?}
      self.join(sep).html_safe
    else
      self.join(sep)
    end
  end
end
      
    
    
