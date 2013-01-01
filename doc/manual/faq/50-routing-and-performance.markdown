# routing and performance

Originally written by kevinpfromnm on 2010-08-04.

I was perusing over the initializers in my project, and I saw we have
a hobo initializer.  It tells the modelrouter to reload routes on
every page request.  The way I understand it, these initializers get
loaded into every environment.  Does that mean the hobo router is
reloading its routes on every request, even in production?

Thanks.