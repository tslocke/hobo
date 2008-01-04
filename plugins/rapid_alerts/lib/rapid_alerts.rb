class RapidAlerts < Hobo::Bundle
    
  def defaults
    { :polymorphic_user => false, :polymorphic_subject => false, :AlertUser => :User }
  end
    
end
