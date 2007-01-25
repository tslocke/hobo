class Object

  def in?(array)
    array.include?(self)
  end

  def not_in?(array)
    not array.include?(self)
  end
end


class Module
  
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

end

module Enumerable

  def omap(method = nil, &b)
    if method
      map(&method)
    else
      map {|x| x.instance_eval(&b)}
    end
  end

  def oselect(method = nil, &b)
    if method
      select(&method)
    else
      select {|x| x.instance_eval(&b)}
    end
  end

  def ofind(method=nil, &b)
    if method
      find(&method)
    else
      find {|x| x.instance_eval(&b)}
    end
  end

  def search(not_found=nil)
    each do |x|
      val = yield(x)
      return val if val
    end
    not_found
  end

  def oany?(method=nil, &b)
    if method
      any?(&method)
    else
      any? {|x| x.instance_eval(&b)}
    end
  end

  def oall?(method=nil, &b)
    if method
      all?(&method)
    else
      all? {|x| x.instance_eval(&b)}
    end
  end

  def every(proc)
    map(&proc)
  end

end

class Hash

  def self.build(array)
    array.inject({}) do |res, x|
      k, v = yield x
      res[k] = v
      res
    end
  end

  def select_hash(new_keys=nil, &b)
    res = {}
    if b
      each {|k,v| res[k] = v if yield(k,v) }
    else
      new_keys.each {|k| res[k] = self[k] if self.has_key?(k)}
    end
    res
  end

  #alias_method :hobo_original_reject, :reject
  def rejectX(keys=nil, &b)
    if b
      hobo_original_reject(&b)
    else
      res = {}.update(self) # can't use dup because it breaks with symbols
      keys.each {|k| res.delete(k)}
      res
    end
  end

  def partition_hash(keys=nil, &b)
    yes = {}
    no = {}
    each do |k,v|
      q = b ? yield(k,v) : keys.include?(k)
      if q
        yes[k] = v
      else
        no[k] = v
      end
    end
    [yes, no]
  end

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

