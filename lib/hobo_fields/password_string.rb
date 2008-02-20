class Hobo::PasswordString < String
  
  COLUMN_TYPE = :string
  
  HoboFields.register_type(:password, self)

end
