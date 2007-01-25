class Hobo::FieldUndefiner
  
  def initialize(self_, field)
    @self_ = self_
    @field = field.to_s
    refl = self.class.reflections[field.to_sym]
    @undef = if refl and refl.macro == :belongs_to
               Hobo::Undefined.new(refl.klass)
             else
               Hobo::Undefined.new
             end
  end

  def method_missing(name, *args, &block)
    if name.to_s == @field
      @undef
    else
      @self_.send(name, *args, &block)
    end
  end
  
end

Object.instance_methods.each do |m|
  Hobo::FieldUndefiner.send(:undef_method, m) unless m.in?(%w{send instance_eval}) || m.starts_with?('_')
end

