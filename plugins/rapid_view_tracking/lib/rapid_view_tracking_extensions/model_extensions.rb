module RapidViewTrackingExtensions
  
  module ModelExtensions

    def self.included(mod)
      base::ClassMethods.send :include, ClassMethods
    end

    module ClassMethods
      def track_viewings(options={})
        track_users    = options[:track_users]    || true
        count_viewings = options[:count_viewings] || true
        track_if       = options[:track_if]       || proc {|user, target| !viewer.guest? }
        count_if       = options[:count_if]       || proc {|user, target| user != target.get_creator }
        counter_field  = options[:counter_field]  || :view_counter
        viewing_class  = options[:viewing_class]  || "Viewing"

        
        fields { |f| f.field counter_field, :integer, :default => 0 } if view_counter
        
        has_many :viewings, :class_name => viewing_class, :as => options[:as] if track_users
        
        define_method :view! do |viewer|
          if track_users && track_if[viewer, self]
            if (v = viewings.find(:viewer => viewer))
              v.save # save it to set new updated_at
            else
              v.create(:viewer => viewer)
            end
          end
          if count_viewings && count_if[viewer, self]
            self.class.increment_counter(counter_field, id)
          end
        end
        
      end
    end

  end

end
