class Module
  
  def included_in_class_callbacks(base)
    if base.is_a?(Class)
      included_modules.each { |m| m.included_in_class(base) if m.respond_to?(:included_in_class) }
    end
  end
  
  def inheriting_attr_accessor(*names)
    for name in names
      class_eval %{
        def #{name}
          if defined? @#{name}
            @#{name}
          elsif superclass.respond_to?('#{name}')
            superclass.#{name}
          end
        end
      }
    end
  end
  
  # Custom alias_method_chain that won't cause inifinite recursion if
  # called twice.
  # Calling alias_method_chain on alias_method_chain
  # was just way to confusing, so I copied it :-/
  def alias_method_chain(target, feature)
    # Strip out punctuation on predicates or bang methods since
    # e.g. target?_without_feature is not a valid method name.
    aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
    yield(aliased_target, punctuation) if block_given?
    without = "#{aliased_target}_without_#{feature}#{punctuation}"
    unless instance_methods.include?(without)
      alias_method without, target
      alias_method target, "#{aliased_target}_with_#{feature}#{punctuation}"
    end
  end

  
  # Fix delegate so it doesn't go bang if 'to' is nil
  def delegate(*methods)
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, ("Delegation needs a target. Supply an options hash with a :to key"  +
                            "as the last argument (e.g. delegate :hello, :to => :greeter).")
    end

    methods.each do |method|
      module_eval(<<-EOS, "(__DELEGATION__)", 1)
        def #{method}(*args, &block)
          (_to = #{to}) && _to.__send__(#{method.inspect}, *args, &block)
        end
      EOS
    end
  end
    
  private
  
  def bool_attr_accessor(*args)
    options = args.extract_options!
    (args + options.keys).each {|n| class_eval "def #{n}=(x); @#{n} = x; end" }
    
    args.each {|n| class_eval "def #{n}?; !!@#{n}; end" }

    options.keys.each do |n|
      class_eval %(def #{n}?
                     if @#{n}.nil? && !instance_variables.include?("@\#{@#{n}}")
                       @#{n} = #{options[n].inspect}
                     else
                       @#{n}
                     end
                   end)
      set_field_type(n => TrueClass) if respond_to?(:set_field_type)
    end
  end

end

module Kernel

  def it() It.new end
  alias its it
  
  def classy_module(&b)
    m = Module.new
    m.meta_def :included do |base|
      base.class_eval &b
    end
  end
  
end


class It

  undef_method(*(instance_methods - %w*__id__ __send__*))

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


class Object

  def in?(array)
    array.include?(self)
  end

  def not_in?(array)
    not array.include?(self)
  end
  
  alias_method :is_a_without_multiple_args?, :is_a?
  def is_a?(*args)
    args.any? {|a| is_a_without_multiple_args?(a) }
  end
  
  # metaid
  def metaclass; class << self; self; end; end
  
  def meta_eval(src=nil, &blk)
    if src
      meta_eval.instance_eval(src)
    else
      metaclass.instance_eval &blk
    end
  end

  # Adds methods to a metaclass
  def meta_def(name, &blk)
    meta_eval { define_method name, &blk }
  end

  # Defines an instance method within a class
  def class_def(name, &blk)
    class_eval { define_method name, &blk }
  end
  
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

class BlankSlate
  instance_methods.reject { |m| m =~ /^__/ }.each { |m| undef_method m }
  def initialize(me)
    @me = me
  end
end

class CallIfAvailable < BlankSlate
  
  def method_missing(name, *args, &b)
    @me.send(name, *args, &b) if @me.respond_to?(name)
  end
  
end



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


module Enumerable

  def search(not_found=nil)
    each do |x|
      val = yield(x)
      return val if val
    end
    not_found
  end

  def every(method, *args)
    map { |x| x.send(method, *args) }
  end
    
  def map_with_index
    res = []
    each_with_index {|x, i| res << yield(x, i)}
    res
  end
  
  def build_hash
    res = {}
    each do |x|
      k, v = yield x
      res[k] = v
    end
    res
  end
  
  def map_hash
    res = {}
    each do |x|
      v = yield x
      res[x] = v
    end
    res
  end
  
  def rest
    self[1..-1]
  end

  class MultiSender
 
    undef_method(*(instance_methods - %w*__id__ __send__*))

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
  
end

class Array
  
  alias_method :multiply, :*
  
  def *(rhs=nil)
    if rhs
      multiply(rhs)
    else
      Enumerable::MultiSender.new(self, :map)
    end
  end

end

class Hash

  def self.build(array)
    array.inject({}) do |res, x|
      pair = yield x
      res[pair[0]] = pair[1] unless pair.nil?
      res
    end
  end

  def select_hash(new_keys=nil)
    res = {}
    if block_given?
      each {|k,v| res[k] = v if yield(k,v) }
    else
      new_keys.each {|k| res[k] = self[k] if self.has_key?(k)}
    end
    res
  end
  
  def map_hash(&b)
    res = {}
    each {|k,v| res[k] = b.arity == 1 ? yield(v) : yield(k, v) }
    res
  end

  def partition_hash(keys=nil)
    yes = {}
    no = {}
    each do |k,v|
      if block_given? ? yield(k,v) : keys.include?(k)
        yes[k] = v
      else
        no[k] = v
      end
    end
    [yes, no]
  end
  
  def recursive_update(hash)
    hash.each_pair do |key, value|
      current = self[key]
      if current.is_a?(Hash) and value.is_a?(Hash)
        current.recursive_update(value)
      else
        self[key] = value
      end
    end
  end
  
  def -(keys)
    res = {}
    each_pair {|k, v| res[k] = v unless k.in?(keys)}
    res
  end
  
  def &(keys)
    res = {}
    keys.each {|k| res[k] = self[k] if has_key?(k)}
    res    
  end
  
  alias_method :| , :merge
  
  def get(*args)
    args.map {|a| self[a] }
  end
  
end


class HashWithIndifferentAccess
  
  def -(keys)
    res = HashWithIndifferentAccess.new
    keys = keys.map {|k| k.is_a?(Symbol) ? k.to_s : k }
    each_pair { |k, v| res[k] = v unless k.in?(keys) }
    res
  end
  
  def &(keys)
    res = HashWithIndifferentAccess.new
    keys.each do |k|
      k = k.to_s if k.is_a?(Symbol)
      res[k] = self[k] if has_key?(k)
    end
    res    
  end
  
  def partition_hash(keys=nil)
    keys = keys._?.map {|k| k.is_a?(Symbol) ? k.to_s : k }
    yes = HashWithIndifferentAccess.new
    no = HashWithIndifferentAccess.new
    each do |k,v|
      if block_given? ? yield(k,v) : keys.include?(k)
        yes[k] = v
      else
        no[k] = v
      end
    end
    [yes, no]
  end
  
end


class <<ActiveRecord::Base
  alias_method :[], :find
end


# --- Fix Chronic - can't parse '12th Jan' --- #
begin
  require 'chronic'
  
  module Chronic
    
    class << self
      def parse_with_hobo_fix(s)
        parse_without_hobo_fix(if s =~ /^\s*\d+\s*(st|nd|rd|th)\s+[a-zA-Z]+(\s+\d+)?\s*$/
                                 s.sub(/\s*\d+(st|nd|rd|th)/) {|s| s[0..-3]}
                               else
                                 s
                               end)
      end
      alias_method_chain :parse, :hobo_fix
    end
  end
rescue MissingSourceFile; end



# --- Fix pp dumps - these break sometimes without this --- #
require 'pp'
module PP::ObjectMixin

  alias_method :orig_pretty_print, :pretty_print
  def pretty_print(q)
    orig_pretty_print(q)
  rescue
    "[#PP-ERROR#]"
  end

end

class Proc
  
  def call_with_block(*args, &b)
    call(*args + [b])
  end
  
end
