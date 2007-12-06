module ::Hobo::Plugins
  class HoboImages < HoboPlugin
    PLUGIN_DEFAULTS = {
      :image       => :image,
#      :on          => false,
      :thumbnails  => {:thumb => '100x100'}
    }
    PLUGIN_SYMBOLS = [:image]

    def default
      images
    end

    def images
      images_model
      images_controller
    end

    def images_model
      hobo_model :Image do
        fields do
          parent_id    :integer
          content_type :string
          filename     :string    
          thumbnail    :string 
          size         :integer
          width        :integer
          height       :integer
          label        :string
          timestamps
        end

        has_attachment :content_type => :image, 
                         :path_prefix => "public/images/#{sym[:images]}",
                         :max_size => 2.megabytes,
                         :thumbnails => sym[:thumbnails]
#                         :resize_to => '320x200>',

        validates_as_attachment
        
        def creatable_by?(user);       user.super_user?; end
        def updatable_by?(user, new);  false; end
        def editable_by?(user, field); user.super_user?; end
        def deletable_by?(user);       user.super_user?; end
        def viewable_by?(user, field); true;  end
        
        def self.fullsize_images
          self.find(:all,:conditions => ['thumbnail IS NULL'])
        end
#        def_scope :fullsize_images, :conditions => ['thumbnail IS NULL']
      end
    end

    def images_controller
      resource_controller :ImagesController do
        include_taglib "images_controller", :from_plugin => "hobo_images"
        
        def update
          hobo_update do
            flash[:notice] = "The #{sym[:image].to_s.humanize} was successfully updated."
            redirect_to(:action => :index)
          end
        end

        def index
          hobo_index :collection => proc {model.fullsize_images}
        end

        def select_image
          hobo_index
        end
        
      end
    end
  end
end
