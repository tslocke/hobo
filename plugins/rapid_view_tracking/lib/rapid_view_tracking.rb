class RapidViewTracking < Hobo::Bundle
  
  module ModelControllerExtensions
    
    
    
  end
  
  module ModelExtensions
    
    def included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def track_viewings(options={})
        RapidViewTracking.new(options, :Target => )
        has_many 
      end
    end
    
  end
  
end
