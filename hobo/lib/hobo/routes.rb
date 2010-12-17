module Hobo
  module Routes
    extend self

    def reset_linkables
      @linkable_keys = Set.new
    end

    def linkable_key(klass, action, options)
      subsite = options[:subsite] || options['subsite']
      method  = options[:method]  || options['method'] || :get
      [ subsite, klass.name, action, method ].join('/')
    end

    def linkable!(klass, action, options={})
      @linkable_keys << linkable_key(klass, action, options)
    end

    def linkable?(klass, action, options={})
      @linkable_keys.member? linkable_key(klass, action, options)
    end

    def models_with(wanted_action)
      @linkable_keys.map do |k|
        subsite, class_name, action, method = k.split('/')
        (action == wanted_action.to_s) ? class_name.constantize : nil
      end.compact
    end

  end
end
