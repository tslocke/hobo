module ActiveRecord
  module Associations
    class AssociationCollection

      include Hobo::Scopes::ApplyScopes


      def hobo_association_collection?
        Hobo::Model.in?(@owner.class.included_modules)
      end


      def new_candidate(attributes = {})
        record = new
        @target.delete record
        set_reverse_association(record) if hobo_association_collection?
        record
      end


      def user_new_candidate(user, attributes = {})
        record = user_new(user, attributes)
        @target.delete record
        set_reverse_association(record) if hobo_association_collection?
        record
      end

      # DO NOT call super here - AssociationProxy's version loads the collection, and that's bad.
      # TODO: this really belongs in Rails; migrate it there ASAP
      def respond_to?(*args)
        proxy_respond_to?(*args) || Array.new.respond_to?(*args)
      end

      # TODO: send this patch into Rails. There's no reason to load the collection just to find out it acts like an array.
      def is_a?(klass)
        [].is_a?(klass)
      end

      def member_class
        proxy_reflection.klass
      end

      private

        def set_reverse_association(object)
          if @owner.new_record? &&
              (refl = @owner.class.reverse_reflection(@reflection.name)) &&
              refl.macro == :belongs_to
            bta = ActiveRecord::Associations::BelongsToAssociation.new(object, refl)
            bta.replace(@owner)
            object.instance_variable_set("@#{refl.name}", bta)
          end
        end

    end
  end
end
