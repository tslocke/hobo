module ActiveRecord
  module NamedScope
    class Scope

      delegate :member_class, :to => :proxy_found

      include Hobo::Scopes::ApplyScopes

      def respond_to?(method, include_private=false)
        super || scopes.include?(method) || proxy_scope.respond_to?(method, include_private)
      end
      
      private
      
      def method_missing(method, *args, &block)
        if respond_to?(method) && scopes.include?(method)
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
