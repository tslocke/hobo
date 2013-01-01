# My changes to application.dryml are being ignored.

Development mode in Hobo 2.0 is a lot faster than development mode in
Hobo 1.3. Part of the reason is because it's a little bit pickier
about what files it reloads when things change. To force a reload of
application.dryml or front_site.dryml, simply touch the dryml file for
your current view. For example, if you touch app/views/foos/show.dryml
and then reload /foos/17, all changed DRYML files that are required by
show.dryml will be reloaded.
