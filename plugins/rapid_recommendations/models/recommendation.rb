bundle_model :Recommendation do 
  
  fields do |f|
    f.comment _comment_format_, :primary_content => true
    f.timestamps
  end

  belongs_to :author, :class_name => _Author_, :polymorphic => :optional, :creator => true
  belongs_to :target, :class_name => _Target_, :polymorphic => :optional

  
  def duplicate_recommendation?
    # these methods are provided by the bundle; they return either the
    # fkey or fkey + type-name pair, according to whether the
    # association was set polymorphic or not.
    fields = self.class.author_fields + self.class.target_fields
    conditions = fields.map_hash {|f| send(f) }
    self.class.find(:first, :conditions => conditions)
  end
  
  
  def creatable_by?(user)
    user == author && !find_by_author_id && !duplicate_recommendation? && user != target.get_creator
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
