# Uploading for Hobo app

Originally written by brett on 2008-11-03.

What if you want to upload a file to your app?  You can use the  <a href="http://github.com/technoweenie/attachment_fu/tree/master">attachment_fu</a> plugin.

The model code needs filename and size and perhaps other fields depending on your implementation, surf over to <a href="http://svn.techno-weenie.net/projects/plugins/attachment_fu/README">techno-weenie</a> for info on what attachment\_fu supports.  This example assumes the model is named ImportProject.

    fields do
        content_type :string
        filename     :string    
        size         :integer
        timestamps
      end
  
      has_attachment :storage => :file_system
               , :max_size => 100.megabytes
               , :path_prefix => "public/import_projects"
      validates_as_attachment

To get the plugin from the git repository change directory over to the plugins directory clone from git.

git clone git://github.com/technoweenie/attachment\_fu.git


You may need this patch:

create a file appname/lib/attachment\_fu\_patch.rb

    require 'tempfile'
    
    class Tempfile
      def size
        if @tmpfile
          @tmpfile.fsync # added this line
          @tmpfile.flush
          @tmpfile.stat.size
        else
          0
        end
      end
    end

And this needs to be added to: appname/config/environment.rb

    require 'lib/attachment_fu_patch.rb'

environment.rb

    # Be sure to restart your server when you modify this file

    # Uncomment below to force Rails into production mode when
    # you don't control web/app server and can't set it the proper way
    # ENV['RAILS_ENV'] ||= 'production'
    
    # Specifies gem version of Rails to use when vendor/rails is not present
    RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION
    
    # Bootstrap the Rails environment, frameworks, and default configuration
    require File.join(File.dirname(__FILE__), 'boot')
    
    require 'lib/attachment_fu_patch.rb'
    
    Rails::Initializer.run do |config|
    ...

How about some view code? appname/app/views/import\_project/new.dryml

    <%= error_messages_for :import_project %>
    
    <new-page>
      <form: enctype="multipart/form-data">
        <label>Choose File</label>
        <input type="file" name="import_project[uploaded_data]"/>
        <submit label="Upload File"/>
      </form:>
    </new-page>

When you create a new import project you should have an upload button to select the file for uploading.


