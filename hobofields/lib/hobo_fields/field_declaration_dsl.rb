module HoboFields

  class FieldDeclarationDsl < BlankSlate

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
      field(name, *args)
    end

  end

end
