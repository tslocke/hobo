# Hobo Tagging Plugin

module Hobo::Plugins
  
  class HoboTagging

    PLUGIN_DEFAULTS = {
      :tag => :tag,
      :tagging => :tagging,
      :target => :target
    }
    PLUGIN_SYMBOLS = [:tag, :tagging, :target]

    def default
      hobo_model :Tag do 
        fields do 
          string :name
        end
        
        has_many sym[:taggings]
        has_many sym[:targets], :through => sym[:taggings]

        def creatable_by?(user);       !user.guest?; end
        def updatable_by?(user, new);  !user.guest?; end
        def deletable_by?(user);       !user.guest?; end
        def viewable_by?(user, field); true;  end
      end
        
      hobo_model :Tagging do 
        belongs_to sym[:target]
        belongs_to sym[:tag]

        def creatable_by?(user);       !user.guest?; end
        def updatable_by?(user, new);  !user.guest?; end
        def deletable_by?(user);       !user.guest?; end
        def viewable_by?(user, field); true;  end
      end
      
    end

  end
  
end
