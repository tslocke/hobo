module Hobo
  
  module Lifecycles
    
    ModelExtensions = classy_module do
      
      attr_writer :lifecycle

      def self.lifecycle(*args, &block)
        options = args.extract_options!
        options = options.reverse_merge(:state_field => :state,
                                        :last_transition_at_field => :last_transition_at)
        
        if defined? self::Lifecycle
          lifecycle = self::Lifecycle
        else
          module_eval "class ::#{name}::Lifecycle < Hobo::Lifecycles::Lifecycle; end"
          lifecycle = self::Lifecycle
          lifecycle.init(self, options)
        end
        
        dsl = DeclarationDSL.new(lifecycle)
        dsl.instance_eval(&block)
          
        declare_field(options[:state_field], :string, :default => lifecycle.initial_state.name)
        declare_field(options[:last_transition_at_field], :datetime)
      end
    
      def lifecycle
        @lifecycle ||= self.class::Lifecycle.new(self)
      end
      
      def become(state)
        self.lifecycle.state = state
      end
      
    end
    
    
    class DeclarationDSL
      
      def initialize(lifecycle)
        @lifecycle = lifecycle
      end
      
      def state(*names, &block)
        names.map {|name| @lifecycle.def_state(name, block) }
      end
      
      def initial_state(name, &block)
        s = @lifecycle.def_state(name, block)
        @lifecycle.initial_state = s
      end
      
      def create(who, name, options={}, &block)
        @lifecycle.def_creator(name, who, block, options)
      end
      
      def transition(who, name, change, options={}, &block)
        @lifecycle.def_transition(name, who,
                                  Array(change.keys.first), change.values.first,
                                  block, options)
      end
      
    end
    
  end
end
