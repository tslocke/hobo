# How come my form is blank?

The most likely cause of forms not displaying is due to permission errors.   Read [The Permission System](http://cookbook.hobocentral.net/manual/permissions) and check your `attr_accessible` declarations.

If the entire form is missing you can add alternate content through an else clause:

    <form/>
    <else> No permission to display form </else>

It's also possible that the form is displaying but none of the fields are.   You can force the display of the fields with

    <form>
      <field-list: force-all/>
    </form>

You probably don't want that in production code, though!