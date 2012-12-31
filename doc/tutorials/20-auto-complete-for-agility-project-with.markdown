# Auto Complete for Agility Project with Hobo 0.8.5 (It works)

Originally written by SeanMac on 2008-12-31.

First, I'm going by: http://cookbook.hobocentral.net/tutorials/agility (12/31/08).  The tutorial on http://hobocentral.net/ needs to be updated.


#How to get Auto-Complete to work:#

Go down to Section 'A form with auto-completion'.  First change "`hobo_completions :username, User.without_joined...`" to "`hobo_completions :name, User.without_joined...`".  This change ends up making auto complete bring up results.  However, once a user is selected an error pops-up.  To fix this, go to '`project_membership.rb`' and add ':accessible => true' to both 'belongs to' variables.  That should fix Auto-Complete.


#Other Fixes:#

In section 'Part 6 – Project Ownership', when you get down to restricting owner for creation permissions.  In `def create_permitted?`, `owner == acting_user` should be replaced with `owner_is? acting_user`.  Otherwise, no one will be able to create Projects because no one owns a project that hasn't been created yet.

In section 'Part 7 – Granting read access to others', right before 'The view layer' the tutorial should tell the user to run migration.  I understand that it's not hard to see that you need to migrate before you can view anything, but this is a tutorial and step-by-step instructions are nice.

In the next section 'The view layer', there is a slight problem with `<aside>`.  When memberships were created, Rapid instantly edited the Project page to have memberships and stories listed.  That means that it edited the page to have an `<aside>` section.  The tutorial doesn't take that into consideration and asks the user to modify the entire content.  It's good that the user gets a chance to edit this content, but the user will find it weird when they see two side panels in the end.  CHANGE this section so that the user just replaces the `<aside>` that is already on the rapid page.  My code is '`<show-page><aside:><h3>Project Members</h3>...</aside:>`'.

Thank you,
Sean

