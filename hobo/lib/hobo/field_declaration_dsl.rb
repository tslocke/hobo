module Hobo
  
  class FieldDeclarationsDsl
    
    def initialize(model)
      @model = model
    end
    
    attr_reader :model
    
    def timestamps
      field(:created_at, :datetime)
      field(:updated_at, :datetime)
    end
    
    def field(name, *args)
      type = args.shift
      options = args.extract_options!
      
      @model.name_attribute            = name.to_sym if options.delete(:name)
      @model.primary_content_attribute = name.to_sym if options.delete(:description)
      @model.creator_attribute         = name.to_sym if options.delete(:creator)

      @model.send(:login_attribute=, name.to_sym, options.delete(:validate)) if @model < User && options.delete(:login)
      
      @model.send(:set_field_type, name => type) unless
        type.in?(@model.connection.native_database_types.keys - [:text])
      @model.field_specs[name] = FieldSpec.new(@model, name, type, options)
      
      @model.send(:validates_presence_of, name)   if :required.in?(args)
      @model.send(:validates_uniqueness_of, name) if :unique.in?(args)
    end
    
    def method_missing(name, *args)
      field(name, *args)
    end
    
    undef_method :type
    
    
  end
  
end
