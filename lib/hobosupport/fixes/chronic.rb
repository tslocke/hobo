# --- Fix Chronic - can't parse '12th Jan' --- #
begin
  require 'chronic'
  
  module Chronic
    
    class << self
      def parse_with_hobo_fix(s)
        parse_without_hobo_fix(if s =~ /^\s*\d+\s*(st|nd|rd|th)\s+[a-zA-Z]+(\s+\d+)?\s*$/
                                 s.sub(/\s*\d+(st|nd|rd|th)/) {|s| s[0..-3]}
                               else
                                 s
                               end)
      end
      alias_method_chain :parse, :hobo_fix
    end
  end
rescue LoadError; end
