class Hobo::LazyArray < Array
  
  def initialize(*args)
    if args.first && args.first.is_a?(Array)
      concat(args.first)
    else
      super
    end
  end
  
  def [](index)
    val = super
    if val.is_a?(Proc)
      self[index] = val.call
    else
      val
    end
  end
  
  def inspect
    "[#{map {|x| x.is_a?(Proc) ? '??' : x.inspect} * ', '}]"
  end
  
  def to_s
    inspect
  end
  
end
