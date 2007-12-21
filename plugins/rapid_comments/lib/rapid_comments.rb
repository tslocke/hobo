class RapidComments < Hobo::Bundle
    
  def defaults
    { :format => :text, :website => false, :author_model => false, :Author => :User }
  end
    
end
