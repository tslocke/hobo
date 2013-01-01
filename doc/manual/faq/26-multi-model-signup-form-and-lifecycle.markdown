# Multi-model Signup Form and Lifecycle

Originally written by Bean on 2008-11-15.

Let's say I have multiple models in addition to 'user' that I want to create and populate on the signup form.  Let's say I wanted to use a presenter pattern,and wrap it in a transaction.  When 'create' is called on user, it executes the 'create' defined in the lifecycle.  do_signup doesn't do the job.  How do I handle this?

Thanks!