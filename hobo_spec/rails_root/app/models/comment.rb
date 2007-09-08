class Comment < ActiveRecord::Base
  
  hobo_model
  
  fields do
    author :string
    body :text
    timestamps
  end
  
  belongs_to :post
  
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
    deleter == post.user
  end

  
end
