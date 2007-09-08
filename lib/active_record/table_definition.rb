module ActiveRecord::ConnectionAdapters

  class TableDefinition

    def fkey(*args)
      options = take_options!(args)
      args.each {|col| column("#{col}_id".to_sym, :integer, options)}
    end

    def auto_dates
      column :created_at, :datetime
      column :updated_at, :datetime
    end

    def method_missing(name, *args)
      if name.in? [:integer, :float, :decimal, :datetime, :date, :timestamp,
                      :time, :text, :string, :binary, :boolean ]
        options = take_options!(args)
        args.each {|col| column(col, name, options)}
      else
        super
      end
    end


    private

    def take_options!(args)
      args.last.is_a?(Hash) ? args.pop : {}
    end

  end

end
