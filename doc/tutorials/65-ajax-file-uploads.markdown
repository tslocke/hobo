# Ajax file uploads

Originally written by Bryan Larsen on 2011-01-16.




Note: actually there's one or two steps missing here:  you also need the formSubmit function in hobo-jquery.   If you have questions, ping me on the list.   Even better, this is built into Hobo 1.4.

With the [paperclip plugin](http://cookbook.hobocentral.net/plugins/paperclip_with_hobo) installed, Hobo supports file uploads, but does not support Ajax file uploads.   It seems like it should work, but the file doesn't get uploaded.   The problem is that browsers do not allow Javascript access to the local file system as a security measure.

To get around this, most sites either use a Flash plugin or use an ugly IFrame hack.   We'll use the [JQuery form plugin](http://malsup.com/jquery/form/), which packages up the IFrame hack.

You'll also need [this enhancement to Hobo](https://hobo.lighthouseapp.com/projects/8324-hobo/tickets/861-need-to-wrap-ajax-response-in-textarea).   You can either install the patch, or use 1.1.0.pre3 or 1.3.0.pre26 (?).

The first step is to install [JQuery form plugin](http://malsup.com/jquery/form/), using something like this:

    <extend tag="page">
      <old-page merge>
        <custom-scripts:>
          <hjq-assets/>
          <javascript name="jquery.form.js"/>
        </custom-scripts:>
      <old-page/>
    </extend>

This assumes you're using the [hobo-jquery plugin](http://cookbook.hobocentral.net/plugins/hobo-jquery).   See [its instructions](http://cookbook.hobocentral.net/plugins/hobo-jquery) for more details.

On our application, we have a package that has-many uploads.

    class Package < ActiveRecord::Base
      hobo_model
      has_many :uploads, :dependent => :destroy
    end

    class Upload < ActiveRecord::Base
      hobo_model
      fields do
        name :string
        timestamps
      end
      has_attached_file :attachment
      belongs_to :owner, :class_name => "User", :creator => true
    end

Our view is pretty standard Hobo Ajax:

    <edit-page>
      <after-form:>
        <hr/>
        <h3>Attachments</h3>
        <div part="attachments-div">
          <error-messages/>
          <table-plus:uploads fields="name, attachment_file_name, attachment_file_size"/>
        </div>
        
        <h3>Add an Attachment</h3>
        <form with="&new_for_current_user(this.uploads)" owner="package" message="Uploading..." update="attachments-div" without-cancel>
          <field-list: skip="package"/>
        </form>
       </after-form:>
     </edit-page>

But we need some extra stuff in the controller to correspond to the requirements listed [here for the jQuery form plugin](http://malsup.com/jquery/form/#file-upload).

    class UploadsController < ApplicationController
      hobo_model_controller
      auto_actions  :all, :except => [:index]
      auto_actions_for :package, [:create, :new]

      def create_for_package
        hobo_create_for :package do
          if valid?
            # we have to ignore the requested file type because the workarounds
            # necessary to send files via ajax don't allow us to set the
            # headers.  So we just assume that we need to send an Ajax
            # response.  We'll also Wrap that response in a textarea so
            # the browser keeps its hands off of it.
            ajax_update_response(params[:page_path], params[:render].values, {}, {:preamble => "<textarea>\nvar _update = Hobo.updateElement;", :postamble => "</textarea>"})
          else
            render(:status => 500,
                  :js => "alert(\"#{this.errors.full_messages.join(". ").gsub('\n', '')}\");")
          end
        end
      end
    end


