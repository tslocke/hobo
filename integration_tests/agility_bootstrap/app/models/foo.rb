# this is a model that contains random crap for testing
class Foo < ActiveRecord::Base
  hobo_model

  fields do
    timestamps
    bool1 :boolean
    bool2 :boolean
    i :integer
    f :float
    dec :decimal, :precision => 10, :scale => 4
    s :string
    tt :text, :limit => 16777215
    d :date
    dt :datetime
    hh :html
    tl :textile
    md :markdown
    es enum_string("a", "b", "c"), :default => "a"
    v :boolean, :default => true
  end

  lifecycle do
    state :state1, :default => true
    state :state2

    transition :trans1, { :state1 => :state2 }, :params => [:v], :available_to => :all do |r|
      raise "bug450" if r.v==false || !r.errors.blank?
    end     
    transition :trans2, { :state2 => :state1 }, :params => [:v], :available_to => :all do |r|
      raise "bug450" if r.v==false || !r.errors.blank?
    end     
  end

  has_many :bars,  :dependent => :destroy, :accessible => true
  has_many :foobazs, :dependent => :destroy
  has_many :bazs,  :dependent => :destroy, :through => :foobazs, :accessible => true

  validate :v_must_be_true

  def v_must_be_true
    errors[:base] << "v must be true" unless v==true
  end

  # --- Hobo Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(attribute)
    acting_user.administrator?
  end  
end
