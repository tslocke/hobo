class Hobo::LazyString < String
  
  def initialize(&b)
    @proc = b
  end
  
  def to_s
    unless @string
      @string = @proc.call
      puts "!#{@string}"
    end
    @string
  end
  
  (String.instance_methods(false) - %w{initialize to_s send}).select{|m|!m.starts_with?("_")}.each do |m|
    if m =~ /[a-zA-Z0-9_]=$/
      class_eval "def #{m}(val); to_s.#{m}val; end"
    else
      class_eval "def #{m}(*args, &b); puts '#{m}'; to_s.#{m}(*args, &b); end"
    end
  end
  
end
