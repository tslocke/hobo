# Dynamic, Role-based Main Menu

Originally written by dziesig on 2011-04-19.

I have a demo site for this recipe that I posted to github.  Keep in mind that I have never used github before and am a relative new-comer to git itself.

https://github.com/dziesig/Hobo-Dynamic--Role-based-Main-Menu


This recipe implements a Dynamic Main Menu whose contents are a function of the 
site's models and the User's Role(s), with each User potentially having both Primary and Secondary Roles.

&lt;bs>
Background:  My daughter is a successful Real Estate Broker here in Florida. 
&lt;brag>She has degrees in Russian, French, Marketing and Computer Science.&lt;/brag> 
Together we collaborated on a Back Office Intranet originally implemented in 
Ruby-on-Rails (1.2 if I recall correctly).  The menu system on that website
was hard-coded to allow any given user to choose between two potential modes.
For example, the Broker is also an Agent with different needs for each role.
We had multiple roles:

       *   Administrator (me)
       *   Broker (my daughter)
       *   Reviewer (new for the Hobo version)
       *   Agent (my daughter plus many others)
       *   InactiveAgent (few)
       *   Unassigned (needed as a place holder).
  
The design called for a main menu with the following tabs:

       *   Home
       *   ModeSelect (caption is based on user's alternate role)
       *   Yada 1 (Required place-holder, never visible)
       *   Yada 2 (Broker-specific)
          *
       *   Yada 10 (Agent-specific)
          *
       *   Yada 20 (Reviewer-specific)
          *
       *   Yada 32 (it's a big site with many functions/data).

After a really helpful tip from kevinpfromnm, which eliminated a lot of redundant editing between migrations, and which serendipitously improved the appearance of
menus whose owners had primary and secondary roles, the menu design became:

       *   ModeSelect (caption is based on user's alternate role, if any)
           *
           <extra space>
           *
       *   Home
       *   Yada 1 (Required place-holder, never visible)
       *   Yada 2 (Broker-specific)
           *
       *   Yada 10 (Agent-specific)
           *
       *   Yada 20 (Reviewer-specific)
           *
       *   Yada 32 (it's a big site with many functions/data).
  
The admin menu was:

       *   Home
       *   Permissions
       *   Roles
       *   Users
  
The formats of these menus can be seen in the attached images (once someone tells me where the link is (hint, it is not the words "Upload image" on the left aside)).
In the meanwhile, the images are in the github repository noted above under the doc directory.

If all of the tabs on the main menu were visible simultaneously, 
there would be no room "above the fold" for application data.  
Also, there are things that the Broker/Administrator can do that 
we didn't want Agents know was possible.

My original Hobo design (or lack thereof) used a hard-coded main menu
that (like its Rails predecessor) was getting very hard to maintain.

I took a step back (figuratively) and looked at what Hobo supplied
in a "plain-vanilla" site with the intent of using dryml to extend it and map
the main menu to the permission/role system.
&lt;/bs>

The setup wizard choices need invite-only/email-invitation so the 
admin can set user's roles in this recipe.  There may be other
ways for the administrator to setup the restricted attributes of
users (specifically the user's role that only admin can change) but
I haven't tried to find them.

        hobo new DynamicMainMenu

        cd DynamicMainMenu
        
I found this permission/role implementation somewhere but I can't
remember where.  With a few mods to the original it works fine here.

        hobo g model permission_role
        hobo g resource admin::permission name:string description:string
        hobo g resource admin::role name:string description:string
        
This will populate the menu with some items.

        hobo g resource test_with_space name:string
        hobo g resource yada1  name:string
        hobo g resource yada2  name:string
        hobo g resource yada3  name:string
        hobo g resource yada4  name:string
        hobo g resource yada5  name:string
        hobo g resource yada6  name:string
        hobo g resource yada7  name:string
        hobo g resource yada8  name:string
        hobo g resource yada9  name:string
        hobo g resource yada10 name:string
        hobo g resource yada11 name:string
        hobo g resource yada12 name:string
        hobo g resource yada13 name:string
        hobo g resource yada14 name:string
        hobo g resource yada15 name:string
        hobo g resource yada16 name:string
        hobo g resource yada17 name:string
        hobo g resource yada18 name:string
        hobo g resource yada19 name:string
        hobo g resource yada20 name:string
        
        hobo g migration
        
At this point, you can start the app and see what happens when you have
a lot of menu items.  Note that the White *Current* tab impacts those below it.

Edit application.css

        /* Fixes the over-sized current tab */
        
        .page-header .navigation.main-nav li.current a {
          color: #222;
          background: url(../images/30-DBE1E5-FCFEF5.png) repeat-x #FCFEF5;
          border:0;
        }
        
        /* reduces size of the development-mode dryml file names */
        /* Note, this comes from a mod I made to the hobo templates */
        /* It is not necessary without my mods, but is present in the demo */
        .dryml_file
        {
          font-size: 9px;
        }

        
Refresh the page and the White current tab height returns to the default of the
other tabs and the menu behaves normally.


edit role.rb

        fields do
          name        :string, :unique, :index
          description :string
          timestamps
        end
      
        has_many :users;
      
        has_many :permissions, :through => :permission_roles, :accessible => true
        has_many :permission_roles, :dependent => :destroy
        
        # --- Permissions --- #
        
edit permission.rb

        fields do
          name        :string, :unique, :index
          description :string
          timestamps
        end
        
        has_many :roles, :through => :permission_roles, :accessible => true
        has_many :permission_roles, :dependent => :destroy
        
        # --- Permissions --- #


edit permission\_role.rb

        fields do
          timestamps
        end
      
        belongs_to :role
        belongs_to :permission
      
        def name
          if !role.nil? && !permission.nil?
            role.name + ' ' + permission.name
          else
            '<undefined>' # just in case
          end
        end
        
        # --- Permissions --- #

hobo g migration

edit user.rb

        fields do
          name          :string, :required, :unique
          email_address :email_address, :login => true, :required => true, :unique => true
          administrator :boolean, :default => false
          use_secondary_role 	:boolean, :default => false #when true, user assumes secondary role
          timestamps
        end
      
        belongs_to  :primary_role, :class_name => "Role"
        belongs_to  :secondary_role, :class_name => "Role"
        delegate    :permissions, :to => :role
        
        def role
          if self.use_secondary_role?
            self.secondary_role
          else
            self.primary_role
          end
        end
        
        def alternate_role
          if self.use_secondary_role?
            self.primary_role
          else
            self.secondary_role
          end
        end    
      
        def toggle_mode
          self.use_secondary_role = !self.use_secondary_role
          self.save!
        end
        
        # This gives admin rights and an :active state to the first sign-up.

< ..... snip ..... >

        alias_method_chain :new_password_required?, :invite_only
      
        # set default roles to Unassigned
        before_save do |user|
          self.primary_role_id = 6 if self.primary_role.nil?
          self.secondary_role_id = 6 if self.secondary_role.nil?
        end
        
        # --- Signup lifecycle --- #

< ..... snip ..... >

        #--------------------------------------------------------------------
        # Roles, Permissions, has_multiple_roles
        #--------------------------------------------------------------------
        
          def method_missing(method_id, *args)
            if match = matches_dynamic_role_check?(method_id)
              tokenize_roles(match.captures.first).each do |check|
                if self.role.name.downcase == check
                  return true
                end
              end
              return false
            elsif match = matches_dynamic_perm_check?(method_id)
              if !permissions.nil? 
                result = permissions.find_by_name(match.captures.first)
                return result
              end
            else
              super
            end
          end
        
          def has_multiple_roles?
            if self.secondary_role != nil
              return self.secondary_role != self.primary_role unless self.secondary_role.name == 'Unassigned'
            end
            false
          end
         
          private
          
          def matches_dynamic_role_check?(method_id)
            /^is_an?_([a-zA-Z]\w*)\?$/.match(method_id.to_s)
          end
         
          def tokenize_roles(string_to_split)
            string_to_split.split(/_or_/)
          end
        
          def matches_dynamic_perm_check?(method_id)
            result = /^can([a-zA-Z]\w*)\?$/.match(method_id.to_s)
            result
          end   
        end
        
hobo g migration

edit users\_controller.rb

          < ..... snip ..... >
        
          def toggle
            current_user.toggle_mode
            redirect_to "#{base_url}/"
          end
          
        end


edit routes.rb

          match 'search' => 'front#search', :as => 'site_search'
        
          match 'user/toggle' => 'users#toggle'
          
          # The priority is based upon order of creation:
          
          < ..... snip ..... >

          # Sample resource route within a namespace:
          #   namespace :admin do
          #     # Directs /admin/products/* to Admin::ProductsController
          #     # (app/controllers/admin/products_controller.rb)
          #     resources :products
          #   end
          namespace :admin do
            resources :roles
            resources :permissions
          end
  
Now for some DRYML magic (there may be a DRYer way for some of this, but
it works for me). Create the file:

app/views/taglibs/nav\_item.dryml

        <!-- 
          The extension of nav-item implements an interface to the
          Permission/Role subsystem such that a positive permission in the
          form of AccessMenuItem will show the <nav-item> associated with 
          MenuItem (Use caution, the rails convention implies singular names,
          I've already been burnt using the permission "AccessStreetTypes" 
          which should have been "AccessStreetType") -->
        
        <extend tag="nav-item">
          <% body = parameters.default
             body = h(this.to_s) if body.blank?
             name ||= body.gsub(/<.*?>/, '').strip
             show_it = !(current_user.class == Guest)
            if show_it
              show_it = (name == 'Home') || 
                        (name == 'Permissions') || 
                        (name == 'Roles') || 
                        (name == 'Users') || 
                        (name.include?(' Mode'))
              if !show_it
                access = "current_user.canAccess" + this.to_s + "?"
                show_it = !(eval access).nil?
              end
            end
          -%>
          
          <% if show_it %>
            <old-nav-item merge />
          <% else %>
            <old-nav-item merge style="display:none" />
          <% end %>
        </extend>

        <def tag="mode-nav-item">
          <% if current_user.respond_to?(:has_multiple_roles?) && current_user.has_multiple_roles?
            mode = "#{current_user.alternate_role} Mode" %> 
            <nav-item href="/user/toggle"><%= mode -%></nav-item>
          <% end %>
        </def>
        
The following is only necessary if you absolutely need to re-arrange the menu.  kevinpfromnm's tip populates the menu automatically by &lt;extending...> the &lt;main-nav> tag.       

Create the file app/views/taglibs/main\_navigation.dryml

Copy the head of app/views/tablibs/auto/rapid/pages.dryml that contains the
main menu into it, then make the noted change:

        <!-- ====== Main Navigation ====== -->
        
        <def tag="main-nav">
          <navigation class="main-nav" merge-attrs param="default">
            <nav-item href="#{base_url}/">Home</nav-item>
            <mode-nav-item/> <!-- ADD THIS IF YOU WANT TO HAVE MULTI-ROLE USERS -->
            <nav-item with="&TestWithSpace"><ht key="test_with_space.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada1"><ht key="yada1.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada2"><ht key="yada2.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada3"><ht key="yada3.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada4"><ht key="yada4.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada5"><ht key="yada5.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada6"><ht key="yada6.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada7"><ht key="yada7.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada8"><ht key="yada8.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada9"><ht key="yada9.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada10"><ht key="yada10.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada11"><ht key="yada11.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada12"><ht key="yada12.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada13"><ht key="yada13.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada14"><ht key="yada14.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada15"><ht key="yada15.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada16"><ht key="yada16.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada17"><ht key="yada17.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada18"><ht key="yada18.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada19"><ht key="yada19.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
            <nav-item with="&Yada20"><ht key="yada20.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
          </navigation>
        </def>
        

Notice that I re-arranged the Yada's so they were in numeric order, not alphanumeric order.
I did this only to  be sure that we were NOT using the rapid-generated menu.  Using the extended &lt;main-nav> tag will return them to the original alphanumeric order.

Edit application.dryml

        <include src="taglibs/auto/rapid/forms"/>
        <include src="taglibs/nav_item"/>
        <include src="taglibs/main_navigation"/> <!-- only if you used the 
        
        <set-theme name="clean"/>

End of the "don't do this unless..." section

kevinpfromnm's tip.  Create the file app/views/taglib/front\_site.dryml:

        <include src="rapid" plugin="hobo"/>

        <include src="taglibs/auto/rapid/cards"/>
        <include src="taglibs/auto/rapid/pages"/>
        <include src="taglibs/auto/rapid/forms"/>

        <set-theme name="clean"/>

        <extend tag="main-nav">
          <navigation class="main-nav" merge-attrs param="default">
          <mode-nav-item/>
          <old-main-nav merge-attrs/>
          </navigation>
        </extend>
        
At this time, if you restart the app and refresh your browser, you
will see a very empty main menu

Now to populate the roles and permissions.

Login as the administrator (first user).  In the gitHub demo site, the admin email is a@a.com with 'Password' as the password (all users of the demo site have 'Password' as their passwords).

Select the Admin link to get to the Admin sub-site.

Select the Roles tab on the menu and start adding Roles.
In the demo site they are (in descending capability order):

*  Administrator
*  Broker
*  Reviewer
*  Agent
*  InactiveAgent
*  Unassigned << note this is hard-coded in user.rb as the 6th item.

You do not have to add permissions at this time.  You do not have
to order the entries except, for now, the 6th entry is the initialization
value when users are created (I'll fix that soon, I hope).

Select the Permissions tab on the menu and start adding
menu permissions.  Note that menu permissions start with
Access and contain the SINGULAR name of the associated model.

Thus in the demo site,

       *  AccessYada1
       *      .
       *      .
       *      .
       *  AccessYada20

map to each of the dummy model menu tabs, even though the tabs are
captioned Yada1s, ..., Yada20s.

In my real-estate app, I use the locales to re-caption the menu tabs (this works
even if you only use a single language, I implement en and es so it is not much 
of an additional hardship) just because the model names don't necessarily map to concise labels.

Let's add some permissions to the roles.

Select the Roles tab on the menu and map permissions to each role as you like.

I entered some pseudo-random associations in the demo site.

Now add some users with various roles.  Since I have not setup the email
for the demo site, you will have to look in the terminal output for the email message
and manually copy the link for the invitation acceptance, as in:

        Sent mail to betty@broker.org (711ms)
        Date: Sun, 17 Apr 2011 21:18:20 -0400
        
        From: no-reply@0.0.0.0
        
        To: betty@broker.org
        Message-ID: <4dab915cceea9_546d25615c84186cc@development.mail>
        Subject: Invitation to Dynamic Main Menu
        Mime-Version: 1.0
        Content-Type: text/html;
         charset=UTF-8
        Content-Transfer-Encoding: 7bit
         
        Betty Broker,
         
        You have been invited to join Dynamic Main Menu. If you wish to accept, please click on the following link
         
           http://0.0.0.0:3001/users/6-betty-broker/accept_invitation?key=48607c3d25d861ca00cb5062ae6662a3afcd58bd
        
        Thank you,
        
        The Dynamic Main Menu team.

As soon as you issue the invitation (in the real world), edit the new user and assign appropriate roles.  If you don't, and the new user is fast enough, she will encounter the situation where her roles are unassigned and she can't do anything.

Play with the demo site and you can see how the dynamics work.  The Broker and Reviewer both have alternate roles as Agents so the tab immediately to the left of Home allows them to toggle to the mode displayed on the tab.

Note also that the permission system is not limited to the AccessMenuItem function.  In my real-estate app, I have fine-grained
permissions that enable/limit each role's ability to (for example) view or modify other user's data.  The broker,
in broker mode, can edit everyone's profiles; in agent mode, she can only edit her own profile.  The permissions,
in this case are:

EditAllProfiles -- associated code: current\_user.canEditAllProfiles?

EditOwnProfile  -- associated code: current\_user.canEditOwnProfile?

in the absence of either of these permissions, the user can not even edit her own profile.

Many thanks to kevinpfromnm for tip on extending the main-nav tag.

One last comment.  If I were starting over, I would change the name of the Administrator role to something different to avoid confusion with the hobo user's administrator boolean.  For me this is more of a political issue; the name could be easily changed by editing the Role, but the rest of the staff is accustomed to it, (backwards compatibility with the rails app where it did not conflict), so I'm stuck with it (unless I just do it).





