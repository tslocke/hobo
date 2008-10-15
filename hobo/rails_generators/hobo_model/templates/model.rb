class <%= class_name %> < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
<% for attribute in attributes -%>
    <%= "%-#{max_attribute_length}s" % attribute.name %> :<%= attribute.type %>
<% end -%>
    timestamps
  end


  # --- Hobo Permissions --- #

  def creatable_by?(creator)
    user.administrator?
  end

  def updatable_by?(updater, updated)
    user.administrator?
  end

  def deletable_by?(delter)
    user.administrator?
  end

  def viewable_by?(viewer, field)
    true
  end

end
