# We need to be able to eval an expression outside of the Hobo module
# so that, e.g. "User" doesn't eval to "Hobo::User"
# (Ruby determines this constant lookup scope lexically)
def __top_level_eval__(obj, expr)
  obj.instance_eval(expr)
end
  
module Hobo

  module Lifecycles

    module Actions

      def available_to_acting_user?(record)
        return true if available_to.nil? # available_to not specified (these steps are not published)
        acting_user_is?(available_to, record)
      end

      def publishable_by(user, who, record)                    
        case who
        when :all
          true

        when :key_holder
          record.lifecycle.valid_key?

        when :self
          record == user

        when Array
          # recursively apply the same test to every item in the array
          who.detect { |w| publishable_by(user, w, record) }

        else
          refl = record.class.reflections[who]
          if refl && refl.macro == :has_many
            record.send(who).include?(user)
          elsif refl && refl.macro == :belongs_to
            record.send("#{who}_is?", user)
          else
            value = run_hook(record, who)
            if value.is_a?(Class)
              user.is_a?(value)
            elsif value.respond_to?(:include?)
              value.include?(user)
            else
              value == user
            end
          end
        end
      end

      def acting_user_is?(who, record)
        publishable_by(record.acting_user, who, record)
      end

      def run_hook(record, hook, *args)
        case hook
        when Symbol
          record.send(hook, *args)
        when String
          __top_level_eval__(record, hook)
        when Proc
          if hook.arity == 1
            hook.call(record)
          else
            record.instance_eval(&hook)
          end
        end
      end


      def fire_event(record, event)
        if event
          if event.arity == 1
            event.call(record)
          else
            record.instance_eval(&event)
          end
        end
      end


      def guard_ok?(record)
        if options[:if]
          raise ArgumentError, "do not provide both :if and :unless to lifecycle steps" if options[:unless]
          run_hook(record, options[:if])
        elsif options[:unless]
          !run_hook(record, options[:unless])
        else
          true
        end
      end


      def prepare!(record, attributes)
        record.attributes = extract_attributes(attributes) if attributes
        record.lifecycle.generate_key if options[:new_key]
        apply_user_becomes!(record)
      end


      def can_run?(record)
        available_to_acting_user?(record) && guard_ok?(record) && record.lifecycle.invariants_satisfied?
      end
      
      
      def available_to
        options[:available_to]
      end
      
      
      def publishable?
        available_to
      end
      
      
      def apply_user_becomes!(record)
        if (assoc = options[:user_becomes])
          record.send("#{assoc}=", record.acting_user)
        end
      end
      
      def get_state(record, state)
        case state
        when Proc
          if state.arity == 1
            state.call(record)
          else
            record.instance_eval(&state)
          end
        when String
          eval(state, record.instance_eval { binding })
        else
          state
        end
      end
            
    end

  end
end
