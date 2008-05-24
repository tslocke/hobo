module Hobo

  module Lifecycles

    class Lifecycle

      def self.init(model, options)
        @model   = model
        @options = options
        reset
      end

      def self.reset
        @states        = {}
        @creators      = {}
        @transitions   = []
        @preconditions = []
        @invariants    = []
      end

      class << self
        attr_accessor :model, :options, :states, :initial_state,
                      :creators, :transitions, :invariants, :preconditions
      end

      def self.def_state(name, on_enter)
        name = name.to_s
        returning(State.new(name, on_enter)) do |s|
          states[name] = s
          class_eval "def #{name}?; record.state == '#{name}'; end"
        end
      end


      def self.def_creator(name, who, on_create, options)
        name = name.to_s
        returning(Creator.new(self, name, who, on_create, options)) do |creator|

          class_eval %{
                       def self.#{name}(user, attributes=nil)
                         create('#{name}', user, attributes)
                       end
                       def self.can_#{name}?(user, attributes=nil)
                         can_create?('#{name}', user, attributes)
                       end
                      }

       end
      end

      def self.def_transition(name, who, start_state, end_states, on_transition, options)
        returning(Transition.new(self, name.to_s, who, start_state, end_states, on_transition, options)) do |t|

          class_eval %{
                       def #{name}(user, attributes=nil)
                         transition('#{name}', user, attributes)
                       end
                       def can_#{name}?(user, attributes=nil)
                         can_transition?('#{name}', user, attributes)
                       end
                      }

        end
      end

      def self.state_names
        states.keys
      end


      def self.can_create?(name, user, attributes=nil)
        creators[name.to_s].allowed?(user, attributes)
      end


      def self.create(name, user, attributes=nil)
        creators[name.to_s].run!(user, attributes)
      end


      def self.creator_names
        creators.keys
      end


      def self.transition_names
        transitions.*.name.uniq
      end


      def self.state_field
        options[:state_field]
      end


      # --- Instance Features --- #

      attr_reader :record

      attr_accessor :provided_key, :current_key


      def initialize(record)
        @record = record
      end


      def can_transition?(name, user, attributes=nil)
        available_transitions_for(user, name, attributes).any?
      end


      def transition(name, user, attributes=nil)
        transition = find_transition(name, user, attributes)
        transition.run!(record, user, attributes)
      end


      def find_transition(name, user, attributes=nil)
        available_transitions_for(user, name, attributes).first or
          raise LifecycleError, "No #{name} transition available to #{user} on this #{record.class.name}"
      end


      def state_name
        record.read_attribute self.class.state_field
      end


      def state
        self.class.states[state_name]
      end


      def available_transitions
        state.transitions_out
      end


      def available_transitions_for(user, name=nil, attributes=nil)
        matches = available_transitions
        matches = matches.select { |t| t.name == name.to_s } if name
        matches.select { |t| t.allowed?(record, user, attributes) }
      end


      def state=(state_name)
        state_name = state_name.to_s
        if self.state != state_name
          record.write_attribute self.class.state_field, state_name

          if state_name == "destroy"
            record.destroy
          else
            s = self.class.states[state_name]
            raise ArgumentError, "No such state '#{state_name}' for #{record.class.name}" unless s
            if record.save
              s.activate! record
            end
          end
        end
      end


      def key_timestamp_field
        record.class::Lifecycle.options[:key_timestamp_field]
      end


      def generate_key
        key_timestamp = Time.now
        record.write_attribute key_timestamp_field, key_timestamp
        current_key
      end


      def current_key
        require 'digest/sha1'
        Digest::SHA1.hexdigest("#{record.id}-#{state_name}-#{record.read_attribute key_timestamp_field}")
      end

      def valid_key?
        provided_key == current_key
      end


      def invariants_satisfied?
        self.class.invariants.all? { |i| record.instance_eval(&i) }
      end

      def preconditions_satisfied?
        self.class.preconditions.all? { |i| record.instance_eval(&i) }
      end

    end

  end
end
