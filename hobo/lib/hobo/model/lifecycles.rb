module Hobo
  module Model
    module Lifecycles

      class LifecycleError < RuntimeError; end

      class LifecycleKeyError < LifecycleError; end

      ModelExtensions = classy_module do

        attr_writer :lifecycle

        def self.has_lifecycle?
          defined?(self::Lifecycle)
        end

        def self.lifecycle(*args, &block)
          options = args.extract_options!
          options = options.reverse_merge(:state_field => :state,
                                          :key_timestamp_field => :key_timestamp,
                                          :key_timeout => 999.years)

          # use const_defined so that subclasses can define lifecycles
          # TODO: figure out how to merge with parent, if desired
          if self.const_defined?(:Lifecycle)
            lifecycle = self::Lifecycle
            state_field_class = self::LifecycleStateField
          else
            # First call

            module_eval "class ::#{name}::Lifecycle < Hobo::Model::Lifecycles::Lifecycle; end"
            lifecycle = self::Lifecycle
            lifecycle.init(self, options)

            module_eval "class ::#{name}::LifecycleStateField < HoboFields::Types::LifecycleState; end"
            state_field_class = self::LifecycleStateField
            state_field_class.model_name = name
          end

          dsl = Hobo::Model::Lifecycles::DeclarationDSL.new(lifecycle)
          dsl.instance_eval(&block)

          default = lifecycle.default_state ? { :default => lifecycle.default_state.name.to_s } : {}
          declare_field(options[:state_field], state_field_class, default)
          unless options[:index] == false
            index_options = { :name => options[:index] } unless options[:index] == true
            index(options[:state_field], index_options || {})
          end
          attr_protected  options[:state_field]

          unless options[:key_timestamp_field] == false
            declare_field(options[:key_timestamp_field], :datetime)
            never_show      options[:key_timestamp_field]
            attr_protected  options[:key_timestamp_field]
          end

        end

        # eval avoids the ruby 1.9.2 "super from singleton method ..." error
        eval %(
          def valid?(context=nil)
            if context.nil? && self.class.has_lifecycle? && (step = lifecycle.active_step)
              context = step.name
            end
            super(context)
          end
        )

        def lifecycle
          @lifecycle ||=  if self.class.const_defined?(:Lifecycle)
                            self.class::Lifecycle.new(self)
                          else
                            # search through superclasses
                            current = self.class.superclass
                            until (current.const_defined?(:Lifecycle) || current.nil? || !current.respond_to?(:lifecycle)) do
                              current = current.superclass
                            end
                            current::Lifecycle.new(self) if current.const_defined?(:Lifecycle)
                          end
        end

      end


      class DeclarationDSL

        def initialize(lifecycle)
          @lifecycle = lifecycle
        end

        def state(*args, &block)
          options = args.extract_options!
          names = args
          states = names.map {|name| @lifecycle.def_state(name, block) }
          if options[:default]
            raise ArgumentError, "you must define one state if you give the :default option" unless states.length == 1
            @lifecycle.default_state = states.first
          end
        end

        def create(name, options={}, &block)
          @lifecycle.def_creator(name, block, options)
        end

        def transition(name, change, options={}, &block)
          @lifecycle.def_transition(name,
                                    Array(change.keys.first), change.values.first,
                                    block, options)
        end

        def invariant(&block)
          @lifecycle.invariants << block
        end

      end

    end
  end
end
