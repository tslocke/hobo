module RapidViewTrackingExtensions
  
  module ControllerExtensions

    def self.included(base)
      base.extend ClassMethods
    end
    
    private
    
    def record_viewing
      @this.view!(current_user) if allowed?
    end
    
    module ClassMethods
      
      def track_viewings(*actions)
        after_filter :record_viewing, :only => actions
      end
      
    end

  end

end
