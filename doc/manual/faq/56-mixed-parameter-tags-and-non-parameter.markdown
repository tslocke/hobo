# mixed parameter tags and non-parameter tags (did you forget a ':'?) trying to change a form field

Originally written by kevinpfromnm on 2010-08-04.

    > In any case, if you just want to swap out one field's tag in a list,
    > you could do this (assume the field is called special_field):

    > <field-list fields="...">
    >  <special-field-view:>
    >    <input for-type="text" />
    >  </special-field-view:>
    > </field-list>

The field is called note, so those lines of code should look like this
for me, right?

          <field-list fields="name, note"/>
          <note-view:>
            <input for-type="text" cols="80" rows="4"/>
          </note-view:>

In my app, I've created edit.dryml in the appropriate views
subdirectory, and copied the generated form out of forms.dryml into it
as follows:

     <edit-page>
        <content-body:>
    
          <form>
            <error-messages />
              <field-list fields="name, note, cre_usr, upd_usr, dist_type"/>
              <note-tag:>
                <input for-type="text" cols="80" rows="4"/>/>
              </note-tag:>
    
              <div >
                <submit label="#{ht 'dists.actions.save', :default=>['Save']}" />
                <or-cancel/>
              </div>
          </form>
        </content-body:>
     </edit-page>

First of all, this clearly isn't very DRY, but it's what I think that
the Agility tutorial tells me to do in the paragraphs where it
discusses filling in the content-body: parameter.

Second, it doesn't work.

    >mixed parameter tags and non-parameter tags (did you forget a ':'?) -- at app/views/dists/edit.dryml:4
    >Extracted source (around line #4):
    
    >1:  <edit-page>
    >2:     <content-body:>
    >3:
    >4:       <form>
    >5:         <error-messages />
    >6:           <field-list fields="name, note"/>
    >7:           <note-tag:>
