class Baz < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    timestamps
  end

  has_many :foobazs
  has_many :foos, :through => :foobazs
  has_many :bats, :accessible => true

  validate :must_be_j

  def must_be_j
    errors.add_to_base("name must start with j") unless name =~ /^j/
  end

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
