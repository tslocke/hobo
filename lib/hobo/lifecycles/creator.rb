module Hobo
  module Lifecycles

    class Creator < Struct.new(:lifecycle, :name, :who, :on_create, :options)

      def initialize(*args)
        super
        self.name = name.to_sym
        lifecycle.creators[name] = self
      end

      include Actions


      def allowed?(user, attributes=nil)
        record = lifecycle.model.new
        record.with_acting_user(user) { prepare_and_check!(record, user, attributes) }
      end


      def candidate(user, attributes=nil)
        record = lifecycle.model.new
        record.with_acting_user(user) { prepare_and_check!(record, attributes) }
        record.exempt_from_edit_checks = true
        record
      end


      def extract_attributes(attributes)
        model = lifecycle.model
        params = options.fetch(:params, [])
        allowed = params.dup
        params.each do |p|
          if (refl = model.reflections[p]) && refl.macro == :belongs_to
            allowed << refl.primary_key_name.to_s
          end
        end
        attributes & allowed
      end


      def change_state(record)
        state = options[:become]
        record.lifecycle.become(state) if state
      end


      def run!(user, attributes)
        record = lifecycle.model.new
        record.lifecycle.active_step = self
        record.with_acting_user(user) do
          if prepare_and_check!(record, attributes)
            if change_state(record)
              fire_event(record, on_create)
            end
            record
          else
            raise Hobo::Model::PermissionDeniedError
          end
        end
      end


      def parameters
        options[:params] || []
      end

    end

  end
end
