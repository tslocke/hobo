module ::Hobo::Plugins
  
  class HoboBlog < HoboPlugin
  
    PLUGIN_DEFAULTS = {
      :post       => :post,
      :comment    => :comment,
      :categories => false,
      :category   => :category,
      :categorisation => :categorisation,
      :format  => :text
    }
    PLUGIN_SYMBOLS = [:post, :comment, :category, :categorisation]
    
    def comments_controller
      @opt[:CommentsController].to_s.constantize
    end

    def default
      posts
      if @opt[:comment]
        HoboComments.new(
          :comment => @opt[:comment],
          :target  => @opt[:post]
        )
        
        comments_controller.class_eval do
          def create
            hobo_create do
              redirect_to(object_url(@comment.target) + '#bottom') if valid?
            end
          end
        end
      end
      
      if @opt[:categories]
        HoboTagging.new(:target => @opt[:post],
                        :tag  => @opt[:category],
                        :tagging => @opt[:categorisation])
      end
    end

    def posts
      posts_model
      posts_controller
    end

    def posts_model
      hobo_model :Post do
        fields do
          title  :string
          body   model.sym[:format]
          timestamps
        end
        
        if has_feature(:comments)
          has_many sym[:comments], :order => 'created_at ASC'
        end
        if has_feature(:categories)
          has_many sym[:categorisations]
          has_many sym[:categories], :through => sym[:categorisations]
        end

        def self.recent(limit=3, options={})
          options = options.reverse_merge(:limit => limit, :order => 'created_at DESC')
          find(:all, options)
        end

        def creatable_by?(user);       !user.guest?; end
        def updatable_by?(user, new);  !user.guest?; end
        def deletable_by?(user);       !user.guest?; end
        def viewable_by?(user, field); true;  end
      end
    end

    def posts_controller
      resource_controller :PostsController do
        include_taglib "posts_controller", :from_plugin => "hobo_blog"
        if has_feature(:comments)
          include_taglib "hobo_comments", :from_plugin => "hobo_comments"
        end
      end
    end
  end
end
