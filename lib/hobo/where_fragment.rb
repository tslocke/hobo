module Hobo

  class WhereFragment

    def initialize(sql, *params)
      @sql = params.empty? ? sql : ActiveRecord::Base.send(:sanitize_sql, [sql] + params)
    end

    def &(rhs)
      WhereFragment.new("(#{to_sql}) and (#{rhs.to_sql})")
    end

    def |(rhs)
      WhereFragment.new("(#{to_sql}) or (#{rhs.to_sql})")
    end

    def to_sql
      @sql
    end

  end

end
