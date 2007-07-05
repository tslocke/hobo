module Hobo
  
  class FieldSpec
    
    class UnknownSqlTypeError < RuntimeError; end
  
    DEFAULT_SQL_TYPES = {
      :html => :text,
      :markdown => :text,
      :textile => :text
    }
    
    SQL_TYPES = [ :integer, :float, :decimal, :datetime, :date, :timestamp, :time, :text, :string,
                  :binary, :boolean ]
  
    def initialize(model, name, type, options={})
      raise ArgumentError, "you cannot provide a field spec for the primary key" if name == model.primary_key
      self.model = model
      self.name = name.to_sym
      self.type = type.to_sym
      self.options = options
    end
    
    attr_accessor :model, :name, :type, :options
    
    def sql_type
      options[:sql_type] or begin
                              sql_types = model.connection.native_database_types.keys - [:primary_key]
                              if type.in?(SQL_TYPES)
                                type
                              elsif options[:length]
                                :string
                              else
                                DEFAULT_SQL_TYPES[type] or raise UnknownSqlTypeError, type
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
