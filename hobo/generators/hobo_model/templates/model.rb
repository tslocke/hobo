class <%= class_name %> < ActiveRecord::Base

  hobo_model

  fields do
<% for attribute in attributes -%>
    <%= attribute.name %> :<%= attribute.type %>
<% end -%>
    timestamps
  end


  # --- Hobo Permissions --- #

  def creatable_by?(user)
    false
  end

  def updatable_by?(user, new)
    false
  end

  def deletable_by?(user)
    false
  end

  def viewable_by?(user, field)
    true
  end

end
