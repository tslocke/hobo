# Using Legacy data in Hobo

Originally written by gigg on 2010-07-02.

Can someone put a more complete solution together for legacy database integration into a hobo app please?

I know you can use these options:

  set_primary_key "old_primary_key"
  set_inheritance_column :category ## in case type is used
  establish_connection :old_database

I have also seen the post here:
http://cookbook.hobocentral.net/questions/36-how-do-i-specify-primary-and

Which is not conclusive.

My question includes how do you tell hobo not to want to change the size of the column width and allow it to use enum options instead of strings for columns?

Thanks for any help.



