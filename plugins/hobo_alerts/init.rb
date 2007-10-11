module ::Hobo::Plugins
  class HoboComments < HoboPlugin
    PLUGIN_DEFAULTS = {
      :user => :user
    }
    PLUGIN_SYMBOLS = [:alert]

    def default
      alerts
    end

    def alerts
      alert_model
      alerts_controller
    end

    def alert_model
      hobo_model :Alert do
        fields do
          message :text
          link    :string
          timestamps
        end
        belongs_to sym[:user]
        alias_method :user, sym[:target] unless sym[:target] == :user
        
        def creatable_by?(user);         false; end
        def updatable_by?(user, new);    false; end
        def deletable_by?(user);         false; end
        def viewable_by?(viewer, field); viewer == user;  end
      end
    end

    def alerts_controller
      resource_controller :AlertsController do
      end
    end
  end
end
