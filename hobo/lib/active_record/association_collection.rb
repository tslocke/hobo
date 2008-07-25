module ActiveRecord
  module Associations
    class AssociationCollection

      include Hobo::Scopes::ApplyScopes


      def hobo_association_collection?
        Hobo::Model.in?(@owner.class.included_modules)
      end


      def build_with_reverse_reflection(*args)
        res = build_without_reverse_reflection(*args)
	set_reverse_association(res) if hobo_association_collection?
	res
      end
      alias_method_chain :build, :reverse_reflection


      def new(attributes = {})
        record = @reflection.klass.new(attributes)
	if hobo_association_collection?
	  set_belongs_to_association_for(record)
	  set_reverse_association(record) unless proxy_reflection.options[:as]
	end
	record
      end


      def member_class
        proxy_reflection.klass
      end


      def proxy_respond_to_with_automatic_scopes?(method, include_priv = false)
        proxy_respond_to_without_automatic_scopes?(method, include_priv) || create_automatic_scope(method)
      end
      alias_method_chain :proxy_respond_to?, :automatic_scopes


      protected

      # hack/fix to change the order in which to look for missing methods
      # without this, the proxy's target (which is [] initially) is checked first for the method.
      # after that, (automatic) scopes are looked for.
      # this is problematic for the 'search' scope, since the initial [] also responds to #search
      # because of HoboSupport's enumerable extension
      def method_missing_with_automatic_scopes(method, *args, &block)
        if @reflection.klass.respond_to?(method) && @reflection.klass.scopes.include?(method)
          @reflection.klass.scopes[method].call(self, *args)
        else
          method_missing_without_automatic_scopes(method, *args, &block)
	end
      end
      alias_method_chain :method_missing, :automatic_scopes


      private


        def set_reverse_association(object)
	  if @owner.new_record? && (refl = @owner.class.reverse_reflection(@reflection.name))
	    bta = ActiveRecord::Associations::BelongsToAssociation.new(object, refl)
	    bta.replace(@owner)
	    object.instance_variable_set("@#{refl.name}", bta)
	  end
	end

    end
  end
end
