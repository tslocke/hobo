# Define BlankSlate in case ActiveSupport aint present
unless defined? BlankSlate
  class BlankSlate
    instance_methods.reject { |m| m =~ /^__/ }.each { |m| undef_method m }
    def initialize(me)
      @me = me
    end
  end
end

