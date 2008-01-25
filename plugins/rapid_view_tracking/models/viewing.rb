bundle_model :Viewing do
  
  fields do
    timestamps
  end
  
  belongs_to :viewer, :class_name => _Viewer_, :polymorphic => :optional
  belongs_to :target, :class_name => _Target_, :polymorphic => :optional
  
end
