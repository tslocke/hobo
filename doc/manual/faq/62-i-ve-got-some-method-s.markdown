# I've got some method(s) I want to set for multiple models

Originally written by kevinpfromnm on 2010-08-04.

Hi, all.

I'm working with a data model in which every table has cre_usr and
upd_usr fields, to be filled in with the name of a logged-in user
whenever a row is created or updated.

I tried to create an abstract BaseModel class to supply a default
before_validation_on_create, using self.abstract_class = true;
however, it appears that Hobo doesn't look at abstract_class, because
I get TABLE BaseModel does not exist.  This would be my preferred
approach, since it seems DRY-er than anything else.

Second best would be to employ :creator => true  in every hobo_model,
but I don't see any equivalent that would fire only on update.  I also
don't see a way to customize the column names that receive the
acting_user value.

Any ideas on how to move forward?  What's the best way to do this?
SK 