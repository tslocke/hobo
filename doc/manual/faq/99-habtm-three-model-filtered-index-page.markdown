# HABTM three model filtered index page

Originally written by slm4996 on 2012-01-17.

I have been trying to figure out how to implement a filtered index page for a HABTM relationship.

Here are some simplified models:

    class Plant < ActiveRecord::Base
    
      hobo_model # Don't put anything above this
    
      fields do
        name						          :string
      end
    
      has_many :leaf_type,	:through => :leaf_type_assignments, :accessible => true
      has_many :leaf_type_assignments, :dependent => :destroy
    end



    class LeafTypeAssignment < ActiveRecord::Base
    
      hobo_model # Don't put anything above this
    
      fields do
        timestamps
      end
      
      belongs_to :plant
      belongs_to :leaf_type
    end


    class LeafType < ActiveRecord::Base
    
      hobo_model # Don't put anything above this    
    
      fields do
        name        :string
        description :text
        timestamps
      end
      
      validates_presence_of :name
      
      set_default_order "name" 
      
      has_many :plants, :through => :leaf_type_assignments
      has_many :leaf_type_assignments, :dependent => :destroy
    end

This is the closet thing that I have found so far:
https://groups.google.com/forum/#!starred/hobousers/XdhusnGjiuQ

But I can't seem to make this work. What am I doing wrong, or what should I do differently in my models to make this work?

Thank you.