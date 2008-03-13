class RapidForum < Hobo::Bundle
  
  def includes
    RapidViewTracking.new(:Target => :FormumTopic, :Viewing => :_ForumTopic_Viewing)
  end
  
end
