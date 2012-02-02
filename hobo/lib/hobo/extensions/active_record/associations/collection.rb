module ActiveRecord
  module Associations
    class CollectionProxy

      include Hobo::Model::Scopes::ApplyScopes


      def hobo_association_collection?
        Hobo::Model.in?(proxy_association.owner.class.included_modules)
      end


      def new_candidate(attributes = {})
        record = new
        proxy_association.target.delete record
        set_reverse_association(record) if hobo_association_collection?
        record
      end


      def user_new_candidate(user, attributes = {})
        record = user_new(user, attributes)
        proxy_association.target.delete record
        set_reverse_association(record) if hobo_association_collection?
        record
      end

      def is_a?(klass)
        if has_one_collection?
          load_target
          proxy_association.target.is_a?(klass)
        else
          [].is_a?(klass)
        end
      end

      def member_class
        proxy_association.reflection.klass
      end

      private

        def set_reverse_association(object)
          if proxy_association.owner.new_record? &&
              (refl = proxy_association.owner.class.reverse_reflection(proxy_association.reflection.name)) &&
              refl.macro == :belongs_to
            object.send("#{refl.name}=", proxy_association.owner)
          end
        end

        def has_one_collection?
          proxy_association.reflection.macro == :has_one
        end

    end
  end
end
