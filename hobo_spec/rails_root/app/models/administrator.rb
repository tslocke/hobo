begin
  class Administrator < ActiveRecord::Base
  
  hobo_user_model :name
  
  fields do
    name :string
  end
  
  def super_user?
    true
  end
  
end


rescue Exception => e
puts e
end
