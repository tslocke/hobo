# Importing an existing database schema

Originally written by lmorris99 on 2011-01-29.

I have a MySQL database already created and populated.
I was using ActiveScaffold, so it's a nice Rails database with _id fields for foreign keys, etc.
I'd like to let Hobo generate its normal UI against this existing database.

I guess one way to do it is to write a script that reads the existing table and field names, and spits out a lot of 
* ruby script/generate hobo_model_resource TABLEA FIELDA1:type FIELDA2:type ...
*  ruby script/generate hobo_model_resource TABLEB FIELDB1:type FIELDB2:type ...

where TABLE and FIELD names come from the existing database layout.

Is there a better way? Perhaps using the existing schema.rb?
