module ::Hobo::Plugins
  class HoboAlerts < HoboPlugin
    PLUGIN_DEFAULTS = {
      :alert => :alert,
      :user => :user,
      :subject => :subject,
      :polymorphic_user    => false,
      :polymorphic_subject => false
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
          name :string
          timestamps
        end
        belongs_to(sym[:user],    :polymorphic => sym[:polymorphic_user])
        belongs_to(sym[:subject], :polymorphic => sym[:polymorphic_subject])
        
        alias_method :user,    sym[:user]    unless sym[:user]    == :user
        alias_method :subject, sym[:subject] unless sym[:subject] == :subject
        
        def self.alert(users, subject, name)
          users.each { |u| create(:user => u, :subject => subject, :name => name.to_s) }
        end
        
        def creatable_by?(user);         false; end
        def updatable_by?(user, new);    false; end
        def deletable_by?(deleter);      deleter == user; end
        def viewable_by?(viewer, field); viewer == user;  end
      end
    end

    def alerts_controller
      resource_controller :AlertsController do
      end
    end
  end
end
