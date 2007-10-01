class Hobo::EmailAddress < String
  
  COLUMN_TYPE = :string
  
  def validate
    "is not a valid email address" unless 
      self.blank? || self =~ /^\s*([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\s*$/i
  end

end

Hobo.field_types[:email_address] = Hobo::EmailAddress
