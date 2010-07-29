class Module

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
    unless method_defined?(without)
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

end
