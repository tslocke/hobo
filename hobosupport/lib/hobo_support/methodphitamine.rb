# From: http://jicksta.com/articles/2007/08/04/the-methodphitamine

require 'blankslate'

module Kernel

  def it() It.new end
  alias its it

end

class It < BlankSlate

  def initialize
    @methods = []
  end

  def method_missing(*args, &block)
    @methods << [args, block] unless args == [:respond_to?, :to_proc]
    self
  end

  def to_proc
    lambda do |obj|
      @methods.inject(obj) do |current,(args,block)|
        current.send(*args, &block)
      end
    end
  end

end
