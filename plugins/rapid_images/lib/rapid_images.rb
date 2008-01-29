class RapidImages < Hobo::Bundle
    
  def defaults
    { :max_file_size     => 2.megabytes,
      :image_path_prefix => "images/#{name}" }
  end
  
end
