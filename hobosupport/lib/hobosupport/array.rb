class Array

  alias_method :multiply, :*

  def *(rhs=nil)
    if rhs
      multiply(rhs)
    else
      Enumerable::MultiSender.new(self, :map)
    end
  end

  def drop_while!
    drop = 0
    drop += 1 while yield(self[drop])
    self[0..drop-1] = []
    self
  end

end


