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
        record
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
