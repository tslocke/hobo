class User < ActiveRecord::Base
  
  hobo_user_model
  
  fields do
    name :string
  end
  
  set_login_attr :name
  
  
end
