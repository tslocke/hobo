class Hobo::LazyHash < Hash
  
  def initialize(hash)
    if hash.is_a?(Hash)
      update(hash)
    else
      super
    end
  end
  
  def [](key)
    val = super
    if val.is_a?(Proc)
      self[val] = val.call
    else
      val
    end
  end
  
  
end
