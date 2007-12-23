bundle_model :Tagging do 
  
  belongs_to _tag_
  belongs_to _tag_target_

  def creatable_by?(user);       user.administrator? end
  def updatable_by?(user, new);  user.administrator? end
  def deletable_by?(user);       user.administrator? end
  def viewable_by?(user, field); false; end

end
