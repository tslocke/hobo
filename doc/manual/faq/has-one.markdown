# How come Hobo doesn't display an input for my `has_one`?

Historically, has_one was a bastard cousin to has_many that made it
difficult to support. We also haven't generally found the need for it,
perhaps because it's not available to us. In the meantime you can
approximate a has_one by using a has_many with validates_length_of to
constrain it to a single item.

That being said, Peter Pavlovich is working on support for has_one.

