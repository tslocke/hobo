Flexibility Matters
{.document-title}

If you are looking for an automatically generated web application, there are many projects that will give you one.  Many live in the Java world, but three very popular projects give you a very nice environment for model development while providing automatic interfaces.   With Rails you can use [ActiveAdmin](http://activeadmin.info/) and [RailsAdmin](https://github.com/sferik/rails_admin), and [Django](https://www.djangoproject.com/) is a popular alternative to Rails that provides these capabilities out of the box.

The major difference between these frameworks and Hobo is right in the name.   They're admin frameworks.   Hobo is an application framework that gives you an automatic admin interface as a side effect.

In a typical application, an automatic interface can deliver 90 or 99% of what you need straight out of the box.  But that remaining 1% is likely a very critical piece of your application, and cannot be part of any automatic toolkit because it's unique to your needs.   With the other admin frameworks you often end up rewriting most or all of the other 99% of the application just so you can fit your 1% in.