class RapidForum < Hobo::Bundle
  
  def includes
    RapidViewTracking.new(:Target => :FormumTopic)
  end
  
end
