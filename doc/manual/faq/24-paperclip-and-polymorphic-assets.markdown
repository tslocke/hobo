# Paperclip and polymorphic assets

Originally written by marton on 2008-11-04.

I would like to see a receipt on how to have a common Asset table to store fileuploads to your site. Very often models needs pictures and it should not be nessesary to have the assets spread? (maybe you do not agree here).

I would like to see a :
class Asset < ActiveRecord::Base
   belongs_to :storable_object, :polymorphic => true
end

Then in for instance you user model:
class User < ActiveRecord::Base
...
  has_many :images, :as => :storable_object
...
end
