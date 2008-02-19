module HoboFields
  
  class Percentage < DelegateClass(Fixnum)
    
    COLUMN_TYPE = :integer
    
    def validate
      "must be from 0 to 100" unless self.in?(0..100)
    end
    
    def to_html
      to_s
    end
      
    HoboFields.register_type(:percentage, self)
    
  end

end
