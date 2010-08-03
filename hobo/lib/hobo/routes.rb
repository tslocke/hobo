module Hobo
  class Routes
    class << self

      def reset_linkables
        @linkable = Set.new
      end

      def linkable_key(klass, action, options)
        subsite = options[:subsite] || options['subsite']
        method  = options[:method]  || options['method'] || :get
        [ subsite, klass.name, action, method ]
      end

      def linkable!(klass, action, options={})
        @linkable << linkable_key(klass, action, options)
      end

      def linkable?(klass, action, options={})
        @linkable.member? linkable_key(klass, action, options)
      end

      def models_with(action)
        @linkable.map do |k|
          (k[2] == action) ? k[1].constantize : nil
        end.compact
      end

    end
  end
end
