class Hobo::PasswordString < String
  
  COLUMN_TYPE = :string

end

Hobo.field_types[:password] = Hobo::PasswordString
