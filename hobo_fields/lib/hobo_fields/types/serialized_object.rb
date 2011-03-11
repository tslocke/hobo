module HoboFields
  module Types
    class SerializedObject < Object

      COLUMN_TYPE = :text

      def self.declared(model, name, options)
        model.serialize name, options.delete(:class) || Object
      end

      HoboFields.register_type(:serialized, self)

    end
  end
end
