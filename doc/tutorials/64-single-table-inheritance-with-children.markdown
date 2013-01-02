# Single Table Inheritance with Children

Originally written by dziesig on 2011-01-14.

I have used the design pattern which consists of STI with child tables in many situations before (RoR, Delphi, ... ).  I looked for existing recipes but the existing one didn't exactly fit the design pattern (and didn't seem to work with Hobo 1.3 either).

My current instantiation of the design pattern is as follows:

The primary class is a Profile - it has children in the form of a list of Phone Numbers (and other lists, all of which are implemented the same way) - it is not directly manipulated (it could be, but I haven't tried. YMMV).

There are three sub-classes of Profile:  Agents, Clients, CooperatingAgents - (yes my client is a real-estate agency).

Supporting tables:  PhoneKind (e.g., Home, Office, Home FAX, Cell, ... ).

I have simplified the contents of the various tables below by eliminating a lot of the real-estate-specific columns (which don't add to understanding the hobo problem/solution anyway) and permissions (which are also application-specific).

The following assumes an hobo app named sti-with-children

    hobo new sti-with-children
    cd sti-with-children

    hobo generate resource phone_kind kind:string
    hobo generate resource phone_number number:string
    hobo generate resource profile name:string street:string #snip...
    hobo generate resource client
    hobo generate resource agent
    hobo generate resource cooperating_agent

Edit the models:

**phone\_number.rb**

      snip ...

      fields do
        number :string, :required => true # Hobo bug? see bottom of recipe
        timestamps
      end

      belongs_to :phone_kind
      belongs_to :profile
      belongs_to :agent
      belongs_to :client
      belongs_to :cooperating_agent
  
      validates_presence_of :phone_kind # Hobo bug? see bottom of recipe
  
      # The never_show line gets rid of extraneous fields that could otherwise
      # result in erroneous behavior.  There is a residual bug here.  I tried
      # to add :profile to the list.  When I did, attempting to display the
      # phone number resulted in a Hobo error message decrying the attempt to
      # display a non-readable field.  I will look at this further and if
      # necessary I will post a ticket and fix this recipe when possible.
      # Editing application.dryml as shown below gets rid of the profile field.

      never_show :agent, :client, :cooperating_agent

      def name
        number + ' ' + phone_kind.kind # minimal formatting - this could be fancier
      end
  
      # --- Permissions --- #

      snip ...

**phone\_kind.rb**

      snip ...

      fields do
        kind :string
        timestamps
      end

      has_many :phone_numbers
  
      # --- Permissions --- #

      snip ...

**profile.rb**

      snip...

      fields do
        name :string
        street :string
        sti_type :string       # Add this
        timestamps
      end
  
      set_inheritance_column :sti_type # Add this
    
      has_many :phone_numbers    # This is normal relationship
      children :phone_numbers    # This was needed to make the phone_numbers appear.
  
      # --- Permissions --- #

      snip ...

**agent.rb**

    class Agent < Profile # For STI

      # Leave out the hobo_model line.  Without it, there is no tab for the class (e.g. Agent tab).
      # With it, the ^(*&% thing overflows the stack when creating, editing, etc.
       
      has_many :phone_numbers  # The other recipe(s) say leave the sub-class models empty, but
      children :phone_numbers  # I needed both these lines to make the app work.

    end

Similarly for **client.rb** and **cooperating\_agent.rb**:

    class Client < Profile 

      # Leave out the hobo_model line.  Without it, there is no tab for the class (e.g. Agent tab).
      # With it, the ^(*&% thing overflows the stack when creating, editing, etc.
  
      has_many :phone_numbers
      children :phone_numbers

    end

    class CooperatingAgent < Profile 

      # Leave out the hobo_model line.  Without it, there is no tab for the class (e.g. Agent tab).
      # With it, the ^(*&% thing overflows the stack when creating, editing, etc.
  
      has_many :phone_numbers
      children :phone_numbers

    end

Edit the controllers:

**phone\_numbers\_controller.rb**

    class PhoneNumbersController < ApplicationController

      hobo_model_controller

      auto_actions :all, :except => :index  # I didn't want the Phone Numbers tab to be visible
  
      auto_actions_for :profile, :create			# These were required to get the
      auto_actions_for :agent, :create			# Add Phone Number link to
      auto_actions_for :client, :create			# appear on all of the show pages
      auto_actions_for :cooperating_agent, :create

    end

**profiles\_controller.rb**

    class ProfilesController < ApplicationController

      hobo_model_controller

      auto_actions :all, :except => :index # I didn't want the Profile tab to be visible

    end

Edit application.dryml

    # Add this at an appropriate place (I put it at the end).

    <def tag="form" for="PhoneNumber">
      <form merge param="default">
        <error-messages param/>
        <field-list fields="number, phone_kind" param/> <!-- NOTE: ", profile" has been removed -->
        <div param="actions">
          <submit label="#{ht 'phone_number.actions.save', :default=>['Save']}" param/><or-cancel param="cancel"/>
        </div>
      </form>
    </def>

    <!-- ====== Main Navigation ====== -->

    <def tag="main-nav">
      <navigation class="main-nav" merge-attrs param="default">
        <nav-item href="#{base_url}/">Home</nav-item>
    <!-- Manual addition of sub-class tabs -->
        <nav-item with="&Agent"><ht key="agent.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
        <nav-item with="&Client"><ht key="client.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
        <nav-item with="&CooperatingAgent"><ht key="client.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
    <!-- =============================== -->
        <nav-item with="&PhoneKind"><ht key="phone_kind.nav_item" count="100"><model-name-human count="100"/></ht></nav-item>
      </navigation>
    </def>

    <def tag="show-page" for="PhoneNumber">
      <page merge title="#{ht 'phone_number.show.title', :default=>['Phone number'] }">

        <body: class="show-page phone-number" param/>

        <content: param>
              <header param="content-header">
    <!-- #######################################################################################
         Removing the following line eliminated a (Not Available) link-substitute from the page.
         It could be replaced by a series of < if= ... >tags based on the sti_type field to link
         back to the appropriate sub-class if desired.
         ####################################################################################### -->
           <!--     <a:agent param="parent-link">&laquo; <ht key="phone_number.actions.back_to_parent" parent="Agent" name="&this">Back to <name/></ht></a:agent> -->
                <h2 param="heading">
                  <ht key="phone_number.show.heading" name="&this.respond_to?(:name) ? this.name : ''">
                    <name/>
                  </ht>
                </h2>

                <record-flags fields="" param/>

                <a action="edit" if="&can_edit?" param="edit-link">
                  <ht key="phone_number.actions.edit" name="&this.respond_to?(:name) ? this.name : ''">
                    Edit Phone number
                  </ht>
                </a>
              </header>
    
              <section param="content-body">
    <! ##################################################################################
       Removing the following line eliminated another (not Available) link-substitute.
       I don't know where it came from since profile doesn't have a description field.
       ################################################################################## -->
           <!--     <view:profile param="description"/>  -->
                <field-list fields="number, phone_kind" param/>
              </section>
        </content:>
    
      </page>
    </def>


This edit was necessary (1) to remove the "profile" field which could have caused erroneous behavior.  Removing it via the never\_show method failed with a Hobo error; (2) to add back the missing menu tabs, and; (3) To remove extraneous (Not available) link-substitutes associated with profile.

Once you have done the above, then:

    hobo generate migration
    rails server

I have not been able to get the appropriate tabs for the sub-classes to appear without causing a stack overflow when performing db operations on the sub-classes.  With the exception of that, everything works if you use the appropriate route (e.g. localhost/clients, or localhost/agents).  In my app, I just manually modified the main menu to include tabs for the sub-classes as shown in application.dryml above.

There is minor exception to it working as expected:  when the validation for the phone number fails during create or edit, there is **NO notification** to the user.  It just silently re-loads the failing page.  I think this is a bug in Hobo, but I haven't investigated any further yet.




