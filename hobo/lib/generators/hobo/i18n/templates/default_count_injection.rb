
  # the default_count is called from i18n tags in order to produce the right pluralization
  # when no count is explicitly passed. It is normally used to generate a plural.
  # You can return different integers according to the needs of different languages
  # if you return the symbol :dynamic the count will be the model count
  # so the tag output will be singular or plural depending on the record count
  def default_count
    100 # fixed plural by default
  end

