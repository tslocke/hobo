# Define BlankSlate in case ActiveSupport aint present
unless defined? BlankSlate
  class BlankSlate
    (instance_methods+protected_instance_methods+private_instance_methods).reject { |m| m =~ /^__/ || m.to_s == 'object_id' }.each { |m| undef_method m }
    def initialize(me)
      @me = me
    end
  end
end


