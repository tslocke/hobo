class RapidBlog < Hobo::Bundle
  
  def includes
    optional_bundle(:RapidComments, :comments,
                    :CommentTarget => :BlogPost,
                    :Comment       => :BlogPostComment)

    optional_bundle(:RapidTagging, :categories, 
                    :Tag       => :BlogPostCategory,
                    :TagTarget => :BlogPost,
                    :Tagging   => :BlogPostCategorisation)
  end
  
  def defaults
    { :format => :html, :comments => true, :author => true, :Author => :User }
  end
  
end
