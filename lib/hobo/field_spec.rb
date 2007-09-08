module Hobo
  
  class FieldSpec
    
    class UnknownSqlTypeError < RuntimeError; end
  
    def initialize(model, name, type, options={})
      raise ArgumentError, "you cannot provide a field spec for the primary key" if name == model.primary_key
      self.model = model
      self.name = name.to_sym
      self.type = type.to_sym
      self.options = options
      self.position = model.field_specs.length
    end
    
    attr_accessor :model, :name, :type, :position, :options
    
    def sql_type
      options[:sql_type] or begin
                              sql_types = model.connection.native_database_types.keys - [:primary_key]
                              if type.in?(sql_types)
                                type
                              elsif options[:length]
                                :string
                              else
                                field_type = Hobo.field_types[type]
                                field_type && field_type::COLUMN_TYPE or raise UnknownSqlTypeError, [model, name, type]
                              end
                            end
    end
    
    def limit
      options[:limit] || types[sql_type][:limit]
    end
    
    def precision
      options[:precision]
    end
    
    def scale
      options[:scale]
    end
    
    def null
      :null.in?(options) ? options[:null] : true
    end
    
    def default
      options[:default]
    end
    
    def different_to?(col_spec)
      [:limit, :precision, :scale, :null, :default].any? do |k|
        # puts "#{col_spec.send(k).inspect} --- #{self.send(k).inspect} : #{col_spec.send(k) != self.send(k)}"
        col_spec.send(k) != self.send(k)
      end || sql_type != col_spec.type
    end
    
    private
    
    def types
      @types ||= model.connection.native_database_types
    end
    
  end
  
end
