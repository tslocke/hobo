# I've got a virtual field I want to submit with a form or lifecycle transition but not have it stored in the database

Originally written by kevinpfromnm on 2010-08-04.

I have a feeling that I have read something about this earlier, but
cannot seem to find the information anywhere.

I have a model that is using states and transitions. Now, when certain
transitions take place I need the user to supply a comment. This
comment is not the same model, and I cannot seem to figure out how to
include it. After transition is submitted this comment should also be
persisted.

I also have a couple of places where I consider adding view-only
fields to the transition. Fields that are not to be persisted, but
used as logics in the transition block.

Regards,
Ronny 