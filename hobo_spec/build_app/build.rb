#!/usr/bin/env ruby 

# This script generates the POD demo from scratch. We can then run
# some Selenium tests on it to ensure everything is in order

require 'fileutils'

APP_NAME = 'new_hobo_app'

def sh(*s)
  ok = system(s.join(' '))
  exit(1) unless ok
end

def gen(s)
  sh "ruby script/generate #{s}"
end

def edit(filename)
  src = File.read(filename)
  src = yield src
  File.open(filename, 'w') {|f| f.write(src) }
end

FileUtils.rm_rf(APP_NAME)

sh '../../hobo/bin/hobo --hobo-src ../../hobo', APP_NAME

puts "\nCreating POD app"

Dir.chdir(APP_NAME) do
  gen "hobo_model advert title:string body:text"
  gen "hobo_model_controller advert"
  
  gen "hobo_model category name:string"
  gen "hobo_model_controller category"
  
  edit "app/models/user.rb" do |user|
    user.sub(/  # --- Hobo Permissions --- #.*end\s*end/m, <<-END)
  has_many :adverts, :dependent => :destroy

  # --- Hobo Permissions --- #

  def super_user?
    login == 'admin'
  end
  
  def creatable_by?(user)
    user.guest?
  end

  def updatable_by?(user, new)
    user == self || user.administrator?
  end

  def deletable_by?(user)
    user.administrator?
  end

  def viewable_by?(user, field)
    true
  end

end
END
  end
  
  edit "app/models/advert.rb" do |advert|
    advert.sub(/  # --- Hobo Permissions --- #.*end\s*end/m, <<-END)
  belongs_to :user, :creator => true
  belongs_to :category

  # --- Hobo Permissions --- #

  def creatable_by?(user)
    user == self.user || user.administrator?
  end

  def updatable_by?(user, new)
    user == self.user && same_fields?(new, :user) || user.administrator?
  end

  def deletable_by?(user)
    user == self.user || user.administrator?
  end

  def viewable_by?(user, field)
    true
  end

end
END
  end
  
  edit "app/models/category.rb" do |category|
    category.sub(/  # --- Hobo Permissions --- #.*end\s*end/m, <<-END)
  has_many :adverts, :dependent => :destroy

  # --- Hobo Permissions --- #

  def creatable_by?(user)
    user.administrator?
  end

  def updatable_by?(user, new)
    user.administrator?
  end

  def deletable_by?(user)
    user.administrator?
  end

  def viewable_by?(user, field)
    true
  end

end
END
  end

  edit "app/controllers/categories_controller.rb" do |controller|
    controller.sub("auto_actions :all", "auto_actions :all, :except => :new")
  end
  
  gen "hobo_migration"

end


