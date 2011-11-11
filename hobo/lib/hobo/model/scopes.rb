module Hobo
  module Model
    module Scopes

      ::ActiveRecord::Associations::Builder::BelongsTo.valid_options << :scope
      ::ActiveRecord::Associations::Builder::HasMany.valid_options << :scope
      ::ActiveRecord::Associations::Builder::HasOne.valid_options << :scope

      def self.included_in_class(klass)
        klass.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods

        include AutomaticScopes

        include ApplyScopes

      end

    end
  end
end
