module Hobo
  
  module Lifecycles
    
    module Actions
      
      def set_or_check_who!(record, user)
        if who == :anyone
          true
        elsif who.is_a?(Array)
          who.detect {|attribute| record.send(attribute) == user }
        elsif (current = record.send(who)) # it's already set, check it's the same user
          user == current
        elsif user.is_a?(record.class.attr_type(who))
          record.send("#{who}=", user)
          true
        else
          false
        end
      end
      

      def run_hook(record, hook, *args)
        if hook.is_a?(Symbol)
          record.send(hook, *args)
        elsif hook.is_a?(Proc)
          hook.call(record, *args)
        end
      end

      
      def fire_event(record, event)
        record.instance_eval(&event) if event
      end
      
      
      def check_guard(record, user)
        !options[:if] || run_hook(record, options[:if], user)
      end
      
      def check_invariants(record)
        record.lifecycle.invariants_satisfied?
      end
      
      
      def prepare(record, user, attributes=nil)
        if attributes
          attributes = extract_attributes(attributes)
          record.attributes = attributes
        end
        set_or_check_who!(record, user) && record
      end
      
      
      def prepare_and_check!(record, user, attributes=nil)
        prepare(record, user, attributes) if check_guard(record, user) && check_invariants(record)
      end
      
    end

  end
end
