bundle_model :Recommendation do 
  
  fields do |f|
    f.comment _comment_format_, :primary_content => true
    f.timestamps
  end

  belongs_to :author, :class_name => _Author_, :polymorphic => :optional, :creator => true
  belongs_to :target, :class_name => _Target_, :polymorphic => :optional
  
  def creatable_by?(user)
    user == author
  end
  
  def updatable_by?(user, new)
    user == author || user.administrator?
  end
  
  def deletable_by?(deleter)
    deleter == author || user.administrator?
  end
  
  def viewable_by?(viewer, field)
    true
  end

end
