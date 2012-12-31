# Optimistic Locking in Hobo

Originally written by iainbeeston on 2009-11-27.

A rarely used feature of activerecord is the lock\_version column, which (if present) enables optimistic locking for that table. When activerecord updates that model it will compare the lock\_version of the version being saved against the version in the database, and if they aren't the same then it will throw a StaleObjectError, which prevents concurrent updates from overwriting one-another. If they do match then the lock\_version is incremented (it's an integer) to invalidate any updates that are waiting to happen. This is a great way of increasing the safety and (potential) concurrency of your app (without needing more traditional concurrency schemes like table locking).

To implement this in your hobo app you need to do update all 3 layers of your model (the model, view and controller).

# Model

This part's easy, just add lock\_version as a field in your models (and obviously generate a migration to add it to the database as well).

    class ConcurrentModel < ActiveRecord::Base
    
        hobo_model # Don't put anything above this

        # --- Fields --- #

        fields do
            lock_version :integer, :default => 0
            timestamps
        end

        never_show :lock_version
    end

Note that I've set the default to 0 (this is important or activerecord won't have a value to compare against when it updates). Also, the never\_show macro is useful because it hides the field from rapid (so it won't appear in any of your views)

# View

Next you'll need to add it to your forms so that when the user submits an update the server is sent the lock\_version that was current when they loaded the model. Thanks to rapid you can extend the form tag itself and this change will be reflected in every form rendered in your app.

    <extend tag="form">
        <old-form merge>
            <before-field-list:>
                <input type="hidden" name="#{param_name_for_this}[lock_version]" value="&this.lock_version" if="&this.has_attribute?(:lock_version) && !this.new_record?"/>
            </before-field-list:>
        </old-form>
    </extend>

    <extend tag="input-many">
        <old-input-many merge-params merge-attrs='&attributes - [:fields]'>
            <do param="default">
                <input type="hidden" name="#{param_name_for_this}[lock_version]" value="&this.lock_version" if="&this.has_attribute?(:lock_version) && !this.new_record?"/>
                <field-list merge-attrs='fields'/>
            </do>
        </old-input-many>
    </extend>

Here I've added lock_version to the input-many tag as well as the form tag - this is because input-many doesn't re-use form, but instead just calls field-list on any associated models. (Otherwise models updated through an input-many wouldn't be protected by optimistic locking).

# Controller

At this point optimistic locking will work, but the user will get a nasty error screen if a StaleObjectError is thrown. To correct this, you'll need to update your controller to catch the error, then reload the model (with the updated values) and send them back to the previous page in the same way as a validation error would.

     def update
          hobo_update
          rescue ActiveRecord::StaleObjectError
               flash_notice "This #{model.view_hints.model_name} was changed by someone else while you were editing it. Please try again."
               response_block(&block) or respond_to do |wants|
                    wants.html do
                         # reload the model from the database
                         self.this = find_instance
                         # re-render the form
                         re_render_form(:edit)
                    end
                    wants.js do
                         render(:status => 500, :text => ("There was a problem with that change.\n" + @this.errors.full_messages.join("\n")))
                    end
               end
          end
     end

If you like you can override the update method in hobo itself and get this across all of your models.


And that's it! Now your users will get a nice, user-friendly flash notice if they try a concurrent update, whereas before they would have silently overwritten someone else's update.

To test it, try opening the same edit page (for the same model) twice in two different browsers (as you can have a different session in each). Change a few fields in both, then save them both (without reloading either after saving). The second one to be saved will show the warning above and reject the update.

The idea for this recipe came from [Scripted Zen](http://scriptedzen.blogspot.com/2007/08/optimistic-locking-in-rails-with-active.html), which is one of the few places I've seen optimistic locking discussed (besides the pragmatic programmers rails book).

