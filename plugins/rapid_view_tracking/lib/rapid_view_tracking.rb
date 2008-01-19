class RapidViewTracking < Hobo::Bundle
  
  module ModelControllerExtensions

    def self.included(base)
      base.class_eval do
        alias_method_chain :hobo_show, :view_tracking
      end
    end

    def hobo_show_with_view_tracking(*args, &b)
      hobo_show_without_view_tracking(*args) do
        @this.view!(current_user) if @this && @this.respond_to?(:view!) && valid?
        response_block(&b) or
          if not_allowed?
            permission_denied
          else
            hobo_render
          end
      end
    end

  end
  
  module ModelExtensions

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def track_viewings(options={})
        configuration = { :track_users => true, :view_counter => true, :counter_conditions => "", :viewer_conditions => "unless viewer.guest?" }
        configuration.update(options) if options.is_a?(Hash)
        
        target = self.name.underscore
        
        if configuration[:track_users]
          RapidViewTracking.new(options, :Viewing => "#{self.name}Viewing".to_sym, :Target => self.name.to_sym)
          has_many :viewings, :class_name => "#{self.name}Viewing"
        end
        
        if configuration[:view_counter]
          fields do
            view_counter :integer, :default => 0
          end
        end
        
        class_eval %{
          def view!(viewer)
            if #{configuration[:track_users]}
              v = viewings.find_or_create_by_user_id(viewer.id) #{configuration[:viewer_conditions]}
              v.save if v  # refresh updated_at
            end
            if #{configuration[:view_counter]}
              self.class.increment_counter(:view_counter, id) #{configuration[:counter_conditions]}
            end
          end
        }
        
      end
    end

  end
  
end