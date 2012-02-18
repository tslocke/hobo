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

  # we used to have a delegate in here that didn't go bang if 'to' is
  # nil.  If you relied on it, use the new :allow_nil option with
  # active_support's delegate

end
