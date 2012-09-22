class Guest < Hobo::Model::Guest

  def administrator?
    false
  end

end
