module ActiveRecord
  module NamedScope
    
    class Scope      
      delegate :member_class, :to => :proxy_found      
      include Hobo::Scopes::ApplyScopes      
    end

    module ClassMethods
      def scopes
        hash = read_inheritable_attribute(:scopes)
        if hash.nil?
          if respond_to?(:create_automatic_scope)
            write_inheritable_attribute(:scopes, new_automatic_scoping_hash(self))
          else
            # add a default_proc to optimize the next condition
            write_inheritable_attribute(:scopes, Hash.new { |hash, key| nil })
          end
        elsif hash.default_proc.nil? && respond_to?(:create_automatic_scope)
          write_inheritable_attribute(:scopes, new_automatic_scoping_hash(self).merge!(hash))
        else
          hash
        end
      end
      
      private
      
      def new_automatic_scoping_hash(o)
        hash = Hash.new { |hash, key| o.create_automatic_scope(key) && hash[key] }
        hash.meta_eval do
          define_method :include? do |key, *args|
            super(key, *args) || o.create_automatic_scope(key)
          end
        end
        hash
      end
    end
  end
end
