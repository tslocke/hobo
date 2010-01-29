  module Dryml

    class NoParameterError < RuntimeError; end

    class TagParameters < Hash

      def initialize(parameters, exclude_names=nil)
        if exclude_names.blank?
          update(parameters)
        else
          parameters.each_pair { |k, v| self[k] = v unless k.in?(exclude_names) }
        end
      end

      def method_missing(name, default_content="")
        if name.to_s =~ /\?$/
          has_key?(name.to_s[0..-2].to_sym)
        else
          self[name]._?.call(default_content) || ""
        end
      end

      undef_method :default

      # Question: does this do anything? -Tom 
      def [](param_name)
        fetch(param_name, nil)
      end

    end

  end
