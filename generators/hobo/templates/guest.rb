class Guest

  def display_name
    "Guest"
  end

  def guest?
    true
  end

  def super_user?
    false
  end

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
