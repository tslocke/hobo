class String

  def remove(string_or_rx)
    sub(string_or_rx, '')
  end

  def remove!(string_or_rx)
    sub!(string_or_rx, '')
  end

  def remove_all(string_or_rx)
    gsub(string_or_rx, '')
  end

  def remove_all!(string_or_rx)
    gsub!(string_or_rx, '')
  end

  # Return the constant that this string refers to, or nil if ActiveSupport cannot load such a
  # constant. This is much safer than `rescue NameError`, as that will mask genuine NameErrors
  # that have been made in the code being loaded (#safe_constantize will not)
  def safe_constantize
    Object.class_eval self
  rescue NameError => e
    # Unfortunately we have to rely on the error message to figure out which constant was missing.
    # NameError has a #name method but it is always nil
    if e.message !~ /\b#{self}$/
      # oops - some other name error
      raise
    else
      nil
    end
  end


end