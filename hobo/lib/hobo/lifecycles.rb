module Hobo

  module Lifecycles

    class LifecycleError < RuntimeError; end

    class LifecycleKeyError < LifecycleError; end

    ModelExtensions = classy_module do

      attr_writer :lifecycle

      def self.lifecycle(*args, &block)
        options = args.extract_options!
        options = options.reverse_merge(:state_field => :state,
                                        :key_timestamp_field => :key_timestamp)

        if defined? self::Lifecycle
          lifecycle = self::Lifecycle
        else
          # First call
          
          module_eval "class ::#{name}::Lifecycle < Hobo::Lifecycles::Lifecycle; end"
          lifecycle = self::Lifecycle
          lifecycle.init(self, options)
        end

        dsl = DeclarationDSL.new(lifecycle)
        dsl.instance_eval(&block)

        default = lifecycle.default_state ? { :default => lifecycle.default_state.name } : {}
        declare_field(options[:state_field], :string, default)

        declare_field(options[:key_timestamp_field], :datetime)

        never_show      options[:state_field], options[:key_timestamp_field]
        attr_protected  options[:state_field], options[:key_timestamp_field]
      end


      def self.has_lifecycle?
        defined?(self::Lifecycle)
      end


      def lifecycle
        @lifecycle ||= self.class::Lifecycle.new(self)
      end

    end


    class DeclarationDSL

      def initialize(lifecycle)
        @lifecycle = lifecycle
      end

      def state(*names, options={}, &block)
        states = names.map {|name| @lifecycle.def_state(name, block) }
        if options[:default]
          raise ArgumentError, "you must define one state if you give the :default option" unless states.length == 1
          @lifecycle.default_state = states.first
        end
      end

      def create(who, name, options={}, &block)
        @lifecycle.def_creator(name, who, block, options)
      end

      def transition(who, name, change, options={}, &block)
        @lifecycle.def_transition(name, who,
                                  Array(change.keys.first), change.values.first,
                                  block, options)
      end

      def invariant(&block)
        @lifecycle.invariants << block
      end

    end

  end
end
