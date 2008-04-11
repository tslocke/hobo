module Hobo
  module Lifecycles
    
    class Creator < Struct.new(:name, :who, :on_create, :options)
      
      include Actions
      
      def allowed?(model, user, attributes=nil)
        prepare_and_check!(model.new, user, attributes) && true
      end
      
      
      def extract_attributes(attributes)
        params = options.fetch(:params, [])
        attributes & params
      end

      
      def change_state(record)
        state = options[:become]
        record.become(state) if state
      end
      
      
      def run!(model, user, attributes)
        record = model.new
        if prepare_and_check!(record, user, attributes)
          fire_event(record, on_create)
          change_state(record)
          record
        end
      end
      
    end
    
  end
end
