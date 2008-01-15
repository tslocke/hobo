class RapidRecommendations < Hobo::Bundle
    
  def defaults
    { :polymorphic_user => false, :polymorphic_subject => false, :RecommendationUser => :User }
  end
    
end
