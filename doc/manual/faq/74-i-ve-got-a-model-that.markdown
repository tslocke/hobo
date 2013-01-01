# I've got a model that belongs to a user.  How do I get it so users can only see their owned models?

Originally written by kevinpfromnm on 2010-08-22.

Hi,

I am still new to hobo and loving it. But I have come unstuck and cant
find an answer so I was hoping someone could help.

I have a user, contract, smartcard and device models. What I want to
do is allow a user to login and only see their contract, device and
smartcard. But, I cant figure out how to make it happen. Each user can
login and see all contracts, smartcards and devices which is not what
I want.

The relationships are:

    User

      has_many :contract_assignments, :dependent => :destroy
      has_many :contracts, :class_name => "Contract", :foreign_key => "owner_id"
      has_many :contracts, :through => :contract_assignments

    contract

      belongs_to :owner, :class_name => "User", :creator => true
      has_many :smartcards, :dependent => :destroy
      has_many :devices, :dependent => :destroy
      has_many :contract_assignments, :dependent => :destroy

    smartcard
      belongs_to :contract

    device
      belongs_to :contract

I just added this in user:

    has_many :contracts, :class_name => "Contract", :foreign_key => "owner_id"

 to see if i could get it to work as per the agility recipe. How do I
go about getting this to work?

Help would be truly appreciated. 