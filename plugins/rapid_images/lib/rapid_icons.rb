class RapidIcons < Hobo::Bundle

  # We don't need any models/contollers beyond those provided by RapidImages
  models      :none
  controllers :none
  
  def includes
    include_bundle(:RapidImages, "images", 
                   { :image_path_prefix => "#{_Target_.underscore}_icons", :Image => :_Target_Icon}.update(options))
  end
  
  def init
    customize :_Target_Icon do
      belongs_to _target_, :polymorphic => :optional, :class_name => _Target_, :alias => :target
      
      def creatable_by?(creator)
        creator == target ||             # create an icon for yourself
          creator == target.get_creator  # create an icon for something you created
      end
      
      after_create :destroy_overwritten_icons
      
      private
      
      # The image file associated with an Icon is not generally
      # changed. Instead to change the icon of a particular object, a
      # new Icon record is created. If there is an existing Icon for
      # that object it needs to be destroyed.
      def destroy_overwritten_icons
        self.class.target_is(target).destroy_all(["id <> ?", id]) if target
      end
      
    end
    
    customize :_Target_IconsController do 

      def create
        hobo_create do 
          flash[:notice] = "The icon uploaded successfully"
        end
      end
      
    end
  end
  
  module ModelClassMethods
    
    def has_icon(options={})
      default_class_name = options[:as] ? "Icon" : "#{name}Icon"

      has_one(:icon, 
              :class_name  => options.fetch(:class_name, default_class_name),
              :as          => options[:as],
              :foreign_key => options[:foreign_key])
              
      define_method :default_icon do
        self.class.reflections[:icon].klass.new(:filename => 'default.jpg')
      end
            
    end
    
  end
  Hobo::Model::ClassMethods.send :include, ModelClassMethods
  
end
