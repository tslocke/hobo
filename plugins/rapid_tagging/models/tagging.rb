bundle_model :Tagging do 
  
  belongs_to :tag,    :class_name => _Tag_
  belongs_to :target, :class_name => _TagTarget_

  def creatable_by?(user);       user.administrator? end
  def updatable_by?(user, new);  user.administrator? end
  def deletable_by?(user);       user.administrator? end
  def viewable_by?(user, field); false; end

end
