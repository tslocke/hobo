# --- Fix Chronic - can't parse '12th Jan' --- #
begin
  require 'chronic'

  module Chronic

    class << self
      def parse_with_hobo_fix(s)
        if s =~ /^\s*\d+\s*(st|nd|rd|th)\s+[a-zA-Z]+(\s+\d+)?\s*$/ 
          s = s.sub(/\s*\d+(st|nd|rd|th)/) {|s| s[0..-3]}
        end
        
        # Chronic can't parse '1/1/2008 1:00' or '1/1/2008 1:00 PM',
        # so convert them to '1/1/2008 @ 1:00' and '1/1/2008 @ 1:00 PM'
        s = s.sub(/^\s*(\d+\/\d+\/\d+)\s+(\d+:\d+.*)/, '\1 @ \2')
        parse_without_hobo_fix(s)
      end
      alias_method_chain :parse, :hobo_fix
    end
  end
rescue LoadError; end
