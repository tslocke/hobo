class User < ActiveRecord::Base
  
  hobo_user_model :name
  
  fields do
    name :string
  end
  
  
end
