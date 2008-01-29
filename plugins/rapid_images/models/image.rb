bundle_model :Image do

  fields do |f|
    f.parent_id    :integer
    f.content_type :string
    f.filename     :string    
    f.thumbnail    :string 
    f.size         :integer
    f.width        :integer
    f.height       :integer
    f.label        :string
    f.timestamps
  end

  # attachment_fu
  has_attachment(:content_type => :image, 
                 :path_prefix  => "public/#{_image_path_prefix_}",
                 :max_size     => _max_file_size_,
                 :thumbnails   => _thumbnails_)

  validates_as_attachment
  
  def creatable_by?(user);       user.administrator?; end
  def updatable_by?(user, new);  false; end
  def deletable_by?(user);       user.administrator?; end
  def viewable_by?(user, field); true;  end
  
  def_scope :fullsize, :conditions => ['thumbnail IS NULL']
  
end
