bundle_model :Recommendation do 
  
  fields do |f|
    f.comment _comment_format_, :primary_content => true
    f.timestamps
  end

  belongs_to :author, :class_name => _Author_, :polymorphic => :optional, :creator => true
  belongs_to _target_, :class_name => _Target_, :polymorphic => :optional, :alias => :target

  
  def duplicate_recommendation?
    self.class.author_is(author).target_is(target).first
  end
  
  
  def creatable_by?(user)
    user == author &&               # you can't spoof a recommendation by somebody else
      !duplicate_recommendation? && # you can't recommend the same thing twice
      user != target.get_creator && # you can't recommend things you created
      target != user                # you can't recommend yourself
  end
  
  def updatable_by?(user, new)
    user == author || user.administrator? && only_changed_fields?(new, :comment)
  end
  
  def deletable_by?(deleter)
    deleter == author || user.administrator?
  end
  
  def viewable_by?(viewer, field)
    true
  end

end
