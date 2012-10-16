# Paperclip with Hobo

Install this plugin alongside [paperclip](http://jimneath.org/2008/04/17/paperclip-attaching-files-in-rails/).

It adds two small things:

 - Automatically declares the fields for you, so you can just add
 
        has_attached_file :photo

   to your model, and then run the migration generator.   All options
   are automatically passed on to paperclip's `has_attached_file`.
   
 - Declares an input field
 
        <def tag="input" for="Paperclip::Attachment">
          <%= file_field_tag param_name_for_this, attributes %>
        </def>
        
   (to get this, you need `<include src="paperclip" plugin="paperclip_with_hobo"/>` in application.dryml)


# Installation

Paperclip's official repository (https://github.com/thoughtbot/paperclip.git) has a bug (at the time of writing) that makes paperclip with hobo crash (see http://groups.google.com/group/hobousers/browse_thread/thread/752e154ff9725486). 

But we can use a fork which is nicely patched. Add this to your Gemfile:

    gem 'paperclip', :git => "git://github.com/jeanmartin/paperclip.git", :branch => "master"
    
Update your bundle:

    bundle
    
Install paperclip_with_hobo:

    rails plugin install git://github.com/tablatom/paperclip_with_hobo.git

Include the `paperclip_with-hobo` taglib in your `application.dryml`

    <include src="paperclip" plugin="paperclip_with_hobo"/>

Add paperclip to one of your models:

    has_attached_file :photo

Your default form for the model will now include the four attributes
added by `has_attached_file`.  To actually allow uploading, you will
need to manually add the attachment field (`photo` in the above example)
to your form, and don't forget to add the `multipart` attribute:

    <extend tag="form" for="MyModel">
      <old-form merge multipart>
        <field-list: fields="photo, other-fields, ..."/>
      </old-form>
    </extend>

## Important Note

The name of the plugin is important. It doesn't *have* to be `paperclip_with_hobo` but it will only work if this plugin loads *after* paperclip itself. Calling it `paperclip_something` is a good way to ensure that.
