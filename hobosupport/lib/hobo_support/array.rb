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

  # useful function from Rails 2.3
  if !respond_to? :wrap
    def self.wrap(object)
      case object
      when nil
        []
      when self
        object
      else
        if object.respond_to?(:to_ary)
          object.to_ary
        else
          [object]
        end
      end
    end
  end

end


