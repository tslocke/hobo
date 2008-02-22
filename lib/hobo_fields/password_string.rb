module HoboFields
  
  class PasswordString < String
    
    COLUMN_TYPE = :string
    
    HoboFields.register_type(:password, self)

  end

end
