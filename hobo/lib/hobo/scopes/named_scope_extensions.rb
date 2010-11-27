module ActiveRecord
  module NamedScope
    class Scope

      delegate :member_class, :to => :proxy_found

      include Hobo::Scopes::ApplyScopes

      def respond_to_with_hobo_scopes?(method, include_private=false)
        scopes.include?(method) || proxy_scope.respond_to?(method, include_private) || respond_to_without_hobo_scopes?(method, include_private)
      end
      alias_method_chain :respond_to?, :hobo_scopes
      
      private
      
      def method_missing_with_hobo_scopes(method, *args, &block)
        respond_to?(method) # required for side effects, see LH#839
        method_missing_without_hobo_scopes(method, *args, &block)
      end
      alias_method_chain :method_missing, :hobo_scopes

    end
  end
end
