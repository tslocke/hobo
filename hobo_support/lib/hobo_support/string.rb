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

end