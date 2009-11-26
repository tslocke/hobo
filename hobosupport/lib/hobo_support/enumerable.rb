module Enumerable

  def map_and_find(not_found=nil)
    each do |x|
      val = yield(x)
      return val if val
    end
    not_found
  end

  def map_with_index(res=[])
    each_with_index {|x, i| res << yield(x, i)}
    res
  end

  def build_hash(res={})
    each do |x|
      pair = block_given? ? yield(x) : x
      res[pair.first] = pair.last if pair
    end
    res
  end

  def map_hash(res={})
    each do |x|
      v = yield x
      res[x] = v
    end
    res
  end

  def rest
    self[1..-1] || []
  end

  class MultiSender

    undef_method(*(instance_methods.map{|m| m.to_s} - %w*__id__ __send__ object_id*))

    def initialize(enumerable, method)
      @enumerable = enumerable
      @method     = method
    end

    def method_missing(name, *args, &block)
      @enumerable.send(@method) { |x| x.send(name, *args, &block) }
    end

  end

  def *()
    MultiSender.new(self, :map)
  end

  def where
    MultiSender.new(self, :select)
  end

  def where_not
    MultiSender.new(self, :reject)
  end

  def drop_while
    drop = 0
    drop += 1 while yield(self[drop])
    self[drop..-1]
  end


  def take_while
    take = 0
    take += 1 while yield(self[take])
    self[0..take-1]
  end

end


class Object

  def in?(enum)
    !enum.nil? && enum.include?(self)
  end

  def not_in?(enum)
    enum.nil? || !enum.include?(self)
  end

end
