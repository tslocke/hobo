# Thanks to _why

class Object

  def metaclass; class << self; self; end; end

  def meta_eval(src=nil, &blk)
    if src
      metaclass.instance_eval(src)
    else
      metaclass.instance_eval &blk
    end
  end

  def metaclass_eval(src=nil, &blk)
    if src
      metaclass.class_eval(src)
    else
      metaclass.class_eval &blk
    end
  end

  # Adds methods to a metaclass
  def meta_def(name, &blk)
    meta_eval { define_method name, &blk }
  end

end
