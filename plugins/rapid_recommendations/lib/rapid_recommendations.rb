class RapidRecommendations < Hobo::Bundle
    
  def defaults
    { :polymorphic_author => false, :polymorphic_target => false, :comment_format => :text, :Author => :User }
  end
    
end
