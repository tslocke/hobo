class Hobo::LazyHash < Hash
  
  def initialize(hash=nil)
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
  
  
  def delete(key)
    val = super
    val.is_a?(Proc) ? val.call : val
  end
  
  
  def inspect
    pairs = map do |k, v|
      "#{k.inspect} => #{v.is_a?(Proc) ? '??' : v.inspect}"
    end
    "{#{pairs * ', '}}"
  end
  
  
  def to_s
    inspect
  end
  
end
