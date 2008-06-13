# The dot operator calls methods on objects. Power Dots are dots with extra features
#
#   .? calls a method if the reciever is not nil, returns nil
#   otherwise. We have to write it ._?. in order to be valid Ruby
#
#   .try. calls a mehod only if the recipient resonds to that method

require 'delegate'
require 'singleton'
require 'blankslate'

class Object

  def _?()
    self
  end

  def try
    CallIfAvailable.new(self)
  end

end


class NilClass
  def _?()
    SafeNil.instance
  end
end


class SafeNil
  include Singleton

  def method_missing(method, *args, &b)
    return nil unless nil.respond_to? method
    nil.send(method, *args, &b) rescue nil
  end
end


alias DelegateClass_without_safe_nil DelegateClass
def DelegateClass(klass)
  c = DelegateClass_without_safe_nil(klass)
  c.class_eval do
    def _?
      self
    end
  end
  c
end


class CallIfAvailable < BlankSlate

  def initialize(target)
    @target = target
  end

  def method_missing(name, *args, &b)
    @target.send(name, *args, &b) if @target.respond_to?(name)
  end

end


