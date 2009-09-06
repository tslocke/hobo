module HoboFields

  class IndexSpec

    def initialize(model, fields, options={})
      self.table = model.table_name
      self.fields = Array.wrap(fields).*.to_s
      self.name = options.delete(:name) || model.connection.index_name(self.table, :column => self.fields)
      self.unique = options.delete(:unique) || false
    end

    attr_accessor :table, :fields, :name, :unique

    # extract IndexSpecs from an existing table
    def self.for_model(model)
      t = model.table_name
      model.connection.indexes(t).map do |i|
        self.new(model, i.columns, :name => i.name, :unique => true)
      end
    end

  end

end
