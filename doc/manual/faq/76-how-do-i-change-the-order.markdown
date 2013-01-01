# How do I change the order of  fields in my form or show page?

Originally written by kevinpfromnm on 2010-08-22.

does hobo understand how to display a `has_many` through relationship?

I'm trying to add a association of many lots per user.

    class Lot < ActiveRecord::Base

      hobo_model # Don't put anything above this

      fields do
        number :integer
        code   :string
        timestamps
      end
      has_many :lots_users
      has_many :users, :through =>'lots_users', :foreign_key =>'user_id'
    .....

    class User < ActiveRecord::Base

      hobo_user_model # Don't put anything above this

      fields do
        name          :string, :required, :unique
        email_address :email_address, :login => true
        administrator :boolean, :default => false
        timestamps
      end
      has_many :lots_users
      has_many :lots, :through =>'lots_users', :foreign_key => 'lot_id'

    ....

    class LotsUsers < ActiveRecord::Base
      belongs_to      :user
      belongs_to      :lot
    end 