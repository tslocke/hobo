# How do I build a hobo app on an existing, live database

Originally written by smvanbru on 2009-06-08.

I have a live legacy system in place.

I'd like to access, and modify some of the data with hobo. However there are so many tables and fields, that to completely recreate all the models in hobo would take weeks.  I'd prefer to just create models for tables as I need them.  (or better yet, run a script that creates all the models based on the tables currently in the database.) 

The hobo_migration script wants to drop all tables in the schema that it doesn't know about.  Something I don't want.

How can I use hobo in such a legacy environment?