module Hobo
  
  module Lifecycles
    
    class State < Struct.new(:name, :on_enter, :transitions_in, :transitions_out)
      
      include Actions
      
      def initialize(*args)
        super
        self.transitions_in  = []
        self.transitions_out = []
      end
      
      
      def activate!(record)
        fire_event(record, on_enter)
      end
      
    end

  end
end
