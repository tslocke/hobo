class RapidBlog < Hobo::Bundle
  
  def includes
    optional_bundle(:RapidComments, :comments,
                    :CommentTarget => :BlogPost,
                    :Comment       => :_BlogPost_Comment)

    optional_bundle(:RapidTagging, :categories, 
                    :TagTarget => :BlogPost,
                    :Tag       => :_BlogPost_Category,
                    :Tagging   => :_BlogPost_Categorisation)
  end
  
  def defaults
    { :format => :html, :comments => true, :author => true, :Author => :User }
  end
  
end
