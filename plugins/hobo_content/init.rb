module ::Hobo::Plugins
  class HoboContent < HoboPlugin
    PLUGIN_DEFAULTS = {
      :content_block       => :content_block,
      :text_type           => :html
    }
    PLUGIN_SYMBOLS = [:content_block]

    def default
      content_blocks
    end

    def content_blocks
      content_blocks_model
      content_blocks_controller
    end

    def content_blocks_model
      hobo_model :ContentBlock do
        fields do
          name  :string
          title :string
          body  model.sym[:text_type]
          timestamps
        end
        
        def self.[](name)
          find_or_create_by_name(name)
        end

        def creatable_by?(user);       user.super_user?; end
        def updatable_by?(user, new);  user.super_user?; end
        def deletable_by?(user);       user.super_user?; end
        def viewable_by?(user, field); true;  end
      end
    end

    def content_blocks_controller
      resource_controller :ContentBlocksController do
        
        def show
#          logger.info("class="+self.class.name)
          klass = sym[:ContentBlock].to_s.constantize
          @content_block = (params[:name] ? klass.find_by_name(params[:name]) : klass.find(params[:id]))
          hobo_show :this => @content_block
        end
      end
    end
  end
end
