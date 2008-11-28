HOBO_HOME = "#{File.dirname(__FILE__)}/../../../.."
$:.unshift "#{HOBO_HOME}/hobosupport/lib"
$:.unshift "#{HOBO_HOME}/hobofields/lib"
$:.unshift "#{HOBO_HOME}/hobo/lib"

require 'rubygems'
require 'sqlite3'
require 'activerecord'
require 'hobosupport'
require 'hobofields'
require 'hobo'

Hobo::Model.enable

module Models
  
  extend self
  
  HOME = File.dirname(__FILE__)
  
  def model(name, &b)
    klass = Object.const_set(name, Class.new(ActiveRecord::Base))
    klass.hobo_model
    klass.class_eval(&b)
    klass.delete_all rescue nil
  end
  
  def user_model(name, &b)
    klass = Object.const_set(name, Class.new(ActiveRecord::Base))
    klass.hobo_user_model
    klass.class_eval(&b)
    klass.delete_all rescue nil
  end
  
  def create_database_sqlite3
    ActiveRecord::Base.establish_connection(:adapter  => "sqlite3",
                                            :database => "#{HOME}/test.sqlite3",
                                            :timeout  => 5000)
  end
  
  def init
    create_database_sqlite3
    make_models
    up, down = HoboFields::MigrationGenerator.run
    ActiveRecord::Migration.class_eval(up)
  end
  
  def make_models

    model :Response do
      fields do 
        body :string
      end
      belongs_to :user
      belongs_to :recipe
      belongs_to :request
    end

    model :Comment do
      fields do
        body :string
      end
      belongs_to :user
      belongs_to :recipe
    end
  
    model :Request do
      fields do
        body :string
      end
      belongs_to :user
      has_many   :responses
    end

    model :Recipe do
      fields do
        name :string
        body :string
      end
      belongs_to :user,         :creator => true
      has_many   :responses,    :dependent => :destroy
      has_many   :comments,     :dependent => :destroy
      has_many   :images,       :dependent => :destroy, :accessible => true
      belongs_to :code_example, :dependent => :destroy, :accessible => true
      has_many   :collaboratorships
      has_many   :collaborators, :through => :collaboratorships, :source => :user, :accessible => true
      
      def create_permitted?;  acting_user == user end
      def update_permitted?;  acting_user == user end
      def destroy_permitted?; acting_user == user end
    end
    
    model :Collaboratorship do
      belongs_to :user
      belongs_to :recipe
      def create_permitted?;  recipe.user == acting_user end
      def destroy_permitted?; recipe.user == acting_user end
    end
    
    model :Image do
      fields do
        name :string
      end
      belongs_to :recipe
      delegate :user, :to => :recipe
      def create_permitted?;  user._?.paid_up? && user == acting_user end
      def update_permitted?;  user == acting_user end
      def destroy_permitted?; user == acting_user end
    end
    
    model :CodeExample do
      fields do
        filename :string
      end
    end

    user_model :User do
      fields do
        name    :string
        paid_up :boolean
      end
      has_many :recipes
      has_many :comments
      has_many :responses
      has_many :requests
      
      lifecycle do
        state :active, :default => true
      end
    end
    
  end
  
end