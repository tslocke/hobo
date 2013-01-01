# How do I get multiple or complicated queries to work with hobo_index?

Originally written by kevinpfromnm on 2010-08-08.

Hi all,

I'm trying to display an odd sort of index page.  I'm cherry picking
three different data sets from one parent model (Manuscripts).
Because of the way I need to pull data out, I can't use a fancy
group_by scope call.  I thought I'd be there if I was able to write
each query as a named scope.  However, when I try to concatenate or
operate on the three results in any way to push them into one object,
the scope turns into an array and hobo_index is apparently incapable
of handling an array for its block; it needs a scope.

So I'm wondering if
  1.) Anyone knows how to concatenate scopes and coerce them back
into scopes
  2.) Anyone knows how to pass an array into hobo_index
  3.) How to pass multiple collections into hobo_index

To further complicate matters, I need the three queries to be separate
in some way.  My current solution was to grab the three queries, and
then create a scoped result by collecting all the ids from my three
queries.  However, then I have no way of telling where one section
stops and the next begins in the view.

Thanks for any help :) 