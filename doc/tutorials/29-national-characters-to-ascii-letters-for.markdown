# National characters to ascii letters for user-friendly URLs

Originally written by Adam Hoscilo on 2009-06-18.

Simple way to have nice URLs:
1. use this lib: <http://snippets.dzone.com/user/Bragi> 
2. in your Model add 'to\_param' method that looks something like this:

example:

    def to_param
      "#{self.id}-#{self.name.to_textual_id}"
    end

I've made few changes to that lib. My version looks like this:

<http://pastie.org/517065>



