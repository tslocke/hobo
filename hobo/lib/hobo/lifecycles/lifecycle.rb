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
        @invariants    = []
      end

      class << self
        attr_accessor :model, :options, :states, :default_state,
                      :creators, :transitions, :invariants
      end

      def self.def_state(name, on_enter)
        name = name.to_sym
        returning(Lifecycles::State.new(name, on_enter)) do |s|
          states[name] = s
          class_eval "def #{name}_state?; state_name == :#{name} end"
        end
      end


      def self.def_creator(name, on_create, options)
        name = name.to_sym
        returning(Creator.new(self, name, on_create, options)) do |creator|

          class_eval %{
                       def self.#{name}(user, attributes=nil)
                         create(:#{name}, user, attributes)
                       end
                       def self.can_#{name}?(user, attributes=nil)
                         can_create?(:#{name}, user)
                       end
                      }

       end
      end

      def self.def_transition(name, start_state, end_states, on_transition, options)
        returning(Transition.new(self, name.to_s, start_state, end_states, on_transition, options)) do |t|

          class_eval %{
                       def #{name}!(user, attributes=nil)
                         transition(:#{name}, user, attributes)
                       end
                       def can_#{name}?(user, attributes=nil)
                         can_transition?(:#{name}, user)
                       end
                       def valid_for_#{name}?
                         valid_for_transition?(:#{name})
                       end
                      }

        end
      end

      def self.state_names
        states.keys
      end
      
      def self.publishable_creators
        creators.values.where.publishable?
      end
      
      def self.publishable_transitions
        transitions.where.publishable?
      end
      
      def self.step_names 
        (creators.keys | transitions.*.name).uniq
      end
      
      
      def self.creator(name)
        creators[name.to_sym] or raise ArgumentError, "No such creator in lifecycle: #{name}"
      end


      def self.can_create?(name, user)
        creators[name.to_sym].allowed?(user)
      end


      def self.create(name, user, attributes=nil)
        creator = creators[name.to_sym] or raise LifecycleError, "No creator #{name} available"
        creator.run!(user, attributes)
      end


      def self.state_field
        options[:state_field]
      end

      def self.key_timeout
        options[:key_timeout]
      end


      # --- Instance Features --- #

      attr_reader :record

      attr_accessor :provided_key, :active_step


      def initialize(record)
        @record = record
      end


      def can_transition?(name, user)
        available_transitions_for(user, name).any?
      end


      def transition(name, user, attributes)
        transition = find_transition(name, user) or raise LifecycleError, "No transition #{name} available"
        transition.run!(record, user, attributes)
      end


      def find_transition(name, user)
        available_transitions_for(user, name).first
      end
      
      
      def valid_for_transition?(name)
        record.valid?
        callback = :"validate_on_#{name}"
        record.run_callbacks callback
        record.send callback
        record.errors.empty?
      end


      def state_name
        name = record.read_attribute(self.class.state_field)
        name.to_sym if name
      end


      def state
        self.class.states[state_name]
      end


      def available_transitions
        state ? state.transitions_out : []
      end

      # see also publishable_transitions_for
      def available_transitions_for(user, name=nil)
        name = name.to_sym if name
        matches = available_transitions
        matches = matches.select { |t| t.name == name } if name
        record.with_acting_user(user) do
          matches.select { |t| t.can_run?(record) }
        end
      end

      def publishable_transitions_for(user)
        available_transitions_for(user).select {|t| t.publishable_by(user, t.available_to, record)}
      end
        

      def become(state_name, validate=true)
        state_name = state_name.to_sym
        record.write_attribute self.class.state_field, state_name.to_s

        if state_name == :destroy
          record.destroy
          true
        else
          s = self.class.states[state_name]
          raise ArgumentError, "No such state '#{state_name}' for #{record.class.name}" unless s

          if record.save(validate)
            s.activate! record
            self.active_step = nil # That's the end of this step
            true
          else
            false
          end
        end
      end
            
      
      def key_timestamp_field
        record.class::Lifecycle.options[:key_timestamp_field]
      end

      def key_timeout
        record.class::Lifecycle.options[:key_timeout]
      end

      def generate_key
        if Time.zone.nil?
          raise RuntimeError, "Cannot generate lifecycle key timestamp if the time-zone is not configured. Please add, e.g. config.time_zone = 'UTC' to environment.rb"
        end
        key_timestamp = Time.now.utc
        record.write_attribute key_timestamp_field, key_timestamp
        key
      end


      def key
        require 'digest/sha1'
        timestamp = record.read_attribute(key_timestamp_field)
        if timestamp
          timestamp = timestamp.getutc
          Digest::SHA1.hexdigest("#{record.id}-#{state_name}-#{timestamp}")
        end
      end

      def key_expired?
        timestamp = record.read_attribute(key_timestamp_field)
        timestamp.nil? || (timestamp.getutc + key_timeout < Time.now.utc)
      end

      def valid_key?
        provided_key && provided_key == key && !key_expired?
      end

      def invariants_satisfied?
        self.class.invariants.all? { |i| record.instance_eval(&i) }
      end


      def active_step_is?(name)
        active_step && active_step.name == name.to_sym
      end
      
      def method_missing(name, *args)
        if name.to_s =~ /^(.*)_in_progress\?$/
          active_step_is?($1)
        else
          super
        end
      end

    end

  end
end
