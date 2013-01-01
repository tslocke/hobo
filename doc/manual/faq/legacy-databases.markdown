# Can Hobo work with legacy databases, and how?

Hobo supports legacy databases using the same mechanisms that Rails and ActiveRecord do.  The only thing really Hobo specific to keep in mind is that the `fields` declaration in your model is optional.  In Rails, it serves two primary purposes: to enable the migration generation tool to work, and to enable rich type declaration.

The former purpose is not necessary with legacy data, so you only need to add `fields` declaration for columns that you wish to declare as a rich type.