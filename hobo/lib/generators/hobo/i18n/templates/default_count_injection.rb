
  # the default_count is passed as the count value to i18n tags
  # in order to produce the right pluralization
  # you can return different integers according to the needs of different languages
  # if you return the symbol :dynamic the count will be the model count
  # so the tag output will be singular or plural depending on the record count
  def default_count
    100
  end

