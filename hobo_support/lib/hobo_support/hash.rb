class Hash

  def select_hash(&b)
    res = {}
    each {|k,v| res[k] = v if (b.arity == 1 ? yield(v) : yield(k, v)) }
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

  def compact
    res = {}
    each { |k, v| res[k] = v unless v.nil? }
    res
  end

  def compact!
    keys.each { |k| delete(k) if self[k].nil? }
  end

  # Ruby 1.9.1 complains about the use of index and recommends key
  # but Ruby 1.8 doesn't have key.  Add it.
  alias_method(:key, :index) unless method_defined?(:key)

end


# HashWithIndifferentAccess from ActiveSupport needs different
# versions of these

if defined? HashWithIndifferentAccess

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

end

if defined? ActiveSupport
  class ActiveSupport::OrderedHash
    alias each_pair each

    def first
      empty? ? nil : [keys.first, values.first]
    end
  end
end
