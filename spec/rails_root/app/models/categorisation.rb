class Categorisation < ActiveRecord::Base
  
  hobo_model
  
  belongs_to :post
  belongs_to :category
  
  def viewable_by?(user, field)
    true
  end
  
  def creatable_by?(creator)
    creator == post.user
  end
  
  def updatable_by?(updater, new)
    updater == post.user
  end
  
  def deletable_by?(deleter)
    updater == post.user
  end

  
end
