module Hobo

  class ProcBinding

    def self.eval(proc, self_, locals)
      ProcBinding.new(self_, locals).instance_eval(&proc)
    end

    def initialize(self_, locals)
      @self_ = self_
      @locals = locals
      locals.symbolize_keys!
    end

    def method_missing(name, *args, &block)
      if @locals.has_key?(name)
        @locals[name]
      else
        @self_.send(name, *args, &block)
      end
    end

  end

  (Object.instance_methods + 
   Object.private_instance_methods +
   Object.protected_instance_methods).each do |m|
    ProcBinding.send(:undef_method, m) unless
      %w{initialize method_missing send instance_eval}.include?(m) || m.starts_with?('_')
  end

end
