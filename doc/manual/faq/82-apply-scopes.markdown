# apply_scopes

Originally written by Etern on 2010-10-05.

The code for apply scopes will ignore any blank parameters, but what if you want to check if a parameter is false or nil?

i.e.

Model.apply_scopes(:completed_is => false)

Apply_scopes seems to ignore this, and if you use find, you aren't able to use paginate on it.