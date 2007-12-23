class User < ActiveRecord::Base
  
  hobo_user_model
  
  fields do
    name :string, :login => true
  end
  
end
