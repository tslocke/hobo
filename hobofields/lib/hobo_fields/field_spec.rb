module HoboFields

  class FieldSpec

    class UnknownSqlTypeError < RuntimeError; end

    def initialize(model, name, type, options={})
      raise ArgumentError, "you cannot provide a field spec for the primary key" if name == model.primary_key
      self.model = model
      self.name = name.to_sym
      self.type = type.is_a?(String) ? type.to_sym : type
      self.options = options
      self.position = model.field_specs.length
    end

    attr_accessor :model, :name, :type, :position, :options

    def sql_type
      options[:sql_type] or begin
                              if native_type?(type)
                                type
                              else
                                field_class = HoboFields.to_class(type)
                                field_class && field_class::COLUMN_TYPE or raise UnknownSqlTypeError, "#{type.inspect} for #{model}.#{name}"
                              end
                            end
    end

    def limit
      options[:limit] || native_types[sql_type][:limit]
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
      sql_type != col_spec.type ||
        begin
          check_attributes = [:null, :default]
          check_attributes += [:precision, :scale] if sql_type == :decimal
          check_attributes << :limit if sql_type.in?([:string, :text, :binary, :integer])
          check_attributes.any? { |k| col_spec.send(k) != self.send(k) }
        end
    end


    private

    def native_type?(type)
      type.in?(native_types.keys - [:primary_key])
    end

    def native_types
      MigrationGenerator.native_types
    end

  end

end
