bundle_model :Viewing do
  fields do
    timestamps
  end
  
  belongs_to _user_
  belongs_to _target_
end