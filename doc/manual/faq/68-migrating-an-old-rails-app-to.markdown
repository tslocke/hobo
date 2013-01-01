# Migrating an old rails app to hobo

Originally written by kevinpfromnm on 2010-08-08.

We have an old Rails application (developed in 2005) and we would like
to revamp it using Hobo. We are starting to read Hobo's manual and
learn more about it but one concern that we have is that because this
application is live, we don't want to make any intrusive changes to
the database. We would like to develop the new application while the
old one is running. Do the Hobo generators support that? When we
generate our resources and we specify all the fields in our current
tables, will Hobo learn from them so that it doesn't "destroy" any
data?

Thanks,
JD