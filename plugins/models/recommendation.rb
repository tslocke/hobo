bundle_model :Recommendation do 
  
  fields do
    timestamps
  end

  belongs_to :user,    (_polymorphic_user_    ? { :polymorphic => true } : { :class_name => _RecommendationUser_ })
  belongs_to :subject, (_polymorphic_subject_ ? { :polymorphic => true } : { :class_name => _RecommendationSubject_ })
  
  def creatable_by?(user);         user == self.user; end
  def updatable_by?(user, new);    false; end
  def deletable_by?(deleter);      deleter == user; end
  def viewable_by?(viewer, field); viewer  == user; end

end