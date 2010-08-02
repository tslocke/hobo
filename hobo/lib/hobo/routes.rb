module Hobo
  class Routes
    class << self

      def reset_linkables
        @linkable = Set.new
      end

      def linkable_key(klass, action, options)
        subsite = options[:subsite] || options['subsite']
        method  = options[:method]  || options['method']
        opts = options.map { |k, v| "#{k}=#{v}" unless v.blank? }.compact.join(',')
        "#{subsite}/#{klass.name}/#{action}/#{method}"
      end

      def linkable!(klass, action, options={})
        options[:method] ||= :get
        @linkable << linkable_key(klass, action, options)
      end

      def linkable?(klass, action, options={})
        options[:method] ||= :get
        @linkable.member? linkable_key(klass, action, options)
      end

    end
  end
end
