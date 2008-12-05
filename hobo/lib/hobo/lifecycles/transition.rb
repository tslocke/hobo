module Hobo

  module Lifecycles

    class Transition < Struct.new(:lifecycle, :name, :start_states, :end_state, :on_transition, :options)

      include Actions


      def initialize(*args)
        super
        self.name = name.to_sym
        start_states.each do |from|
          state = lifecycle.states[from]
          raise ArgumentError, "No such state '#{from}' in #{name} transition (#{lifecycle.model.name})" unless state
          state.transitions_out << self
        end
        lifecycle.transitions << self
      end


      def extract_attributes(attributes)
        update_attributes = options.fetch(:update, [])
        attributes & update_attributes
      end
        
      
      def change_state(record)
        record.lifecycle.become(get_state(record, end_state))
      end


      def run!(record, user, attributes)
        current_state = record.lifecycle.state_name
        unless start_states.include?(current_state)
          raise Hobo::Lifecycles::LifecycleError, "Transition #{record.class}##{name} cannot be run from the '#{current_state}' state"
        end
        record.lifecycle.active_step = self
        record.with_acting_user(user) do
          prepare!(record, attributes)
          if can_run?(record)
            if change_state(record)
              fire_event(record, on_transition)
            end
          else
            raise Hobo::PermissionDeniedError
          end
        end
      end


      def parameters
        options[:update] || []
      end


    end

  end

end
