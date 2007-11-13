module Hobo
  
  class Percentage < DelegateClass(Fixnum)
    
    COLUMN_TYPE = :integer
    
    def validate
      "must be from 0 to 100" unless self.in?(0..100)
    end
        
  end

end
Hobo.field_types[:percentage] = Hobo::Percentage
