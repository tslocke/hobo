module ::Hobo::Plugins
  class HoboComments < HoboPlugin
    PLUGIN_DEFAULTS = {
      :comment       => :comment,
      :target        => :target
    }
    PLUGIN_SYMBOLS = [:comment]

    def default
      comments
    end

    def comments
      comments_model
      comments_controller
    end

    def comments_model
      hobo_model :Comment do
        fields do
          author  :string
          body    :text
          website :string
          timestamps
        end
        belongs_to sym[:target]
        alias_method :target, sym[:target]
        
        def creatable_by?(user);      true; end
        def updatable_by?(user, new); false; end
        def deletable_by?(user);      user.super_user?; end
        def viewable_by?(user, field); true;  end
      end
    end

    def comments_controller
      resource_controller :CommentsController do
      end
    end
  end
end
