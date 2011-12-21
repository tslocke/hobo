module ActiveRecord
  module Associations
    class Association #:nodoc:
      def scoped
        # Rails implementation just returns target_scope.merge(association_scope)
        sc = target_scope.merge(association_scope)

        # Hobo adds in scopes declared on the association, e.g. has_many ..... :scope => :foo
        if (declared_scope = options[:scope])
          if declared_scope.is_a? Array
            declared_scope.inject(sc) { |result, element| result.merge(klass.send(element)) }
          elsif declared_scope.is_a? Hash
            method = declared_scope.keys.first
            arg = declared_scope.values.first
            sc.merge(klass.send(method, arg))
          else
            # It's just a symbol -- the name of a scope
            sc.merge(klass.send(declared_scope))
          end
        else
          sc
        end
      end
    end
  end
end
