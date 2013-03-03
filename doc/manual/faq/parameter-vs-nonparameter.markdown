# Why can't I mix parameter and non-parameter tags?

When you have non-parameter tags in a tag call, you're basically
giving the parent a bunch of info in an ordered fashion, a single blob
of text as an example. Parameter tags are more like a hash with the
parameter name being the key, and the content wrapped being the value.
putting the two together provides 1) a problem of figuring out how to
order things, what goes where etc. and 2) a whole slew of potential
for cryptic bugs when the rules run across something unexpected. If
you must, use the default parameter for the stuff you'd want in
non-parameter tags with a word of warning - this can cause weird
behavior as sometimes the default tag wraps other parameters.

