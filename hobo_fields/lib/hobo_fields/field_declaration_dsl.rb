require 'hobo_fields/enum_string'

module HoboFields

  class FieldDeclarationDsl < BlankSlate

    include HoboFields::EnumString::DeclarationHelper

    def initialize(model)
      @model = model
    end

    attr_reader :model


    def timestamps
      field(:created_at, :datetime)
      field(:updated_at, :datetime)
    end


    def field(name, type, *args)
      @model.declare_field(name, type, *args)
    end


    def method_missing(name, *args)
      field(name, args.first, *args.rest)
    end

  end

end
