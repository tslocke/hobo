# Define BlankSlate in case ActiveSupport aint present
unless defined? BlankSlate
  unless defined? BlankSlate
    class BlankSlate
      instance_methods.reject { |m| m =~ /^__/ || m =~ /^(object_id|instance_eval)$/  }.each { |m| undef_method m }
      def initialize(me)
        @me = me
      end
    end
  end
end


