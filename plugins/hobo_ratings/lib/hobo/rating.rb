module Hobo
  
  class Rating < DelegateClass(Fixnum)

    class << self 
      
      def [](out_of)
        Class.new(Rating) do
          @out_of = out_of
        end
      end
      
      attr_accessor :out_of
      
      def inspect
        name.blank? ? "#<Rating #{out_of}>" : name
      end
      alias_method :to_s, :inspect
      
    end
    
    COLUMN_TYPE = :integer
    
    def initialize(value)
      super(value)
    end

    def out_of
      self.class.out_of
    end

    def validate
      "must be from 0 to #{out_of}" unless self.in?(0..out_of)
    end
        
  end

end
