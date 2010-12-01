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
          write_inheritable_attribute(:scopes, new_automatic_scoping_hash(self))
        elsif hash.default_proc.nil?
          write_inheritable_attribute(:scopes, new_automatic_scoping_hash(self).merge!(hash))
        else
          hash
        end

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

