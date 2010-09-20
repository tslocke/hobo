module Kernel

  def dbg(*args)
    puts "---DEBUG---"
    args.each do |a|
      if a.is_a?(String) && a =~ /\n/
        puts %("""\n) + a + %(\n"""\n)
      else
        p a
      end
    end
    puts "-----------"
    args.first
  end

end
