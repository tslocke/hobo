module Hobo
  module Model
    module Scopes

      ::ActiveRecord::Associations::Builder::Association.valid_options << :scope

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
