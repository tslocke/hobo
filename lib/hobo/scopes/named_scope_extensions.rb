module ActiveRecord
  module NamedScope
    class Scope

      delegate :member_class, :to => :proxy_found

      def respond_to?(method)
        super || scopes.include?(method) || proxy_scope.respond_to?(method)
      end
      
      private
      
      def method_missing(method, *args, &block)
        if scopes.include?(method) || (!respond_to?(method) && proxy_scope.create_automatic_scope(method))
          scopes[method].call(self, *args)
        else
          with_scope :find => proxy_options do
            proxy_scope.send(method, *args, &block)
          end
        end
      end

    end
  end
end
