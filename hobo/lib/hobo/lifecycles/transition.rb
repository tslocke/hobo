module Hobo
  
  module Lifecycles
    
    class Transition < Struct.new(:lifecycle, :name, :who, :start_states, :end_state, :on_transition, :options)
      
      include Actions
            
      
      def initialize(*args)
        super
        start_states.each do |from|
          state = lifecycle.states[from.to_s]
          raise ArgumentError, "No such state '#{from}' in #{'name'} transition (#{lifecycle.model.name})" unless state
          state.transitions_out << self
        end
        unless end_state.to_s == "destroy"
          state = lifecycle.states[end_state.to_s]
          raise ArgumentError, "No such state '#{end_state}' in '#{name}' transition (#{lifecycle.model.name})" unless state
          state.transitions_in << self
        end
        lifecycle.transitions << self
      end
      
            
      def allowed?(record, user, attributes=nil)
        prepare_and_check!(record, user, attributes) && true
      end
      
      
      def extract_attributes(attributes)
        update_attributes = options.fetch(:update, [])
        attributes & update_attributes
      end
      
      
      def run!(record, user, attributes)
        if prepare_and_check!(record, user, attributes)
          fire_event(record, on_transition)
          record.write_attribute lifecycle.options[:last_transition_at_field], Time.now
          record.become end_state
        else
          raise Hobo::Model::PermissionDeniedError
        end        
      end
      
      
      def set_or_check_who_with_key!(record, user, attributes)
        if who == :with_key
          
        end
      end
      

      def parameters
        options[:update] || []
      end


    end
    
  end
  
end
