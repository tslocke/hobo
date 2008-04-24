module Hobo
  module Lifecycles
    
    class Creator < Struct.new(:lifecycle, :name, :who, :on_create, :options)
      
      def initialize(*args)
        super
        lifecycle.creators[name] = self
      end
      
      include Actions
      
      def check_preconditions(record)
        record.lifecycle.preconditions_satisfied?
      end
      
      
      def prepare_and_check_with_preconditions!(record, user, attributes=nil)
        prepare_and_check_without_preconditions!(record, user, attributes) && check_preconditions(record)
      end
      alias_method_chain :prepare_and_check!, :preconditions

      
      def allowed?(user, attributes=nil)
        record = lifecycle.model.new
        prepare_and_check!(record, user, attributes)
      end
      
      
      def candidate(user, attributes=nil)
        record = lifecycle.model.new
        prepare_and_check!(record, user, attributes)
        record.exempt_from_edit_checks = true
        record
      end
      
      
      def extract_attributes(attributes)
        model = lifecycle.model
        params = options.fetch(:params, [])
        allowed = params.dup
        params.each do |p|
          if (refl = model.reflections[p]) && refl.macro == :belongs_to
            allowed << refl.primary_key_name.to_s
          end
        end
        attributes & allowed
      end

      
      def change_state(record)
        state = options[:become]
        record.become(state) if state
      end
      
      
      def run!(user, attributes)
        record = lifecycle.model.new
        if prepare_and_check!(record, user, attributes)
          fire_event(record, on_create)
          change_state(record)
          record
        else
          raise Hobo::Model::PermissionDeniedError
        end
      end
      
      
      def parameters
        options[:params] || []
      end
      
    end
    
  end
end
