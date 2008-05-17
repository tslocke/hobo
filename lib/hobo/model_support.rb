module Hobo

  module ModelSupport

    # This module provides methods common to both Hobo::Model and Hobo::CompositeModel

    def self.included(base)
      base.extend(ClassMethods) if base.is_a? Class
    end

    module ClassMethods

      def delegate_and_compose(*methods)
        options = methods.pop
        unless options.is_a?(Hash) && to = options[:to]
          raise ArgumentError, ("Delegation needs a target. Supply an options hash " +
                                "with a :to key as the last argument (e.g. delegate :hello, :to => :greeter).")
        end
        use = options[:use]

        methods.each do |method|
          module_eval(<<-EOS, "(__COMPOSED_DELEGATION__)", 1)
            def #{method}
              @__#{method}_result__ ||= begin
                                          obj = #{to}.__send__(#{method.inspect})
                                          return nil if obj.nil?

                                          if obj.nil?
                                            nil
                                          elsif obj.is_a?(Array)
                                            obj.map {|o| self.compose_with(o, #{use.inspect})}
                                          else
                                            self.compose_with(obj, #{use.inspect})
                                          end
                                        end
            end
          EOS
        end
      end

    end

  end
end
