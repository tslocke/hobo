class TrueClass

  def implies(x=nil)
    block_given? ? yield : x
  end

end

class FalseClass

  def implies(x)
    true
  end

end
