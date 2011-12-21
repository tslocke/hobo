module ActiveRecord
  module Associations
    module JoinHelper
      def parent_table_name
        # Something v weird going on in Rails 3.1 - can't instantiate this class without this patch
        nil
      end
    end
  end
end

