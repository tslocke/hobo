module HoboFields

  class IndexSpec

    def initialize(model, fields, options={})
      @model = model
      self.table = options.delete(:table_name) || model.table_name
      self.fields = Array.wrap(fields).*.to_s
      self.name = options.delete(:name) || model.connection.index_name(self.table, :column => self.fields)
      self.unique = options.delete(:unique) || false
    end

    attr_accessor :table, :fields, :name, :unique

    # extract IndexSpecs from an existing table
    def self.for_model(model, old_table_name=nil)
      t = old_table_name || model.table_name
      model.connection.indexes(t).map do |i|
        self.new(model, i.columns, :name => i.name, :unique => i.unique, :table_name => old_table_name) unless model.ignore_indexes.include?(i.name)
      end.compact
    end

    def default_name?
      name == @model.connection.index_name(table, :column => fields)
    end

    def to_add_statement(new_table_name)
      r = "add_index :#{new_table_name}, #{fields.*.to_sym.inspect}"
      r += ", :unique => true" if unique
      r += ", :name => '#{name}'" unless default_name?
      r
    end

    def hash
      [table, fields, name, unique].hash
    end

    def ==(v)
      v.hash == hash
    end
    alias_method :eql?, :==

  end

end
