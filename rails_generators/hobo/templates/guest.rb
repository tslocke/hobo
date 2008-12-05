class Guest < Hobo::Guest

  def administrator?
    false
  end

end
