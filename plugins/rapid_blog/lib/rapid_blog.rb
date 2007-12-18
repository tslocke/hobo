class RapidBlog < Hobo::Bundle
  
  def includes
    optional_bundle(RapidComments, :comments,
                    :CommentTarget => :BlogPost,
                    :Comment       => :BlogPostComment)

    optional_bundle(RapidTagging, :categories, 
                    :Tag       => :BlogPostCategory,
                    :TagTarget => :BlogPost,
                    :Tagging   => :BlogPostCategorisation)
  end
  
  def init
    customize :BlogPostCommentsController do
      def create
        hobo_create do
          redirect_to(object_url(@comment.target) + '#bottom') if valid?
        end
      end
    end

  end
  
  def defaults
    { :format => :text }
  end
  
end
