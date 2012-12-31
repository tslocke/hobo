# Setting up unix like permissions with hobo

Originally written by kevinpfromnm on 2010-08-10.

This recipe answers [How do I setup groups for permissions?](/questions/65-how-do-i-setup-groups-for)

For any unfamiliar with unix permissions, the basic concept is that each file, or in our case model instance, has an owner and group.  There are independent permissions for owner, group and everyone on read, write, and execute.

Because of the way hobo and rails work, I used view, write (update) and destroy.  Now, most of the work for this actually has to exist in the model instance.  So, to keep this DRY, we'll setup a module to handle the basic logic of permission and count on overriding for any exceptions.  http://gist.github.com/517863 has the module I ended up writing.  Save it in a file called unix_permissions.rb in app/models/

For it to work, it has to be included for one and there has to be a group model and user instances can have many groups.

    script/generate hobo_model_resource Group name:string
    script/generate hobo_model_resource GroupUser

In `app/models/user.rb` add

    has_many :group_users
    has_many :groups, :through => :group_users, :accessible => true

`app/models/group_user.rb`

    belongs_to :user
    belongs_to :group

`app/models/group.rb`

    has_many :group_users
    has_many :users, :through => :group_users, :accessible => true

`app/controllers/group_users_controller.rb`

    auto_actions :write_only

Note: only one of the group or user needs ability to add links technically.

Add these new tables and columns to the db

`script/generate hobo_migration`

At this point, you could add `include UnixPermissions` to a model(s), remove the default permission methods and have it work (mostly).  You'll want to clean up the views as by default it will show each of the permissions that's true on the model show page.  And likely move group/user administration to a subsite.

Remember, any of the methods defined here can be overridden just by redefining the method after the include UnixPermissions call.  Say for instance, you don't want anyone able to destroy a particular model:

    include UnixPermissions
    def destroy_permitted?
      false
    end

Obviously, this is not a perfect solution for all situations but should give you a starting point or some ideas for writing your own.

