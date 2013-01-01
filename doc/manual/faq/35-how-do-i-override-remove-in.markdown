# How do I override "remove" in table-plus to only remove from ":through" class?

Originally written by oldlibmike on 2009-06-20.

I have a database with :collection has_many :books, :through => :collbooks.
I have a show page that shows the collection and a table_plus of all books.

I would like to include the "remove" action with <controls/>, but I want the remove action to only delete the :collbooks table and leave the :book intact.

As things are now, the remove will actually remove the book entirely.

Thanks in advance!

Mike