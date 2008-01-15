bundle_model :Recommendation do 
  
  fields do
    comment _comment_format_, :primary_content => true
    timestamps
  end

  belongs_to :author, (_polymorphic_user_    ? { :polymorphic => true } : { :class_name => _Author_ }), :creator => true
  belongs_to :target, (_polymorphic_subject_ ? { :polymorphic => true } : { :class_name => _Target_ })
  
  def creatable_by?(user);         user == self.user; end
  def updatable_by?(user, new);    user == self.user; end
  def deletable_by?(deleter);      deleter == user; end
  def viewable_by?(viewer, field); true end

end
