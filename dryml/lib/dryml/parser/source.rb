module Dryml::Parser

  # A REXML source that keeps track of where in the buffer it is
  class Source < REXML::Source

    def initialize(src)
      super(src)
      @buffer_offset = 0
    end

    attr_reader :last_match_offset

    def remember_match(m)
      if m
        @last_match = m
        @last_match_offset = @buffer_offset + m.begin(0)
        @orig[@last_match_offset..@last_match_offset+m[0].length] == @buffer[m.begin(0)..m.end(0)]
      end
      m
    end

    def advance_buffer(md)
      @buffer = md.post_match
      @buffer_offset += md.end(0)
    end

    def scan(pattern, cons=false)
      raise '!'
      return nil if @buffer.nil?
      rv = @buffer.scan(pattern)
      if cons and rv.size > 0
        advance_buffer(Regexp.last_match)
      end
      rv
    end

    def consume(pattern)
      md = remember_match(pattern.match(@buffer))
      if md
        advance_buffer(md)
        @buffer
      end
    end

    def match(pattern, cons=false)
      md = remember_match(pattern.match(@buffer))
      advance_buffer(md) if cons and md
      return md
    end

    def current_line
      pos = last_match_offset || 0
      [0, 0, @orig[0..pos].count("\n") + 1]
    end

  end

end
