# Mobile & iPad friendly sortable-collections

Originally written by Henry Baragar on 2012-08-21.

I could not get [sortable-collection](http://cookbook-1.0.hobocentral.net/api_tag_defs/sortable-collection) drag-and-drop to function on mobile devices and iPads and had to come up with the following solution.

For the purpose of this recipe, we are going to build on the [Task re-ordering](http://cookbook-1.0.hobocentral.net/tutorials/agility#task_reordering) in the Agility Tutorial (stories have many tasks that can be re-ordered).

To app/controllers/tasks_controller.rb file, add the following:

    web_method :move_higher
    web_method :move_lower

To the app/models/task.rb file, add the following:

    def move_higher_permitted?
      editable_by?(acting_user, :position)
    end
    
    def move_lower_permitted?
      editable_by?(acting_user, :position)
    end

To the app/views/taglibs/application.dryml file, add the following:

    <def tag="button-sortable-collection">
      <collection class="button-sortable" part="button-sortable-collection" id="button-sortable-collection">
        <before-item:>
          <div class="ordering-buttons">
           <unless test="&first_item?">
             <remote-method-button method="move_higher" if="&can_edit?" label="&uarr;" update="button-sortable-collec
           </unless>
           <unless test="&last_item?">
             <remote-method-button method="move_lower" if="&can_edit?" label="&darr;" update="button-sortable-collect
           </unless>
          </div>
        </before-item:>
      </collection>
    </def>

Aside:  please suggest a better tag name than "button-sortable-collection".

To the public/stylesheets/application.css file, add the following:

    div.ordering-buttons { float: left; color: white; margin-left: -10px; padding: 0; }

Change the app/views/stories/show.dryml file to:

    <show-page>
      <field-list: tag="editor"/>
      <collection: replace>
        <button-sortable-collection:tasks/>
      </collection:>
    </show-page>

It would be nice if this functionality could be added to the Hobo core, but it requires a better understanding of Hobo that I have.


