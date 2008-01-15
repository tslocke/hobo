bundle_model :Recommendation do 
  
  fields do |f|
    f.comment _comment_format_, :primary_content => true
    f.timestamps
  end

  belongs_to :author, (_polymorphic_author_ ? { :polymorphic => true } : { :class_name => _Author_ }).update(:creator => true)
  belongs_to :target, (_polymorphic_target_ ? { :polymorphic => true } : { :class_name => _Target_ })
  
  def creatable_by?(user);         user == author; end
  def updatable_by?(user, new);    user == author; end
  def deletable_by?(deleter);      deleter == author; end
  def viewable_by?(viewer, field); true end

end
