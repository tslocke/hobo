module HoboFields
  
  class PasswordString < String
    
    COLUMN_TYPE = :string
    
    HoboFields.register_type(:password, self)
    
    def to_html
      "[password hidden]"
    end

  end

end
