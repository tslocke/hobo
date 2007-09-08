class Guest < Hobo::Guest

  def can_update?(obj, field)
    false
  end

  def can_delete?(obj)
    false
  end

  def can_create?(obj)
    false
  end

  def can_view?(obj, field)
    true
  end

end
