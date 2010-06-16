class <%= class_name %> < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
<% for attribute in field_attributes -%>
    <%= "%-#{max_attribute_length}s" % attribute.name %> :<%= attribute.type %>
<% end -%>
    timestamps
  end

<% for bt in bts -%>
  belongs_to :<%= bt %>
<% end -%>
<%= "\n" unless bts.empty? -%>
<% for hm in hms -%>
  has_many :<%= hm %>, :dependent => :destroy
<% end -%>
<%= "\n" unless hms.empty? -%>
  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
